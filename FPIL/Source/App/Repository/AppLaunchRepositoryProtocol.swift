//
//  AppLaunchRepositoryProtocol.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/10/25.
//

import Foundation

protocol AppLaunchRepositoryProtocol {
    func fetchBillingFrequency(completion: @escaping (Result<[InspectionFrequency], Error>) -> Void)
    func fetchEmployeeDesignation(completion: @escaping (Result<[FireStationEmployeeJobDesignations], Error>) -> Void)
    func fetchBuildings(completion: @escaping (Result<[Building], Error>) -> Void)
}
