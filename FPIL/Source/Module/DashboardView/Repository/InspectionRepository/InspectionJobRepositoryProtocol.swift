//
//  InspectionJobRepositoryProtocol.swift
//  FPIL
//
//  Created by OrganicFarmers on 19/09/25.
//

import Foundation

import Foundation

protocol InspectionJobRepositoryProtocol {
    func fetchInspectionJobs(forConditions conditions: [(field: String, value: Any)], orderBy: String, completion: @escaping (Result<[JobModel], Error>) -> Void)
    func createOrupdateInspection(job: JobModel, completion: @escaping (Result<Void, any Error>) -> Void)
    func fetchAllInspectionJobs(
        forConditions conditions: [(field: String, value: Any)],
        completion: @escaping (Result<[JobModel], any Error>) -> Void
    )
    func startInspection(jobItem: JobModel, updatedItems: [String: Any], completion: @escaping (Result<Void, any Error>) -> Void)
}
