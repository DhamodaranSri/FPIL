//
//  AuthViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/09/25.
//

import Foundation
import FirebaseAuth
import FirebaseMessaging
import FirebaseCore
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var errorMessage: String? = nil
    @Published var isLoading = false
    private let loginRepository: LoginRepository
    @Published var profile: Profile?
    
    init(loginRepository: LoginRepository = FirebaseLoginRepository()) {
        self.loginRepository = loginRepository
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        isLoading = true
        errorMessage = nil
        
        loginRepository.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                
                self?.isLoading = false
                switch result {
                case .success(let items):
                    if !items.isEmpty {
                        UserDefaultsStore.profileDetail = items.first
                        self?.profile = items.first
                        completion(true, nil)
                        return
                    }
                    do {
                        self?.removeDeviceTokenOnLogout()
                        try Auth.auth().signOut()
                    } catch {
                    }
                    let customeError = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found / Already Deavtivated"]) as Error
                    self?.errorMessage = customeError.localizedDescription
                    completion(false, customeError)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false, error)
                }

            }
        }
    }
    
    func removeDeviceTokenOnLogout() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let token = Messaging.messaging().fcmToken else { return }
        guard let profileId = UserDefaultsStore.profileDetail?.id else { return }

        let ref = Firestore.firestore()
            .collection("users")
            .document(profileId)

        ref.updateData([
            "deviceTokens": FieldValue.arrayRemove([token])
        ])
    }
}
