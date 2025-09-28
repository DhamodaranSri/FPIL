//
//  TabBarRepositoryProtocol.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import Foundation

protocol TabBarRepositoryProtocol {
    func fetchTabs(forUserType userTypeId: Int, completion: @escaping (Result<[TabBarItem], Error>) -> Void)
    func userSignOut(completion: @escaping (Result<Void, any Error>) -> Void)
    func fetchFireStation(stationId: String, completion: @escaping (Result<[OrganisationModel], Error>) -> Void)
}
