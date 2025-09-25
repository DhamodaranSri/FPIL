//
//  OrganisationModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 22/09/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Model

struct OrganisationModelDTO: Codable, Identifiable {
    var id: String?
    var firestationName: String
    var firestationCheifFirstName: String
    var firestationCheifLastName: String
    var firestationAddress: String
    var firestationContactNumber: String
    var firestationCheifContactNumber: String
    var firestationAdminEmail: String
    var timeZone: Timezone?
    var jurisdiction: Jurisdiction
    var codeReference: CodeReference?
    var billingCycle: BillingCycle?
    var stationCode: String
    var city: String
    var street: String
    var zipCode: String
    var status: Int
}

// UI Model
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

// Convert DTO → Model
extension OrganisationModel {
    init(dto: OrganisationModelDTO) {
        self.id = dto.id ?? ""
        self.firestationName = dto.firestationName
        self.firestationCheifFirstName = dto.firestationCheifFirstName
        self.firestationCheifLastName = dto.firestationCheifLastName
        self.firestationAddress = dto.firestationAddress
        self.firestationContactNumber = dto.firestationContactNumber
        self.firestationCheifContactNumber = dto.firestationCheifContactNumber
        self.firestationAdminEmail = dto.firestationAdminEmail
        self.timeZone = dto.timeZone
        self.jurisdiction = dto.jurisdiction
        self.codeReference = dto.codeReference
        self.billingCycle = dto.billingCycle
        self.stationCode = dto.stationCode
        self.city = dto.city
        self.street = dto.street
        self.zipCode = dto.zipCode
        self.status = dto.status
    }
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
