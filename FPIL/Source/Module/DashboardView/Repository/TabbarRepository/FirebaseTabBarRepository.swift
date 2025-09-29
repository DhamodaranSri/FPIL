//
//  FirebaseTabBarRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import Foundation

final class FirebaseTabBarRepository: TabBarRepositoryProtocol {
    private let service: FirebaseService<TabBarItem>
    private let fireAuthService: FirebaseAuthService
    private let fireStationService: FirebaseService<OrganisationModel>
    
    init() {
        fireAuthService = FirebaseAuthService()
        service = FirebaseService<TabBarItem>(collectionName: "TabbarList")
        fireStationService = FirebaseService<OrganisationModel>(collectionName: "FirestationsList")
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

    func fetchFireStation(stationId: String, completion: @escaping (Result<[OrganisationModel], Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireStationService.fetchBy(field: "id", value: stationId) { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
}
