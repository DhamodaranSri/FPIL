//
//  FirebaseLoginRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 25/09/25.
//

import Foundation
import FirebaseAuth
import FirebaseMessaging
import FirebaseCore
import FirebaseFirestore

final class FirebaseLoginRepository: LoginRepository {
    private let profileService: FirebaseService<Profile>
    private let fireAuthService: FirebaseAuthService
    
    init() {
        fireAuthService = FirebaseAuthService()
        profileService = FirebaseService<Profile>(collectionName: "Profiles")
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<[Profile], any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireAuthService.signIn(email: email, password: password) { [weak self] result in
                if case .failure(let failure) = result {
                    completion(.failure(failure))
                    return
                }
                
                let conditions: [(field: String, value: Any)] = [
                    ("email", email),
                    ("status", 1)
                ]
                
                self?.profileService.fetchByMultipleWhere(conditions: conditions, orderBy: "") { newProfileResult in
                    if case .failure(_) = newProfileResult {
                        completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found / Already Deavtivated"])))
                        return
                    }
                    if let token = Messaging.messaging().fcmToken, case .success(let profileResult) = newProfileResult, profileResult.count > 0 {
                        self?.saveDeviceTokenToFirestore(token: token, profileId: profileResult.first?.id ?? "")
                    }
                    completion(newProfileResult)
                }
            }
            
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
    
    func saveDeviceTokenToFirestore(token: String, profileId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Firestore.firestore().collection("users").document(profileId)
        
        ref.setData([
            "deviceTokens": FieldValue.arrayUnion([token])
        ], merge: true)
    }
    
}
