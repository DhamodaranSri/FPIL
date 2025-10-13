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
    @Published var selectedItem: JobModel? {
        didSet {
            getCheckListFromSelectedItem()
        }
    }
    @Published var checkList: CheckList? = nil
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
        let conditions: [(field: String, value: Any)] = [
            ("stationId", UserDefaultsStore.fireStationDetail?.id ?? ""),
            ("isCompleted", false)
        ]
        isLoading = true
        inspectionRepository.fetchAllInspectionJobs(forConditions: conditions) { [weak self] result in
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
            ("inspectorId", inspectorId)
        ]

        isLoading = true
        inspectionRepository.fetchInspectionJobs(forConditions: conditions) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.items = items
                    UserDefaultsStore.jobStartedDate = self?.items.filter({$0.jobStartDate != nil && $0.isCompleted == false }).first?.jobStartDate
                    UserDefaultsStore.startedJobDetail = self?.items.filter({$0.jobStartDate != nil && $0.isCompleted == false }).first
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
    
    func getCheckListFromSelectedItem() {
        checkList = selectedItem?.building.checkLists.first
    }
    
    func totalSelected() -> Int {
        checkList?
            .questions
            .flatMap { $0.answers }
            .count { $0.isSelected == true } ?? 0
    }
    
    func totalQuestions() -> Int {
        checkList?
            .questions
            .flatMap { $0.answers }
            .count ?? 0
    }

    func totalViolations() -> Int {
        checkList?
            .questions
            .flatMap { $0.answers }
            .count { $0.isVoilated == true } ?? 0
    }

    func totalNotesAdded() -> Int {
        checkList?
            .questions
            .flatMap { $0.answers }
            .count { $0.voilationDescription != nil && ($0.voilationDescription?.count ?? 0) > 0} ?? 0
    }
}

extension JobListViewModel {
    func addOrUpdateInspection(_ job: JobModel, completion: @escaping (Error?) -> Void) {
        
        var includeQRonJob = job

        isLoading = true
        if let siteId = job.id {
            let image = QRGenerator().generateQRCode(from: siteId)
            FirebaseFileManager.shared.uploadImage(image,folder: "\(siteId)/SiteQRImage", fileName: siteId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        includeQRonJob.siteQRCodeImageUrl = url
                        self.inspectionRepository.createOrupdateInspection(job: includeQRonJob) { [weak self] result in
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
                        print("Uploaded image URL: \(url)")
                    case .failure(let error):
                        self.isLoading = false
                        self.serviceError = error
                        completion(error)
                        print("Upload failed: \(error.localizedDescription)")
                    }
                    
                }
            }
        }
    }
    
    func updateStartOrStopInspectionDate(jobModel: JobModel, updatedItems: [String: Any], completion: @escaping (Error?) -> Void) {
        isLoading = true
        inspectionRepository.startInspection(jobItem: jobModel, updatedItems: updatedItems) { [weak self] result in
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
