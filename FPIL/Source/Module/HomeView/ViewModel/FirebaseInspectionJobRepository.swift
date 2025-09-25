//
//  FirebaseInspectionJobRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 19/09/25.
//

import Foundation

final class FirebaseInspectionJobRepository: InspectionJobRepositoryProtocol {
    private let service: FirebaseService<JobModel>
    
    init() {
        service = FirebaseService<JobModel>(collectionName: "InspectionJobItems")
    }

    func fetchInspectionJobs(
        forConditions conditions: [(field: String, value: Any)],
        completion: @escaping (Result<[JobModel], any Error>) -> Void
    ) {
        service.fetchByMultipleWhere(conditions: conditions, orderBy: "") { result in
            completion(result)
        }
    }
}
