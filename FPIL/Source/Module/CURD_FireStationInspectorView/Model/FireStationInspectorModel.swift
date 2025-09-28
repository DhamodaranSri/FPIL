//
//  FireStationInspectorModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 27/09/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Model
struct FireStationInspectorModel: Codable, Identifiable {
    var id: String?
    let firstName: String
    let lastName: String
    let address: String
    let contactNumber: String
    let email: String
    let timeZone: Timezone?
    let jurisdiction: Jurisdiction
    let codeReference: CodeReference?
    let stationCode: String
    let city: String
    let street: String
    let zipCode: String
    let status: Int
    let parentId: String
    let position: FireStationEmployeeJobDesignations
    let employeeId: String?
}

struct FireStationEmployeeJobDesignations: Codable, Identifiable, Hashable {
    let id: String
    let position: String
    let userTypeId: Int
}
