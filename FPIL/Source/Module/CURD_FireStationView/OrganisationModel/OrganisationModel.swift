//
//  OrganisationModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 22/09/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Model
struct OrganisationModel: Codable, Identifiable {
    var id: String?
    let firestationName: String
    let firestationCheifFirstName: String
    let firestationCheifLastName: String
    let firestationAddress: String
    let firestationContactNumber: String
    let firestationCheifContactNumber: String
    let firestationAdminEmail: String
    let timeZone: Timezone?
    let jurisdiction: Jurisdiction
    let codeReference: CodeReference?
    let billingCycle: BillingCycle?
    let stationCode: String
    let city: String
    let street: String
    let zipCode: String
    let status: Int
}

struct Timezone: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    let name: String
}

struct Jurisdiction: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    let name: String
    let code: String?
}

struct CodeReference: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    let name: String
}

struct BillingCycle: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    let name: String
}
