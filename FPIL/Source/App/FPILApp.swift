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
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    var qrGenerator: QRGenerator = QRGenerator()
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        if Auth.auth().currentUser != nil && UserDefaultsStore.profileDetail != nil {
            isLoggedIn = true
            // User is signed in
        } else {
            // No User is Signed in
            isLoggedIn = false
        }
        UIRefreshControl.appearance().tintColor = .gray
        UITextView.appearance().backgroundColor = .clear
        
        let appLaunchRepository = FirebaseAppLaunchRepository()
        appLaunchRepository.fetchBuildings { result in
            if case .success(let buildings) = result {
                UserDefaultsStore.buildings = buildings
            }
        }
        
        appLaunchRepository.fetchBillingFrequency { result in
            if case .success(let buildings) = result {
                UserDefaultsStore.frequency = buildings
            }
        }
        
        appLaunchRepository.fetchClientsType { result in
            if case .success(let clientsType) = result {
                UserDefaultsStore.clientType = clientsType
            }
        }
        
        appLaunchRepository.fetchServicePerformed { result in
            if case .success(let servicePerfomerdTypes) = result {
                UserDefaultsStore.servicesPerfomerdTypes = servicePerfomerdTypes
            }
        }
        
        return true
    }
}

@main
struct FPILApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                switch UserDefaultsStore.profileDetail?.userType {
                case 1: OrganisationListView(viewModel: OrganisationViewModel())
                case 2: DashboardView()
                default: DashboardView()
                }
            } else {
                LoginView()
            }
        }
        .onChange(of: isLoggedIn) { newValue in
            if newValue {
                fetchData() // ✅ call your Firebase data fetch
            }
        }
    }
    
    func fetchData() {
        let appLaunchRepository = FirebaseAppLaunchRepository()
        appLaunchRepository.fetchBuildings { result in
            if case .success(let buildings) = result {
                UserDefaultsStore.buildings = buildings
            }
        }
        
        appLaunchRepository.fetchBillingFrequency { result in
            if case .success(let buildings) = result {
                UserDefaultsStore.frequency = buildings
            }
        }
        
        appLaunchRepository.fetchClientsType { result in
            if case .success(let clientsType) = result {
                UserDefaultsStore.clientType = clientsType
            }
        }
        
        appLaunchRepository.fetchServicePerformed { result in
            if case .success(let servicePerfomerdTypes) = result {
                UserDefaultsStore.servicesPerfomerdTypes = servicePerfomerdTypes
            }
        }
    }
}

func appDelegate() -> AppDelegate {
    guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
        fatalError("could not get app delegate ")
    }
    return delegate
 }
