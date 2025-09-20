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
    @Published var items: [JobModel] = []  // all sites
    @Published var selectedFilter: String = "All"  // default "All"
    
    private let inspectionRepository: InspectionJobRepositoryProtocol
    
    init(inspectionRepository: InspectionJobRepositoryProtocol = FirebaseInspectionJobRepository()) {
        self.inspectionRepository = inspectionRepository
        fetchInspection(inspectorId: "insp_123")
    }
    
    var filteredItems: [JobModel] {
        if selectedFilter == "All" {
            return items
        } else {
            return items.filter { $0.buildingName == selectedFilter }
        }
    }
    
    func selectFilter(_ filter: String) {
        selectedFilter = filter
    }

    func toggleExpand(for job: JobModel) {
        if let index = items.firstIndex(where: { $0.id == job.id }) {
            items[index].isExpanded = !(items[index].isExpanded ?? false)
        }
    }
    
    func fetchInspection(inspectorId: String) {
        
        let conditions: [(field: String, value: Any)] = [
            ("inspectorId", inspectorId),
            ("isCompleted", false)
        ]
        
        inspectionRepository.fetchInspectionJobs(forConditions: conditions) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.items = items
                case .failure(let error):
                    print("Error fetching tabs: \(error)")
                }
            }

        }
    }
}
