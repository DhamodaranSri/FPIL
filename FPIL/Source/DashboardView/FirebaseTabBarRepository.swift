//
//  FirebaseTabBarRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import Foundation

final class FirebaseTabBarRepository: TabBarRepositoryProtocol {
    private let service: FirebaseService<TabBarItem>
    
    init() {
        service = FirebaseService<TabBarItem>(collectionName: "TabbarList")
    }
    
    func fetchTabs(forUserType userTypeId: Int, completion: @escaping (Result<[TabBarItem], Error>) -> Void) {
        service.fetchByContains(field: "userTypeIds", value: userTypeId, orderBy: "order") { result in
            completion(result)
        }
    }
}
