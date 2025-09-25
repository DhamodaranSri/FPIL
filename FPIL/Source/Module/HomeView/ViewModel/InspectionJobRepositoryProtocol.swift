//
//  InspectionJobRepositoryProtocol.swift
//  FPIL
//
//  Created by OrganicFarmers on 19/09/25.
//

import Foundation

import Foundation

protocol InspectionJobRepositoryProtocol {
    func fetchInspectionJobs(forConditions conditions: [(field: String, value: Any)], completion: @escaping (Result<[JobModel], Error>) -> Void)
}
