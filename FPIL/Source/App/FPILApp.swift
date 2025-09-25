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
            AppProvider.shared.isSignnedIn = true
            // User is signed in
        } else {
            // No User is Signed in
            AppProvider.shared.isSignnedIn = false
        }
        UIRefreshControl.appearance().tintColor = .gray
        return true
    }
}

@main
struct FPILApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if AppProvider.shared.isSignnedIn {
                switch UserDefaultsStore.profileDetail?.userType {
                case 1: OrganisationListView(viewModel: OrganisationViewModel())
                case 2: DashboardView()
                default: DashboardView()
                }
            } else {
                LoginView()
            }
        }
    }
}
