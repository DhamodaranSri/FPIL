//
//  ClientDetailViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 30/10/25.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
@MainActor
class ClientDetailViewModel: ObservableObject {
    @Published var inspectionItems: [JobModel] = []
    @Published var currentInspectionItems: [JobModel] = []
    @Published var invoiceItems: [InvoiceDetails] = []
    @Published var selectedItem: ClientModel?
    private let clientListRepository: ClientListRepositoryProtocol
    private let inspectionRepository: InspectionJobRepositoryProtocol
    private let fireAuthService: FirebaseAuthService
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    @Published var serviceError: Error? = nil
    @Published var isLoading: Bool = false
    
    init(selectedItem: ClientModel?, clientListRepository: ClientListRepositoryProtocol = FireBaseClientListRepository(), inspectionRepository: InspectionJobRepositoryProtocol = FirebaseInspectionJobRepository()) {
        fireAuthService = FirebaseAuthService()
        self.clientListRepository = clientListRepository
        self.inspectionRepository = inspectionRepository
        self.selectedItem = selectedItem
        self.invoiceItems = selectedItem?.invoiceDetails ?? []
        if let clientId = selectedItem?.id {
            fetchInspection(clientId: clientId, isCompleted: true)
            fetchInspection(clientId: clientId, isCompleted: false)
        }
        
        if selectedItem == nil {
            fetchClientDetail(clientId: UserDefaultsStore.profileDetail?.id ?? "")
            fetchInspection(clientId: UserDefaultsStore.profileDetail?.id ?? "", isCompleted: true)
            fetchInspection(clientId: UserDefaultsStore.profileDetail?.id ?? "", isCompleted: false)
        }
    }
    
