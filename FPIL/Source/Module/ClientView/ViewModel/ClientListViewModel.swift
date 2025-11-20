//
//  ClientListViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 24/10/25.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
@MainActor
class ClientListViewModel: ObservableObject {
    @Published var items: [ClientModel] = []
    @Published var selectedItem: ClientModel?
    private let clientListRepository: ClientListRepositoryProtocol
    @Published var selectedClient: ClientModel? = nil
    @Published var selectedInvoice: InvoiceDetails? = nil
    @Published var selectedFilter: String = "All"
    
    @Published var searchText: String = "" {
        didSet {
            filterItems()
        }
    }
    
    @Published private(set) var filteredItems: [ClientModel] = []
    @Published var serviceError: Error? = nil
    @Published var isLoading: Bool = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    var filterCategories: [String] {
        let grouped = Dictionary(grouping: items, by: { $0.clientType?.clientTypeName ?? "" })   // <-- update key here
        return grouped.keys.sorted()
    }
    
    func selectFilter(_ filter: String) {
        selectedFilter = filter
        filterItems()
    }
    
    init(clientListRepository: ClientListRepositoryProtocol = FireBaseClientListRepository()) {
        self.clientListRepository = clientListRepository
        fetchClientsList()
    }
    
    func fetchClientsList() {
        isLoading = true

        clientListRepository.fetchAllClientList(stationId: UserDefaultsStore.profileDetail?.parentId ?? "") {  [weak self] result in
            DispatchQueue.main.async {
                
                self?.isLoading = false
                switch result {
                case .success(let items):
                    UserDefaultsStore.allClientDetail = items
                    self?.items = items
                case .failure(let error):
                    self?.serviceError = error
                    print("Error fetching tabs: \(error)")
                }
                
                self?.filterItems()
            }
        }

    }
    
    func refreshClientsList() async {
        // Simulate async refresh (API call etc.)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 sec delay
        fetchClientsList()
    }

    private func filterItems() {
        var result = items
        
        // Apply horizontal filter
        if selectedFilter != "All" {
            result = result.filter { client in
                client.clientType?.clientTypeName == selectedFilter         // <-- update key here
            }
        }
        
        if !searchText.isEmpty {
            result = result.filter { client in
                client.firstName.localizedCaseInsensitiveContains(searchText) ||
                client.lastName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        filteredItems = result
    }
}

extension ClientListViewModel {
    func addClient(_ inspector: ClientModel, completion: @escaping (Error?) -> Void) {

        isLoading = true
        
        clientListRepository.createNewClient(client: inspector) { [weak self] result in
            DispatchQueue.main.async {
                
                self?.isLoading = false
                switch result {
                case .success(let items):
                    print("Success adding tabs: \(items)")
                    completion(nil)
                case .failure(let error):
                    self?.serviceError = error
                    completion(error)
                    print("Error fetching tabs: \(error)")
                }
                
                self?.fetchClientsList()
            }
        }
    }

    func updateClient(_ inspector: ClientModel, completion: @escaping (Error?) -> Void) {

        isLoading = true
        
        clientListRepository.updateClient(client: inspector) { [weak self] result in
            DispatchQueue.main.async {
                
                self?.isLoading = false
                switch result {
                case .success(let items):
                    print("Success adding tabs: \(items)")
                    completion(nil)
                case .failure(let error):
                    self?.serviceError = error
                    completion(error)
                    print("Error fetching tabs: \(error)")
                }
                
                self?.fetchClientsList()
            }
        }
    }
}
