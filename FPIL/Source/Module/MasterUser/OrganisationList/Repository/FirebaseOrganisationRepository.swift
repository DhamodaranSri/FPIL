//
//  FirebaseOrganisationRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 23/09/25.
//

import Foundation

final class FirebaseOrganisationRepository: OrganisationRepositoryProtocol {
    private let fireService: FirebaseService<OrganisationModel>
    private let profileService: FirebaseService<Profile>
    private let fireAuthService: FirebaseAuthService
    
    init() {
        fireService = FirebaseService<OrganisationModel>(collectionName: "FirestationsList")
        fireAuthService = FirebaseAuthService()
        profileService = FirebaseService<Profile>(collectionName: "Profiles")
    }
    
    func fetchAllOranisationList(completion: @escaping (Result<[OrganisationModel], any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireService.fetchAllData { result in
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
    
    func updateFirestation(firestation: OrganisationModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireService.save(firestation) { newDataResult in
                if case .failure(let failure) = newDataResult {
                    completion(.failure(failure))
                    return
                }
                
                let profile = Profile(
                    id: firestation.id,
                    firstName: firestation.firestationCheifFirstName,
                    lastName: firestation.firestationCheifLastName,
                    email: firestation.firestationAdminEmail,
                    contactNumber: firestation.firestationCheifContactNumber,
                    address: firestation.firestationAddress,
                    street: firestation.street,
                    city: firestation.city,
                    zipcode: firestation.zipCode,
                    userType: 2,
                    status: firestation.status,
                    parentId: firestation.id,
                    stationCode: firestation.stationCode
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
    
    func createNewFirestation(firestation: OrganisationModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireAuthService.createUser(email: firestation.firestationAdminEmail) { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                    return
                }
                self.fireService.save(firestation) { newDataResult in
                    if case .failure(let failure) = newDataResult {
                        completion(.failure(failure))
                        return
                    }
                    
                    let newProfile = Profile(
                        id:UUID().uuidString,
                        firstName: firestation.firestationCheifFirstName,
                        lastName: firestation.firestationCheifLastName,
                        email: firestation.firestationAdminEmail,
                        contactNumber: firestation.firestationCheifContactNumber,
                        address: firestation.firestationAddress,
                        street: firestation.street,
                        city: firestation.city,
                        zipcode: firestation.zipCode,
                        userType: 2,
                        status: firestation.status,
                        parentId: firestation.id,
                        stationCode: firestation.stationCode
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


struct Profile: Codable, Identifiable {
    var id: String?
    var firstName: String?
    var lastName: String?
    var email: String
    var contactNumber: String
    var address: String
    var street: String
    var city: String
    var zipcode: String
    var userType: Int
    var status: Int
    var parentId: String?
    var stationCode: String?
}
