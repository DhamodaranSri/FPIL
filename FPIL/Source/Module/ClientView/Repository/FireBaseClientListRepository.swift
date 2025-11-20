//
//  FireBaseClientListRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 24/10/25.
//

import Foundation

final class FireBaseClientListRepository: ClientListRepositoryProtocol {

    private let fireService: FirebaseService<ClientModel>
    private let profileService: FirebaseService<Profile>
    private let fireAuthService: FirebaseAuthService
    
    init() {
        fireService = FirebaseService<ClientModel>(collectionName: "ClientList")
        fireAuthService = FirebaseAuthService()
        profileService = FirebaseService<Profile>(collectionName: "Profiles")
    }
    
    func fetchAllClientList(stationId: String, completion: @escaping (Result<[ClientModel], Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireService.fetchBy(field: "stationId", value: stationId) { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
    
    func updateClient(client: ClientModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireService.save(client) { newDataResult in
                if case .failure(let failure) = newDataResult {
                    completion(.failure(failure))
                    return
                }
                
                let profile = Profile(
                    id: client.id,
                    firstName: client.firstName,
                    lastName: client.lastName,
                    email: client.email,
                    contactNumber: client.contactNumber,
                    address: client.address,
                    street: client.street,
                    city: client.city,
                    zipcode: client.zipCode,
                    userType: 5,
                    status: client.status,
                    parentId: client.stationId
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
    
    func createNewClient(client: ClientModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireAuthService.createUser(email: client.email) { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                    return
                }
                self.fireService.save(client) { newDataResult in
                    if case .failure(let failure) = newDataResult {
                        completion(.failure(failure))
                        return
                    }
                    
                    let newProfile = Profile(
                        id: client.id,
                        firstName: client.firstName,
                        lastName: client.lastName,
                        email: client.email,
                        contactNumber: client.contactNumber,
                        address: client.address,
                        street: client.street,
                        city: client.city,
                        zipcode: client.zipCode,
                        userType: 5,
                        status: client.status,
                        parentId: client.stationId
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
