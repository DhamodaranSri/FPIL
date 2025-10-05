//
//  FirebaseInspectionJobRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 19/09/25.
//

import Foundation

final class FirebaseInspectionJobRepository: InspectionJobRepositoryProtocol {
    private let inspectionService: FirebaseService<JobModel>
    
    init() {
        inspectionService = FirebaseService<JobModel>(collectionName: "SiteInspectionsItems")
    }
    
    func fetchAllInspectionJobs(
        completion: @escaping (Result<[JobModel], any Error>) -> Void
    ) {
        if NetworkMonitor.shared.isConnected {
            inspectionService.fetchAllData { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }

    func fetchInspectionJobs(
        forConditions conditions: [(field: String, value: Any)],
        completion: @escaping (Result<[JobModel], any Error>) -> Void
    ) {
        if NetworkMonitor.shared.isConnected {
            inspectionService.fetchByMultipleWhere(conditions: conditions, orderBy: "") { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }

    func createOrupdateInspection(job: JobModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            inspectionService.save(job) { newDataResult in
                completion(newDataResult)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
}
