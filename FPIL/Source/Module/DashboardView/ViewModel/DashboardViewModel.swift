//
//  DashboardViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import Foundation
import Combine
import SwiftUI

final class DashboardViewModel: ObservableObject {
    @Published var tabs: [TabBarItem] = []
    @Published var selectedTab: TabBarItem?
    @Published var isLoading = false
    @Published var serviceError: Error? = nil
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    private let repository: TabBarRepositoryProtocol
    
    init(repository: TabBarRepositoryProtocol = FirebaseTabBarRepository()) {
        self.repository = repository
        fetchTabs(forUserType: UserDefaultsStore.profileDetail?.userType ?? 2)
        if (UserDefaultsStore.profileDetail?.userType ?? 2) == 2 {
            fetchFireStation(stationId: UserDefaultsStore.profileDetail?.parentId ?? "")
        }
    }
    
    func fetchTabs(forUserType userTypeId: Int) {
        isLoading = true
        repository.fetchTabs(forUserType: userTypeId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.tabs = items
                    self?.selectedTab = items.first
                case .failure(let error):
                    self?.serviceError = error
                    print("Error fetching tabs: \(error)")
                }
            }
        }
    }
    
    func fetchFireStation(stationId: String) {
        isLoading = true
        
        repository.fetchFireStation(stationId: stationId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let station):
                    if station.count > 0 {
                        UserDefaultsStore.fireStationDetail = station.first
                    }
                case .failure(let error):
                    self?.serviceError = error
                }
            }
        }
    }
    
    func selectTab(_ tab: TabBarItem) {
        selectedTab = tab
    }
    
    func signout() {
        isLoading = true
        
        repository.userSignOut { [weak self] result in
            DispatchQueue.main.async {

                self?.isLoading = false
                switch result {
                case .success():
                    UserDefaultsStore.clearData()
                    self?.isLoggedIn = false
                case .failure(let error):
                    self?.serviceError = error
                    print("Error fetching tabs: \(error)")
                }
            }
        }
    }
}
