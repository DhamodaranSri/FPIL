//
//  JobListViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 18/09/25.
//

import Foundation
import UIKit

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
    private var isHistoryLoaded: Bool = false
    
    init(inspectionRepository: InspectionJobRepositoryProtocol = FirebaseInspectionJobRepository(), isHistoryLoaded: Bool = false) {
        self.inspectionRepository = inspectionRepository
        self.isHistoryLoaded = isHistoryLoaded
        if isHistoryLoaded {
            fetchAllInspections()
        } else {
            if (UserDefaultsStore.profileDetail?.userType == 2) {
                fetchAllInspections()
            } else {
                fetchInspection(inspectorId: UserDefaultsStore.profileDetail?.id ?? "")
            }
        }
    }

    func refreshOrganisations() async {
        // Simulate async refresh (API call etc.)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 sec delay
        if isHistoryLoaded {
            fetchAllInspections()
        } else {
            if (UserDefaultsStore.profileDetail?.userType == 2) {
                fetchAllInspections()
            } else {
                fetchInspection(inspectorId: UserDefaultsStore.profileDetail?.id ?? "")
            }
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
        var conditions: [(field: String, value: Any)] = []
        if isHistoryLoaded {
            if (UserDefaultsStore.profileDetail?.userType == 2) {
                conditions = [
                    ("stationId", UserDefaultsStore.fireStationDetail?.id ?? ""),
                    ("isCompleted", true)
                ]
            } else {
                conditions = [
                    ("inspectorId", UserDefaultsStore.profileDetail?.id ?? ""),
                    ("isCompleted", true)
                ]
            }
        } else {
            conditions = [
                ("stationId", UserDefaultsStore.fireStationDetail?.id ?? ""),
                ("isCompleted", false)
            ]
        }

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
                if let history = self?.isHistoryLoaded, history {
                    self?.filterItems()
                } else {
                    if (UserDefaultsStore.profileDetail?.userType == 2) {
                        self?.tabFilterItems()
                    } else {
                        self?.filterItems()
                    }
                }
            }
        }
    }

    func fetchInspection(inspectorId: String) {

        let conditions: [(field: String, value: Any)] = [
            ("inspectorId", inspectorId)
        ]

        isLoading = true
        inspectionRepository.fetchAllInspectionJobsForInspector(forConditions: inspectorId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.items = items
                    UserDefaultsStore.jobStartedDate = self?.items.filter({$0.jobStartDate != nil && $0.isCompleted == false }).first?.jobStartDate
                    if UserDefaultsStore.startedJobDetail == nil {
                        UserDefaultsStore.startedJobDetail = self?.items.filter({$0.jobStartDate != nil && $0.isCompleted == false }).first
                    }
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
        /*
        inspectionRepository.fetchInspectionJobs(forConditions: conditions, orderBy: "jobAssignedDate") { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.items = items
                    UserDefaultsStore.jobStartedDate = self?.items.filter({$0.jobStartDate != nil && $0.isCompleted == false }).first?.jobStartDate
                    if UserDefaultsStore.startedJobDetail == nil {
                        UserDefaultsStore.startedJobDetail = self?.items.filter({$0.jobStartDate != nil && $0.isCompleted == false }).first
                    }
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
        */
    }
    
    func getCheckListFromSelectedItem() {
        if UserDefaultsStore.startedJobDetail != nil {
            checkList = UserDefaultsStore.startedJobDetail?.building.checkLists.first
        } else {
            checkList = selectedItem?.building.checkLists.first
        }
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
    
    func uploadReviewReport(url: URL, completion: @escaping (Error?, String?) -> Void) {
        if NetworkMonitor.shared.isConnected {
            
            isLoading = true
                        
            FirebaseFileManager.shared.uploadFile(at: url, folder: "\(selectedItem?.id ?? "Inspection Reports")/review_report/") { result in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let url):
                        completion(nil, url)
                        print("Uploaded image URL: \(url)")
                    case .failure(let error):
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
    
    func deleteUploadedImage(url: String, completion: @escaping (Error?, Bool) -> Void) {
        if NetworkMonitor.shared.isConnected {
            
            isLoading = true
            
            FirebaseFileManager.shared.deleteImageFromFirebase(urlString: url) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
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
    
    func uploadInspectionPhotoToFirebase(image: UIImage, job: JobModel?, completion: @escaping (Error?, String?) -> Void) {
        
        if NetworkMonitor.shared.isConnected {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
            
            isLoading = true
            
            if let siteId = job?.id, let compressedImage = UIImage(data: imageData) {
                
                FirebaseFileManager.shared.uploadImage(compressedImage,folder: "\(siteId)/inspection_photos", fileName: (UUID().uuidString)) { result in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        switch result {
                        case .success(let url):
                            completion(nil, url)
                            print("Uploaded image URL: \(url)")
                        case .failure(let error):
                            self.serviceError = error
                            completion(error, nil)
                            print("Upload failed: \(error.localizedDescription)")
                        }
                        
                    }
                }
                
            }
        } else {
            completion(NSError(domain: "Internet Connection Error", code: 92001), nil)
        }
    }
    
    func addOrUpdateInspection(_ job: JobModel, isInvoiceGenerate: Bool, completion: @escaping (Error?) -> Void) {
//        guard NetworkMonitor.shared.isConnected else {
//            completion(NSError(domain: "Internet Connection Error", code: 92001))
//            return
//        }
        
        guard let siteId = job.id else {
            completion(NSError(domain: "Missing siteId", code: 92002))
            return
        }
        
        isLoading = true
        var updatedJob = job
        
        // Step 1: Generate and upload QR
        let qrImage = QRGenerator().generateQRCode(from: siteId)
        FirebaseFileManager.shared.uploadImage(qrImage, folder: "\(siteId)/SiteQRImage", fileName: siteId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let url):
                    updatedJob.siteQRCodeImageUrl = url
                    print("Uploaded QR image URL: \(url)")
                    
                    // Step 2: Generate invoice if needed, then update inspection
                    if isInvoiceGenerate {
                        if job.invoiceDetails == nil {
                            self.generateInvoiceAndUpdateInspection(for: updatedJob, completion: completion)
                        } else {
                            self.updateInspectionAndRefresh(for: updatedJob, completion: completion)
                        }
                    } else {
                        self.updateInspectionAndRefresh(for: updatedJob, completion: completion)
                    }
                    
                case .failure(let error):
                    self.isLoading = false
                    self.serviceError = error
                    completion(error)
                    print("QR Upload failed: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Private helpers
    private func generateInvoiceAndUpdateInspection(for job: JobModel, completion: @escaping (Error?) -> Void) {
        let invoiceVM = InvoiceViewModel(
            items: UserDefaultsStore.servicesPerfomerdTypes ?? [],
            client: job.client,
            jobModel: job
        )
        
        invoiceVM.generateInvoice(building: job.building) { [weak self] invoice, error  in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.serviceError = error
                    completion(error)
                    return
                }
                var jobModel = job
                if jobModel.invoiceDetails == nil {
                    jobModel.invoiceDetails = [invoice]
                } else {
                    jobModel.invoiceDetails?.append(invoice)
                }
                self.updateInspectionAndRefresh(for: jobModel, completion: completion)
            }
        }
    }

    private func updateInspectionAndRefresh(for job: JobModel, completion: @escaping (Error?) -> Void) {
        inspectionRepository.createOrupdateInspection(job: job) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let items):
                    print("Inspection updated successfully: \(items)")
                    completion(nil)
                case .failure(let error):
                    self.serviceError = error
                    completion(error)
                    print("Error updating inspection: \(error)")
                }
                
                // Refresh inspections based on user type
                if UserDefaultsStore.profileDetail?.userType == 2 {
                    self.fetchAllInspections()
                } else {
                    self.fetchInspection(inspectorId: UserDefaultsStore.profileDetail?.id ?? "")
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
