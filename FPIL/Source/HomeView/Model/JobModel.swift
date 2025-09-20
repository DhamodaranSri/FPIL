//
//  SiteModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 18/09/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Model

struct JobDTO: Codable, Identifiable {
    var id: String?  // Firestore auto doc ID
    var inspectorId: String
    var companyName: String
    var address: String
    var siteId: String
    var contactName: String
    var phone: String
    var buildingType: Int
    var buildingName: String
    var isCompleted: Bool
    var lastVist: [LastVisit]?
    var totalAverageScore: Int?
    var totalVoilations: Int?
    var totalImagesAttached: Int?
    var totalNotesAdded: Int?
    var checkList: CheckList?
    var jobCreatedDate: Date?
    var lastDateToInspection: Date?
}

// UI Model
struct JobModel: Codable, Identifiable {
    var id: String?
    var inspectorId: String
    let companyName: String
    let address: String
    let siteId: String
    let contactName: String
    let phone: String
    let buildingType: Int
    let buildingName: String
    var isCompleted: Bool
    var lastVist: [LastVisit]?
    var totalAverageScore: Int?
    var totalVoilations: Int?
    var totalImagesAttached: Int?
    var totalNotesAdded: Int?
    var checkList: CheckList?
    var jobCreatedDate: Date?
    var lastDateToInspection: Date?
    
    // Local only (UI state)
    var isExpanded: Bool? = false
}

// Convert DTO → Model
extension JobModel {
    init(dto: JobDTO) {
        self.id = dto.id ?? ""
        self.inspectorId = dto.inspectorId
        self.companyName = dto.companyName
        self.address = dto.address
        self.siteId = dto.siteId
        self.contactName = dto.contactName
        self.phone = dto.phone
        self.buildingType = dto.buildingType
        self.buildingName = dto.buildingName
        self.isCompleted = dto.isCompleted
        self.lastVist = dto.lastVist
        self.totalAverageScore = dto.totalAverageScore
        self.totalVoilations = dto.totalVoilations
        self.totalImagesAttached = dto.totalImagesAttached
        self.totalNotesAdded = dto.totalNotesAdded
        self.checkList = dto.checkList
        self.jobCreatedDate = dto.jobCreatedDate
        self.lastDateToInspection = dto.lastDateToInspection
    }
}

//struct JobModel: Identifiable {
//    var id: String = ""
//    var inspector4Id: String = ""
//    let companyName: String
//    let address: String
//    let siteId: String
//    let contactName: String
//    let phone: String
//    var isExpanded: Bool = false
//    let buildingType:Int
//    let buildingTyname: String
//    var isCompleted: Bool = false
//    var lastVist: [LastVisit]? = nil
//    var totalAverageScore: Int? = nil
//    var totalVoilations: Int? = nil
//    var totalImagesAttached: Int? = nil
//    var totalNotesAdded: Int? = nil
//    var checkList: CheckList? = nil
//}

struct LastVisit: Codable, Identifiable {
    var id: String? = UUID().uuidString
    let inspectorId: String
    let inspectorName: String
    let visitDate: Date
    let cycleId: Int
    let cycleName: String
    let totalScore: Int
    let buildType: Int
    let buildTypeName: String
    let totalSpentTime: Int
    let totalVoilations: Int
}

struct CheckList: Codable {
    let checkListId: String
    let checkListName: String
}
