//
//  DashboardViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import Foundation
import Combine

final class DashboardViewModel: ObservableObject {
    @Published var tabs: [TabBarItem] = []
    @Published var selectedTab: TabBarItem?
    @Published var isLoading = false
    
    private let repository: TabBarRepositoryProtocol
    
    init(repository: TabBarRepositoryProtocol = FirebaseTabBarRepository()) {
        self.repository = repository
        fetchTabs(forUserType: 0) // Example: userTypeId = 0
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
                    print("Error fetching tabs: \(error)")
                }
            }
        }
    }
    
    func selectTab(_ tab: TabBarItem) {
        selectedTab = tab
    }
}
