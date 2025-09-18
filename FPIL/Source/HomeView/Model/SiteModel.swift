//
//  SiteModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 18/09/25.
//

import Foundation

// MARK: - Model
struct Site: Identifiable {
    let id = UUID()
    let companyName: String
    let address: String
    let siteId: String
    let contactName: String
    let phone: String
    var isExpanded: Bool = false
    let buildingType:Int
    let buildingTyname: String
    var isCompleted: Bool = false
    var lastVist: [LastVisit]? = nil
    
}

struct LastVisit: Codable {
    let inspectorId: String
    let inspectorName: String
    let visitDate: String
    let cycleId: String
    let cycleName: String
    let totalScore: Int
    let buildType: Int
    let buildTypeName: String
    let totalSpentTime: Int
    let totalVoilations: Int
}
