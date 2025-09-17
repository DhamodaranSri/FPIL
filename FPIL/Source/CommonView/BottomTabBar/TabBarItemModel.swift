//
//  TabBarItemModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import Foundation

// MARK: - Tab Model
struct TabBarItem: Codable, Hashable, Identifiable {
    var id: String? = UUID().uuidString
    let name: String
    let iconName: String
    let userType: [UserType]
    let userTypeIds: [Int]
}

struct UserType: Codable, Hashable, Identifiable {
    let id: Int
    let type: String
    
}
