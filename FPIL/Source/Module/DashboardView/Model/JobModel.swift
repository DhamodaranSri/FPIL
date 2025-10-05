//
//  SiteModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 18/09/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Model
// UI Model
struct JobModel: Codable, Identifiable {
    var id: String?
    var inspectorId: String?
    var inspectorName: String?
    let siteName: String
    let address: String
    let city: String
    let street: String
    let zipCode: String
    let geoLocationAddress: String
    let latitude: Double
    let longitude: Double
    var clientId: String?
    let firstName: String
    let lastName: String
    let phone: String
    let email: String
    let alternateContactNumber: String?
    let building: Building
    let inspectionFrequency: InspectionFrequency
    var isCompleted: Bool
    var lastVist: [LastVisit]?
    var jobCreatedDate: Date
    var createdById: String?
    let stationId: String
    var lastDateToInspection: Date?
    var jobAssignedDate: Date?
    
    // Local only (UI state)
    var isExpanded: Bool?
}

struct LastVisit: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    let inspectorId: String
    let inspectorName: String
    let visitDate: Date
    let inspectionFrequency: InspectionFrequency
    let totalScore: Int
    let totalSpentTime: Int
    let totalVoilations: Int
}

struct CheckList: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    let checkListName: String
    let questions: [Question]
    var totalAverageScore: Int?
    var totalVoilations: Int?
    var totalImagesAttached: Int?
    var totalNotesAdded: Int?
}

struct Question: Codable, Hashable {
    let question: String
    var answers: [Answers]
}

struct Answers: Codable, Hashable {
    let answer: String
    var isSelected: Bool
}

struct InspectionFrequency: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    let frequencyName: String
}

struct Building: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    let buildingName: String
    let checkLists: [CheckList]
}
