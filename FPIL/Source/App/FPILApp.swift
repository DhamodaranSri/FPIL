//
//  FPILApp.swift
//  FPIL
//
//  Created by OrganicFarmers on 11/08/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        if Auth.auth().currentUser != nil {
//            signOut()
            AppProvider.shared.isSignnedIn = true
            // User is signed in
        } else {
            // No User is Signed in
            AppProvider.shared.isSignnedIn = false
        }        
        return true
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
        }
    }
}

@main
struct FPILApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if AppProvider.shared.isSignnedIn {
                DashboardView()
            } else {
                LoginView()
            }
        }
    }
}
