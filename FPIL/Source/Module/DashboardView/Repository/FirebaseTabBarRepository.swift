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
    private let fireAuthService: FirebaseAuthService
    
    init() {
        fireAuthService = FirebaseAuthService()
        service = FirebaseService<TabBarItem>(collectionName: "TabbarList")
        tempService = FirebaseService<JobDTO>(collectionName: "InspectionJobItems")
    }
    
    func fetchTabs(forUserType userTypeId: Int, completion: @escaping (Result<[TabBarItem], Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            service.fetchByContains(field: "userTypeIds", value: userTypeId, orderBy: "order") { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
    
    
    func userSignOut(completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireAuthService.signOut { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
}
