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
    
    @Published var serviceError: Error? = nil
    @Published var isLoading: Bool = false
    
    init(selectedItem: ClientModel?, clientListRepository: ClientListRepositoryProtocol = FireBaseClientListRepository(), inspectionRepository: InspectionJobRepositoryProtocol = FirebaseInspectionJobRepository()) {
        self.clientListRepository = clientListRepository
        self.inspectionRepository = inspectionRepository
        self.selectedItem = selectedItem
        self.invoiceItems = selectedItem?.invoiceDetails ?? []
        if let clientId = selectedItem?.id {
            fetchInspection(clientId: clientId, isCompleted: true)
            fetchInspection(clientId: clientId, isCompleted: false)
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
            fetchInspection(clientId: clientId, isCompleted: true)
            fetchInspection(clientId: clientId, isCompleted: false)
        }
    }

}
