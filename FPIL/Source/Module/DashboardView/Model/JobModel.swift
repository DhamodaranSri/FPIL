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
struct JobModel: Codable, Identifiable, Hashable {
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
    var building: Building
    let inspectionFrequency: InspectionFrequency
    var isCompleted: Bool
    var lastVist: [LastVisit]?
    var jobCreatedDate: Date
    var createdById: String?
    let stationId: String
    var lastDateToInspection: Date?
    var jobAssignedDate: Date?
    var siteQRCodeImageUrl: String?
    var jobStartDate: Date?
    var jobCompletionDate: Date?
    var isPending: Bool?
    var reScheduleDate: Date?
    var sitePlanDocUrl: String?
    var status: Int? = nil
    var reviewNotes: String? = nil
    var reportPdfUrl: String? = nil
    var client:ClientModel? = nil
    var invoiceDetails: [InvoiceDetails]? = nil
    
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
    let totalSpentTime: TimeInterval
    let totalVoilations: Int
}

struct CheckList: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    var checkListName: String
    var questions: [Question]
    var totalAverageScore: Int?
    var totalVoilations: Int?
    var totalImagesAttached: Int?
    var totalNotesAdded: Int?
    var estimatedInspectionPrice: Double?
}

struct Question: Codable, Hashable {
    let question: String
    var answers: [Answers]
}

struct Answers: Codable, Hashable {
    let answer: String
    var isSelected: Bool
    var isVoilated: Bool? = false
    var voilationDescription: String? = nil
    var photoUrl: String? = nil
}

struct InspectionFrequency: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    let frequencyName: String
}

struct Building: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    var buildingName: String
    var checkLists: [CheckList] = []

    enum CodingKeys: String, CodingKey {
        case id, buildingName, checkLists
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decode(String.self, forKey: .id)
        buildingName = try container.decode(String.self, forKey: .buildingName)
        checkLists = (try? container.decode([CheckList].self, forKey: .checkLists)) ?? []
    }

    init(id: String? = UUID().uuidString, buildingName: String, checkLists: [CheckList] = []) {
        self.id = id
        self.buildingName = buildingName
        self.checkLists = checkLists
    }
}


extension Encodable {
    func toDictionary() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        } catch {
            print("Encoding error: \(error)")
            return nil
        }
    }

    func toFirestoreData() -> [String: Any]? {
            do {
                let data = try Firestore.Encoder().encode(self)
                return data
            } catch {
                print("Firestore encoding error: \(error)")
                return nil
            }
        }
}

extension JobModel {
    var totalSpentTime: TimeInterval {
        lastVist?.compactMap { $0.totalSpentTime > 0 ? $0.totalSpentTime : nil }
                  .reduce(0, +) ?? 0
    }
}