    func fetchClientDetail(clientId: String) {
        isLoading = true
        inspectionRepository.fetchClient(clientId: clientId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.selectedItem = items
                    self?.invoiceItems = items.invoiceDetails ?? []
                case .failure(let error):
                    self?.serviceError = error
                }
            }
        }
    }
    
    func fetchInspection(clientId: String, isCompleted: Bool) {

        let conditions: [(field: String, value: Any)] = [
            ("clientId", clientId),
            ("isCompleted", isCompleted)
        ]

        isLoading = true
        inspectionRepository.fetchAllInspectionJobs(forConditions: conditions) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    if isCompleted {
                        self?.inspectionItems = items
                    } else {
                        self?.currentInspectionItems = items
                    }
                case .failure(let error):
                    self?.serviceError = error
                    print("Error fetching tabs: \(error)")
                }
            }
        }
    }
    
    func refreshClientsList() async {
        // Simulate async refresh (API call etc.)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 sec delay
        if let clientId = selectedItem?.id {
            fetchClientDetail(clientId: clientId)
            fetchInspection(clientId: clientId, isCompleted: true)
            fetchInspection(clientId: clientId, isCompleted: false)
        } else if selectedItem == nil {
            fetchClientDetail(clientId: UserDefaultsStore.profileDetail?.id ?? "")
            fetchInspection(clientId: UserDefaultsStore.profileDetail?.id ?? "", isCompleted: true)
            fetchInspection(clientId: UserDefaultsStore.profileDetail?.id ?? "", isCompleted: false)
        }
    }
    
    func createNewSiteId() -> String {
        return "Site-\(getShortUUID())-\((UserDefaultsStore.profileDetail?.id ?? "").getShortID())"
    }
    
    func createClientModelwithNewInvoice(invoiceItem: InvoiceDetails, siteId: String) -> ClientModel? {
        //let siteId = "Site-\(getShortUUID())-\((UserDefaultsStore.profileDetail?.id ?? "").getShortID())"
        
        guard var clientModel = selectedItem, var invoices = clientModel.invoiceDetails else {
            return nil
        }
        
        if let index = invoices.firstIndex(where: { $0.id == invoiceItem.id }) {

            var invoice = invoices[index]

            // update your required fields
            invoice.isPaid = true
            invoice.inspectionsId = siteId
            invoice.paidDate = Date()

            invoices[index] = invoice
        }
        
        clientModel.invoiceDetails = invoices
        return clientModel
    }
    
    func invoiceDetailsUpdateAndCreateInspection(invoiceItem: InvoiceDetails, completion: @escaping (Error?) -> Void) {
        isLoading = true
        
        var updatedItems: [String: Any] = [:]
        
        guard let clientModel = selectedItem, var invoices = clientModel.invoiceDetails else {
            isLoading = false
            self.serviceError = NSError(domain: "Invoice / Client Not Found", code: 404)
            completion(serviceError)
            return
        }
        
        let siteId = "Site-\(getShortUUID())-\((UserDefaultsStore.profileDetail?.id ?? "").getShortID())"
        
        // Step 2: find matching invoice and update it
        if let index = invoices.firstIndex(where: { $0.id == invoiceItem.id }) {

            var invoice = invoices[index]

            // update your required fields
            invoice.isPaid = true
            invoice.inspectionsId = siteId

            invoices[index] = invoice
        }
        
        // Step 3: convert to Firestore data
        if let updatedData = invoices.toFirestoreDataArray() {
            updatedItems["invoiceDetails"] = updatedData
        }
        
        self.inspectionRepository.updateClient(client: clientModel, updatedItems: updatedItems) { result in
            self.isLoading = false
            switch result {
            case .success():
                completion(nil)
            case .failure(let error):
                self.serviceError = error
                completion(self.serviceError)
            }
        }
    }
    
    func paymentStatusUpdate(invoiceItem: InvoiceDetails, status: Int, completion: @escaping (Error?) -> Void) {
        isLoading = true
        
        var updatedItems: [String: Any] = [:]

        // Step 1: full invoiceDetails array
        guard let clientModel = selectedItem, var invoices = clientModel.invoiceDetails else {
            isLoading = false
            self.serviceError = NSError(domain: "Invoice / Client Not Found", code: 404)
            completion(serviceError)
            return
        }

        // Step 2: find matching invoice and update it
        if let index = invoices.firstIndex(where: { $0.id == invoiceItem.id }) {

            var invoice = invoices[index]

            // update your required fields
            invoice.status = status

            invoices[index] = invoice
        }

        // Step 3: convert to Firestore data
        if let updatedData = invoices.toFirestoreDataArray() {
            updatedItems["invoiceDetails"] = updatedData
        }
        
        self.inspectionRepository.updateClient(client: clientModel, updatedItems: updatedItems) { result in
            self.isLoading = false
            switch result {
            case .success():
                completion(nil)
            case .failure(let error):
                self.serviceError = error
                completion(self.serviceError)
            }
        }
    }
    
    func deleteInvoiceItem(invoiceItem: InvoiceDetails, completion: @escaping (Error?) -> Void) {
        isLoading = true
        
        if let pdfURL = invoiceItem.invoicePDFUrl, var clientModel = selectedItem {
            deleteUploadedImage(url: pdfURL) { error, isSuccess in
                if error == nil {
                    let invoiceArray = clientModel.invoiceDetails?.filter({ $0.id != invoiceItem.id})
                    var updatedItems: [String: Any] = [:]
                    if let invoiceData = invoiceArray?.toFirestoreDataArray() {
                        updatedItems["invoiceDetails"] = invoiceData
                    }
                    self.inspectionRepository.updateClient(client: clientModel, updatedItems: updatedItems) { result in
                        self.isLoading = false
                        switch result {
                        case .success():
                            completion(nil)
                        case .failure(let error):
                            self.serviceError = error
                            completion(self.serviceError)
                        }
                    }
                } else {
                    self.isLoading = false
                    self.serviceError = error
                    completion(self.serviceError)
                }
            }
        } else {
            isLoading = false
            self.serviceError = NSError(domain: "Invoice / Client Not Found", code: 404)
            completion(serviceError)
        }
        
    }

    func deleteUploadedImage(url: String, completion: @escaping (Error?, Bool) -> Void) {
        if NetworkMonitor.shared.isConnected {
                        
            FirebaseFileManager.shared.deleteImageFromFirebase(urlString: url) { error in
                DispatchQueue.main.async {
                    if error == nil {
                        completion(nil, true)
                    } else {
                        self.serviceError = error
                        completion(error, false)
                    }
                }
            }
        } else {
            completion(NSError(domain: "Internet Connection Error", code: 92001), false)
        }
    }
    
    func signout() {
        isLoading = true
                
        clientListRepository.userSignOut { [weak self] result in
            DispatchQueue.main.async {

                self?.isLoading = false
                switch result {
                case .success():
                    UserDefaultsStore.clearData()
                    self?.isLoggedIn = false
                case .failure(let error):
                    self?.serviceError = error
                    print("Error fetching tabs: \(error)")
                }
            }
        }
    }

}
