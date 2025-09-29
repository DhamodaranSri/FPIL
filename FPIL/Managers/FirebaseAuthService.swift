//
//  FirebaseAuthService.swift
//  FPIL
//
//  Created by OrganicFarmers on 24/09/25.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService {
    
    /// Create a new user with random temporary password
    func createUser(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Generate random temporary password
        let tempPassword = UUID().uuidString.prefix(8).description
        
        Auth.auth().createUser(withEmail: email, password: tempPassword) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Send password reset email
            Auth.auth().sendPasswordReset(withEmail: email) { resetError in
                if let resetError = resetError {
                    completion(.failure(resetError))
                } else {
                    completion(.success(tempPassword))
                }
            }
        }
    }
    
    /// Sign in user
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let user = authResult?.user {
                completion(.success(user))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign in failed"])))
            }
        }
    }
    
    /// Sign out user
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Change password for current user
    func changePassword(newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        user.updatePassword(to: newPassword) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Send password reset email
    func sendPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Private Helper
    private func sendEmailWithTempPassword(to email: String, password: String) {
        // Firebase itself does not send custom emails with password.
        // You need to integrate either:
        // 1. Firebase Extensions (Email Trigger + SendGrid/Mailgun)
        // 2. Or Cloud Function to send via SMTP
        // For now, just log:
        print("Send email to \(email) with temporary password: \(password)")
    }
}
