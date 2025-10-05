//
//  FirebaseInspectorsListRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 27/09/25.
//

import Foundation

final class FirebaseInspectorsListRepository: InspectorsListRepositoryProtocol {

    private let fireService: FirebaseService<FireStationInspectorModel>
    private let profileService: FirebaseService<Profile>
    private let fireAuthService: FirebaseAuthService
    
    init() {
        fireService = FirebaseService<FireStationInspectorModel>(collectionName: "InspectorsList")
        fireAuthService = FirebaseAuthService()
        profileService = FirebaseService<Profile>(collectionName: "Profiles")
    }
    
    func fetchAllInspectorsList(stationId: String, completion: @escaping (Result<[FireStationInspectorModel], Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireService.fetchBy(field: "parentId", value: stationId) { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
    
    func updateInspector(inspector: FireStationInspectorModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireService.save(inspector) { newDataResult in
                if case .failure(let failure) = newDataResult {
                    completion(.failure(failure))
                    return
                }
                
                let profile = Profile(
                    id: inspector.id,
                    firstName: inspector.firstName,
                    lastName: inspector.lastName,
                    email: inspector.email,
                    contactNumber: inspector.contactNumber,
                    address: inspector.address,
                    street: inspector.street,
                    city: inspector.city,
                    zipcode: inspector.zipCode,
                    userType: inspector.position.userTypeId,
                    status: inspector.status,
                    parentId: inspector.parentId,
                    stationCode: inspector.stationCode
                )
                
                self.profileService.save(profile) { profileResult in
                    
                    if case .failure(let failure) = profileResult {
                        completion(.failure(failure))
                        return
                    }
                    completion(newDataResult)
                }
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
    
    func createNewInspector(inspector: FireStationInspectorModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireAuthService.createUser(email: inspector.email) { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                    return
                }
                self.fireService.save(inspector) { newDataResult in
                    if case .failure(let failure) = newDataResult {
                        completion(.failure(failure))
                        return
                    }
                    
                    let newProfile = Profile(
                        id:inspector.id,
                        firstName: inspector.firstName,
                        lastName: inspector.lastName,
                        email: inspector.email,
                        contactNumber: inspector.contactNumber,
                        address: inspector.address,
                        street: inspector.street,
                        city: inspector.city,
                        zipcode: inspector.zipCode,
                        userType: inspector.position.userTypeId,
                        status: inspector.status,
                        parentId: inspector.parentId,
                        stationCode: inspector.stationCode
                    )
                    
                    self.profileService.save(newProfile) { newProfileResult in
                        
                        if case .failure(let failure) = newProfileResult {
                            completion(.failure(failure))
                            return
                        }
                        completion(newDataResult)
                    }
                }
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
}
