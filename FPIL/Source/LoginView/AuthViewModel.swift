//
//  AuthViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/09/25.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading = false
    
    init() {
        self.user = Auth.auth().currentUser
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        isLoading = true
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false, error)
                } else {
                    self?.user = result?.user
                    completion(true, nil)
                }
            }
        }
    }
}
