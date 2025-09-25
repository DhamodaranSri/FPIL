//
//  OrganisationViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 22/09/25.
//

import Foundation

// MARK: - ViewModel
@MainActor
class OrganisationViewModel: ObservableObject {
    @Published var items: [OrganisationModel] = []
    @Published var selectedItem: OrganisationModel?
    private let organisationRepository: OrganisationRepositoryProtocol
    
    @Published var searchText: String = "" {
        didSet {
            filterItems()
        }
    }
    
    @Published private(set) var filteredItems: [OrganisationModel] = []
    @Published var serviceError: Error? = nil
    @Published var isLoading: Bool = false
    @Published var isUserSignedOut: Bool = false
    
    init(organisationRepository: OrganisationRepositoryProtocol = FirebaseOrganisationRepository()) {
        self.organisationRepository = organisationRepository
        fetchOrganisationList()
    }

    func toggleExpand(for job: OrganisationModel) {
       
    }
    
    func fetchOrganisationList() {
        isLoading = true

        organisationRepository.fetchAllOranisationList {  [weak self] result in
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
    
    func refreshOrganisations() async {
        // Simulate async refresh (API call etc.)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 sec delay
        fetchOrganisationList()
    }

    private func filterItems() {
        if searchText.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items.filter { org in
                org.firestationName.localizedCaseInsensitiveContains(searchText) ||
                org.firestationCheifFirstName.localizedCaseInsensitiveContains(searchText) ||
                org.firestationCheifLastName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

extension OrganisationViewModel {
    func addOrganisation(_ organisation: OrganisationModel, completion: @escaping (Error?) -> Void) {

        isLoading = true
        
        organisationRepository.createNewFirestation(firestation: organisation) { [weak self] result in
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
                
                self?.fetchOrganisationList()
            }
        }
    }

    func updateOrganisation(_ organisation: OrganisationModel, completion: @escaping (Error?) -> Void) {

        isLoading = true
        
        organisationRepository.updateFirestation(firestation: organisation) { [weak self] result in
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
                
                self?.fetchOrganisationList()
            }
        }
    }
    
    func signout() {
        isLoading = true
        
        organisationRepository.userSignOut { [weak self] result in
            DispatchQueue.main.async {

                self?.isLoading = false
                switch result {
                case .success():
                    AppProvider.shared.profile = nil
                    AppProvider.shared.isSignnedIn = false
                    self?.isUserSignedOut = true
                case .failure(let error):
                    self?.serviceError = error
                }
            }
        }
    }
}
