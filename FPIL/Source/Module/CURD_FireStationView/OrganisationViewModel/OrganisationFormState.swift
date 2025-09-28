//
//  OrganisationFormState.swift
//  FPIL
//
//  Created by OrganicFarmers on 25/09/25.
//

import Foundation
import SwiftUI

class OrganisationFormState: ObservableObject {
    @Published var id: String? = nil
    @Published var firestationName = ""
    @Published var firestationCheifFirstName = ""
    @Published var firestationCheifLastName = ""
    @Published var firestationAddress = ""
    @Published var firestationContactNumber = ""
    @Published var firestationCheifContactNumber = ""
    @Published var firestationAdminEmail = ""
    @Published var street = ""
    @Published var city = ""
    @Published var zipCode = ""
    @Published var stationCode = ""
    @Published var status: Int = 1

    @Published var selectedTimeZone: Timezone = Timezone(id: "1", name: "CA")
    @Published var selectedJurisdiction: Jurisdiction = Jurisdiction(id: "1", name: "California", code: "CA")
    @Published var selectedCodeReference: CodeReference = CodeReference(id: "1", name: "Ref-1")

    let timeZones: [Timezone]
    let jurisdictions: [Jurisdiction]
    let codeReferences: [CodeReference]
    let billingCycles: [BillingCycle]

    init(
        timeZones: [Timezone],
        jurisdictions: [Jurisdiction],
        codeReferences: [CodeReference],
        billingCycles: [BillingCycle],
        organisation: OrganisationModel? = nil
    ) {
        self.timeZones = timeZones
        self.jurisdictions = jurisdictions
        self.codeReferences = codeReferences
        self.billingCycles = billingCycles

        // If editing existing organisation
        if let org = organisation {
            id = org.id
            firestationName = org.firestationName
            firestationCheifFirstName = org.firestationCheifFirstName
            firestationCheifLastName = org.firestationCheifLastName
            firestationAddress = org.firestationAddress
            firestationContactNumber = org.firestationContactNumber
            firestationCheifContactNumber = org.firestationCheifContactNumber
            firestationAdminEmail = org.firestationAdminEmail
            stationCode = org.stationCode
            street = org.street
            city = org.city
            zipCode = org.zipCode
            selectedJurisdiction = org.jurisdiction
            selectedCodeReference = org.codeReference ?? selectedCodeReference
            status = org.status
        }
    }

    func clearForm() {
        firestationName = ""
        firestationCheifFirstName = ""
        firestationCheifLastName = ""
        firestationAddress = ""
        firestationContactNumber = ""
        firestationCheifContactNumber = ""
        firestationAdminEmail = ""
        stationCode = ""
        street = ""
        city = ""
        zipCode = ""
        status = 1
        selectedJurisdiction = jurisdictions.first!
        selectedCodeReference = codeReferences.first!
    }

    func buildOrganisation() -> OrganisationModel {
        return OrganisationModel(
            id: id ?? UUID().uuidString,
            firestationName: firestationName,
            firestationCheifFirstName: firestationCheifFirstName,
            firestationCheifLastName: firestationCheifLastName,
            firestationAddress: firestationAddress,
            firestationContactNumber: firestationContactNumber,
            firestationCheifContactNumber: firestationCheifContactNumber,
            firestationAdminEmail: firestationAdminEmail,
            timeZone: selectedTimeZone,
            jurisdiction: selectedJurisdiction,
            codeReference: selectedCodeReference,
            billingCycle: nil,
            stationCode: stationCode,
            city: city,
            street: street,
            zipCode: zipCode,
            status: status
        )
    }

    func validate() -> [String] {
        var errors: [String] = []

        if let error = Validator.isNotEmpty(firestationName, fieldName: "Firestation Name") { errors.append(error) }
        if let error = Validator.isNotEmpty(stationCode, fieldName: "Station Code") { errors.append(error) }
        if let error = Validator.isNotEmpty(firestationAddress, fieldName: "Address") { errors.append(error) }
        if let error = Validator.isNotEmpty(city, fieldName: "City") { errors.append(error) }
        if let error = Validator.isValidZip(zipCode) { errors.append(error) }
        if let error = Validator.isValidPhone(firestationContactNumber, fieldName: "Firestation Contact Number") { errors.append(error) }
        if let error = Validator.isValidEmail(firestationAdminEmail) { errors.append(error) }
        if let error = Validator.isNotEmpty(firestationCheifFirstName, fieldName: "Chief First Name") { errors.append(error) }
        if let error = Validator.isNotEmpty(firestationCheifLastName, fieldName: "Chief Last Name") { errors.append(error) }
        if let error = Validator.isValidPhone(firestationCheifContactNumber, fieldName: "Chief Contact Number") { errors.append(error) }

        return errors
    }
}
