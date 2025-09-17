//
//  TabBarRepositoryProtocol.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import Foundation

protocol TabBarRepositoryProtocol {
    func fetchTabs(forUserType userTypeId: Int, completion: @escaping (Result<[TabBarItem], Error>) -> Void)
}
