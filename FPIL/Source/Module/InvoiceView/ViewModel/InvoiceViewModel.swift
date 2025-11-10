//
//  InvoiceViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 30/10/25.
//

import Foundation
import UIKit
import FirebaseFirestore

// MARK: - ViewModel
@MainActor
class InvoiceViewModel: ObservableObject {

    @Published var items: [ServicePerformed] = []
    @Published var serviceError: Error? = nil
    @Published var isLoading: Bool = false
    @Published var client: ClientModel? = nil
    @Published var jobModel: JobModel? = nil
    

    private let invoiceRepository: InvoiceRepositoryProtocol
    
    init(invoiceRepository: InvoiceRepositoryProtocol = FireBaseInvoiceRepository(), items: [ServicePerformed] = [], client: ClientModel? = nil, jobModel: JobModel? = nil) {
        self.invoiceRepository = invoiceRepository
        self.items = items
        self.client = client
        self.jobModel = jobModel
    }
    
    func chooseTheService(item: ServicePerformed) {
        var item = item
        item.isSelected = !(item.isSelected ?? false)
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }
    
    func generateInvoice(building: Building, completion: @escaping (InvoiceDetails, Error?) -> Void) {
        isLoading = true
        let items = self.items.filter { $0.isSelected == true || $0.isDefault == true }
        let subTotal = items.reduce(into: 0.0) { result, item in
            result += item.price ?? 0.0
        }
        let taxRate = 8.0
        let taxAmount = subTotal * taxRate / 100
        let totalAmountDue = subTotal + taxAmount
        let invoiceId = "INV-\(getShortUUID())-\((client?.id ?? "").getShortID())"
        var details = InvoiceDetails(id: invoiceId, invoiceTitle: client?.fullName, inspectionsId: jobModel?.id, clientId: client?.id, generatedOn: Date(), totalAmountDue: totalAmountDue, subtotal: subTotal, taxAmount: taxAmount, taxRate: taxRate, isPaid: false, status: 1, building: building, servicePerformed: items)
        
        if let invoice = InvoicePDFGenerator.generateInvoicePDF(invoice: details, jobModel: jobModel, clientModel: client), let clientModel = client {
            uploadReviewReport(url: invoice) { error, url in
                if error == nil, let url {
                    details.invoicePDFUrl = url
                    var updatedItems: [String: Any] = [:]
                    if let invoiceData = details.toFirestoreData() {
                        updatedItems["invoiceDetails"] = FieldValue.arrayUnion([invoiceData])
                    }
                    self.invoiceRepository.createInvoice(clientModel: clientModel, updatedItems: updatedItems) { [weak self] result in
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            switch result {
                            case .success(let items):
                                print("Success adding tabs: \(items)")
                                completion(details, nil)
                            case .failure(let error):
                                self?.serviceError = error
                                completion(details, error)
                                print("Error fetching tabs: \(error)")
                            }
                        }
                    }
                } else {
                    completion(details, error)
                }
            }
        } else {
            completion(details, NSError(domain: "Can't find the Client Details", code: 404))
        }
    }
    
    func uploadReviewReport(url: URL, completion: @escaping (Error?, String?) -> Void) {
        if NetworkMonitor.shared.isConnected {
            
            //isLoading = true
                        
            FirebaseFileManager.shared.uploadFile(at: url, folder: "\(client?.id ?? "Client Invoices")/invoices/") { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        completion(nil, url)
                        print("Uploaded image URL: \(url)")
                    case .failure(let error):
                        self.isLoading = false
                        self.serviceError = error
                        completion(error, nil)
                        print("Upload failed: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            completion(NSError(domain: "Internet Connection Error", code: 92001), nil)
        }
    }
}

