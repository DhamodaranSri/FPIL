//
//  JobListViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 18/09/25.
//

import Foundation

// MARK: - ViewModel
@MainActor
class JobListViewModel: ObservableObject {
    @Published var selectedItem: JobModel?
    @Published var items: [JobModel] = []  // all sites
    @Published var filteredItems: [JobModel] = []
    @Published var serviceError: Error? = nil
    @Published var isLoading: Bool = false
    @Published var selectedFilter: String = "All" {
        didSet {
            tabFilterItems()
        }
    }
    @Published var searchText: String = "" {
        didSet {
            filterItems()
        }
    }

    private let inspectionRepository: InspectionJobRepositoryProtocol
    
    init(inspectionRepository: InspectionJobRepositoryProtocol = FirebaseInspectionJobRepository()) {
        self.inspectionRepository = inspectionRepository
        if (UserDefaultsStore.profileDetail?.userType == 2) {
            fetchAllInspections()
        } else {
            fetchInspection(inspectorId: UserDefaultsStore.profileDetail?.id ?? "")
        }
        
    }

    func refreshOrganisations() async {
        // Simulate async refresh (API call etc.)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 sec delay
        if (UserDefaultsStore.profileDetail?.userType == 2) {
            fetchAllInspections()
        } else {
            fetchInspection(inspectorId: UserDefaultsStore.profileDetail?.id ?? "")
        }
    }

    private func filterItems() {
        if searchText.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items.filter { ins in
                guard let siteId = ins.id else { return false }
                return siteId.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func tabFilterItems() {
        if selectedFilter == "All" {
            filteredItems = items
        } else {
            filteredItems = items.filter { $0.building.buildingName == selectedFilter }
        }
    }

    func selectFilter(_ filter: String) {
        selectedFilter = filter
    }

    func toggleExpand(for job: JobModel) {
        if let index = items.firstIndex(where: { $0.id == job.id }) {
            items[index].isExpanded = !(items[index].isExpanded ?? false)
            if (UserDefaultsStore.profileDetail?.userType == 2) {
                self.tabFilterItems()
            } else {
                self.filterItems()
            }
        }
    }
    
    func fetchAllInspections() {
        isLoading = true
        inspectionRepository.fetchAllInspectionJobs { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.items = items
                case .failure(let error):
                    self?.serviceError = error
                    print("Error fetching tabs: \(error)")
                }
                if (UserDefaultsStore.profileDetail?.userType == 2) {
                    self?.tabFilterItems()
                } else {
                    self?.filterItems()
                }
            }
        }
    }

    func fetchInspection(inspectorId: String) {

        let conditions: [(field: String, value: Any)] = [
            ("inspectorId", inspectorId),
            ("isCompleted", false)
        ]

        isLoading = true
        inspectionRepository.fetchInspectionJobs(forConditions: conditions) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.items = items
                case .failure(let error):
                    self?.serviceError = error
                    print("Error fetching tabs: \(error)")
                }
                if (UserDefaultsStore.profileDetail?.userType == 2) {
                    self?.tabFilterItems()
                } else {
                    self?.filterItems()
                }
            }

        }
    }
}

extension JobListViewModel {
    func addOrUpdateInspection(_ job: JobModel, completion: @escaping (Error?) -> Void) {

        isLoading = true
        
        inspectionRepository.createOrupdateInspection(job: job) { [weak self] result in
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
                if (UserDefaultsStore.profileDetail?.userType == 2) {
                    self?.fetchAllInspections()
                } else {
                    self?.fetchInspection(inspectorId: UserDefaultsStore.profileDetail?.id ?? "")
                }
            }
        }
    }
}
