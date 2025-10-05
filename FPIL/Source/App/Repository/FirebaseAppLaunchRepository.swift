//
//  FirebaseAppLaunchRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/10/25.
//

import Foundation

final class FirebaseAppLaunchRepository: AppLaunchRepositoryProtocol {
    
    private let billingService: FirebaseService<InspectionFrequency>
    private let employeeService: FirebaseService<FireStationEmployeeJobDesignations>
    private let buildingService: FirebaseService<Building>
    private let checklistService: FirebaseService<CheckList>
    
    init() {
        billingService = FirebaseService<InspectionFrequency>(collectionName: "Frequency")
        employeeService = FirebaseService<FireStationEmployeeJobDesignations>(collectionName: "FireStationEmployeeJobDesignations")
        buildingService = FirebaseService<Building>(collectionName: "Buildings")
        checklistService = FirebaseService<CheckList>(collectionName: "CheckLists")
    }
    
    func fetchBillingFrequency(completion: @escaping (Result<[InspectionFrequency], Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            billingService.fetchAllData { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
    
    func fetchEmployeeDesignation(completion: @escaping (Result<[FireStationEmployeeJobDesignations], Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            employeeService.fetchAllData { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
    
    func fetchBuildings(completion: @escaping (Result<[Building], Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            buildingService.fetchAllData { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
}
