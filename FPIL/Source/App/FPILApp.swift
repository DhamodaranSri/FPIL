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
import FirebaseMessaging

enum UserRole: Int {
    case organisation = 1
    case employee     = 2
    case inspector    = 5
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    var qrGenerator: QRGenerator = QRGenerator()
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        askNotificationPermission()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        if Auth.auth().currentUser != nil && UserDefaultsStore.profileDetail != nil {
            isLoggedIn = true
            // User is signed in
        } else {
            // No User is Signed in
            isLoggedIn = false
        }
        UIRefreshControl.appearance().tintColor = .gray
        UITextView.appearance().backgroundColor = .clear

        return true
    }

    func saveDeviceTokenToFirestore(token: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("deviceTokens")
            .document(token)
            .setData([
                "createdAt": FieldValue.serverTimestamp()
            ], merge: true)
    }

    func askNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token:", fcmToken ?? "none")

//        if let token = fcmToken {
//            saveDeviceTokenToFirestore(token: token)
//        }
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
    }
}

@main
struct FPILApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    switch UserRole(rawValue: UserDefaultsStore.profileDetail?.userType ?? 0) {
                    case .organisation:
                        OrganisationListView(viewModel: OrganisationViewModel())
                    case .employee:
                        DashboardView()
                    case .inspector:
                        InspectionPage()
                    default:
                        DashboardView()
                    }
                } else {
                    LoginView()
                }
            }
            .task(id: isLoggedIn) {
                if isLoggedIn { fetchData() }
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
