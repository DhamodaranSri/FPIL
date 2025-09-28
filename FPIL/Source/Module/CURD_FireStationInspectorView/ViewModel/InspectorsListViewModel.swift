//
//  InspectorsListViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 27/09/25.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
@MainActor
class InspectorsListViewModel: ObservableObject {
    @Published var items: [FireStationInspectorModel] = []
    @Published var selectedItem: FireStationInspectorModel?
    private let inspectorListRepository: InspectorsListRepositoryProtocol
    
    @Published var searchText: String = "" {
        didSet {
            filterItems()
        }
    }
    
    @Published private(set) var filteredItems: [FireStationInspectorModel] = []
    @Published var serviceError: Error? = nil
    @Published var isLoading: Bool = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    init(inspectorListRepository: InspectorsListRepositoryProtocol = FirebaseInspectorsListRepository()) {
        self.inspectorListRepository = inspectorListRepository
        fetchInspectorsList()
    }
    
    func fetchInspectorsList() {
        isLoading = true

        inspectorListRepository.fetchAllInspectorsList(stationId: UserDefaultsStore.profileDetail?.parentId ?? "") {  [weak self] result in
            DispatchQueue.main.async {
                
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.items = items
                case .failure(let error):
                    self?.serviceError = error
                    print("Error fetching tabs: \(error)")
                }
                
                self?.filterItems()
            }
        }

    }
    
    func refreshInspectorsList() async {
        // Simulate async refresh (API call etc.)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 sec delay
        fetchInspectorsList()
    }

    private func filterItems() {
        if searchText.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items.filter { ins in
                ins.firstName.localizedCaseInsensitiveContains(searchText) ||
                ins.lastName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

extension InspectorsListViewModel {
    func addInspector(_ inspector: FireStationInspectorModel, completion: @escaping (Error?) -> Void) {

        isLoading = true
        
        inspectorListRepository.createNewInspector(inspector: inspector) { [weak self] result in
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
                
                self?.fetchInspectorsList()
            }
        }
    }

    func updateInspector(_ inspector: FireStationInspectorModel, completion: @escaping (Error?) -> Void) {

        isLoading = true
        
        inspectorListRepository.updateInspector(inspector: inspector) { [weak self] result in
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
                
                self?.fetchInspectorsList()
            }
        }
    }
}
