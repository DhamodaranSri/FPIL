//
//  FirebaseTabBarRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import Foundation

final class FirebaseTabBarRepository: TabBarRepositoryProtocol {
    private let service: FirebaseService<TabBarItem>
    private let tempService: FirebaseService<JobDTO>
    
    init() {
        service = FirebaseService<TabBarItem>(collectionName: "TabbarList")
        tempService = FirebaseService<JobDTO>(collectionName: "InspectionJobItems")
    }
    
    func fetchTabs(forUserType userTypeId: Int, completion: @escaping (Result<[TabBarItem], Error>) -> Void) {
        service.fetchByContains(field: "userTypeIds", value: userTypeId, orderBy: "order") { result in
            completion(result)
        }
        
//        JobModel(
//            id: "Job1",
//            inspectorId: "Inspector1",
//            companyName: "Demo Construction Co.",
//            address: "123 Safety Lane",
//            siteId: "SITE-DEMO-001",
//            contactName: "Chief Johnson",
//            phone: "555-FIRE-001",
//            buildingType: 1,
//            buildingName: "Commercial Buildings",
//            isCompleted: false
//        ),
//        JobModel(
//            id: "Job2",
//            inspectorId: "Inspector1",
//            companyName: "Demo Construction Co.",
//            address: "456 Fire Street",
//            siteId: "SITE-DEMO-002",
//            contactName: "Chief Adams",
//            phone: "555-FIRE-002",
//            buildingType: 2,
//            buildingName: "Residential Buildings",
//            isCompleted: false
//        ),
        
//        let newJob = JobDTO(
//            id: "lWFTQHgZ5TJ9AolYMYsS",
//            inspectorId: "insp_123",
//            companyName: "Commercial Constructions Co.",
//            address: "123 Safety Lane",
//            siteId: "SITE-DEMO-001",
//            contactName: "Chief Johnson",
//            phone: "555-FIRE-001",
//            buildingType: 2,
//            buildingName: "Commercial Building",
//            isCompleted: false,
//            lastVist: nil,
//            totalAverageScore: nil,
//            totalVoilations: nil,
//            totalImagesAttached: nil,
//            totalNotesAdded: nil,
//            checkList: nil,
//            jobCreatedDate: Calendar.current.date(byAdding: .day, value: -15, to: Date())!,
//            lastDateToInspection: Calendar.current.date(byAdding: .day, value: 2, to: Date())!
//        )
//        
//        tempService.save(newJob) { result in
//            print(result)
//        }
    }
}
