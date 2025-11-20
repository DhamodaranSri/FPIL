//
//  FirebaseInspectionJobRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 19/09/25.
//

import Foundation

final class FirebaseInspectionJobRepository: InspectionJobRepositoryProtocol {
    private let inspectionService: FirebaseService<JobModel>
    private let clientService: FirebaseService<ClientModel>
    
    init() {
        inspectionService = FirebaseService<JobModel>(collectionName: "SiteInspectionsItems")
        clientService = FirebaseService<ClientModel>(collectionName: "ClientList")
    }
    
    func fetchAllInspectionJobs(
        forConditions conditions: [(field: String, value: Any)],
        completion: @escaping (Result<[JobModel], any Error>) -> Void
    ) {
        if NetworkMonitor.shared.isConnected {
            inspectionService.fetchByMultipleWhere(conditions: conditions, orderBy: "") { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }

    func fetchInspectionJobs(
        forConditions conditions: [(field: String, value: Any)],
        orderBy: String,
        completion: @escaping (Result<[JobModel], any Error>) -> Void
    ) {
        if NetworkMonitor.shared.isConnected {
            inspectionService.fetchByMultipleWhere(conditions: conditions, orderBy: orderBy) { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
    
    func fetchAllInspectionJobsForInspector(
        forConditions inspectorId: String,
        completion: @escaping (Result<[JobModel], any Error>) -> Void
    ) {
        if NetworkMonitor.shared.isConnected {
            inspectionService.fetchByMultipleWhereAndMultipleFilterForSiteInspector(inspectorId: inspectorId, orderBy: "jobAssignedDate") { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }

    func createOrupdateInspection(job: JobModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            inspectionService.save(job) { newDataResult in
                completion(newDataResult)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }

    func startInspection(jobItem: JobModel, updatedItems: [String: Any], completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            inspectionService.siteUpdate(jobItem, items: updatedItems) { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
    
    func createOrupdateClient(client: ClientModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            clientService.save(client) { newDataResult in
                completion(newDataResult)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
    
    func updateClient(client: ClientModel, updatedItems: [String: Any], completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            clientService.siteUpdate(client, items: updatedItems) { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
    
    func fetchClient(clientId: String, completion: @escaping (Result<ClientModel, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            clientService.fetch(byId: clientId) { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
}
