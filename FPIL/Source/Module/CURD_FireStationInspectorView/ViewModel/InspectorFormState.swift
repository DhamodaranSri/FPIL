//
//  InspectorFormState.swift
//  FPIL
//
//  Created by OrganicFarmers on 27/09/25.
//

import Foundation
import SwiftUI

class InspectorFormState: ObservableObject {
    @Published var id: String? = nil
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var address = ""
    @Published var contactNumber = ""
    @Published var email = ""
    @Published var street = ""
    @Published var city = ""
    @Published var zipCode = ""
    @Published var stationCode = UserDefaultsStore.fireStationDetail?.stationCode ?? ""
    @Published var status: Int = 1
    @Published var parentId: String = UserDefaultsStore.profileDetail?.parentId ?? ""
    @Published var position: FireStationEmployeeJobDesignations = FireStationEmployeeJobDesignations(id: "LxlaYK5OeeDpXLfO9mpm", position: "Inspector", userTypeId: 3)
    @Published var employeeId: String = ""

    @Published var selectedTimeZone: Timezone = UserDefaultsStore.fireStationDetail?.timeZone ?? Timezone(id: "1", name: "CA")
    @Published var selectedJurisdiction: Jurisdiction = UserDefaultsStore.fireStationDetail?.jurisdiction ?? Jurisdiction(id: "1", name: "California", code: "CA")
    @Published var selectedCodeReference: CodeReference = UserDefaultsStore.fireStationDetail?.codeReference ?? CodeReference(id: "1", name: "Ref-1")
    @Published var selectedPosition: FireStationEmployeeJobDesignations = FireStationEmployeeJobDesignations(id: "LxlaYK5OeeDpXLfO9mpm", position: "Inspector", userTypeId: 3)

    let positions: [FireStationEmployeeJobDesignations]

    init(
        positions: [FireStationEmployeeJobDesignations],
        inspector: FireStationInspectorModel? = nil
    ) {
        self.positions = positions

        if let org = inspector {
            id = org.id
            firstName = org.firstName
            lastName = org.lastName
            address = org.address
            contactNumber = org.contactNumber
            email = org.email
            stationCode = stationCode
            street = org.street
            city = org.city
            zipCode = org.zipCode
            selectedJurisdiction = selectedJurisdiction
            selectedCodeReference = selectedCodeReference
            status = org.status
            parentId = parentId
            position = org.position
            employeeId = org.employeeId ?? ""
        }
    }

    func clearForm() {
        firstName = ""
        lastName = ""
        address = ""
        contactNumber = ""
        email = ""
        stationCode = ""
        street = ""
        city = ""
        zipCode = ""
        status = 1
        position = FireStationEmployeeJobDesignations(id: "LxlaYK5OeeDpXLfO9mpm", position: "Inspector", userTypeId: 3)
        employeeId = ""
    }

    func buildInspector() -> FireStationInspectorModel {
        
        FireStationInspectorModel(
            id: id ?? UUID().uuidString,
            firstName: firstName,
            lastName: lastName,
            address: address,
            contactNumber: contactNumber,
            email: email,
            timeZone: selectedTimeZone,
            jurisdiction: selectedJurisdiction,
            codeReference: selectedCodeReference,
            stationCode: stationCode,
            city: city,
            street: street,
            zipCode: zipCode,
            status: status,
            parentId: parentId,
            position: selectedPosition,
            employeeId: employeeId
        )
    }

    func validate() -> [String] {
        var errors: [String] = []

        if let error = Validator.isNotEmpty(stationCode, fieldName: "Station Code") { errors.append(error) }
        if let error = Validator.isNotEmpty(address, fieldName: "Address") { errors.append(error) }
        if let error = Validator.isNotEmpty(city, fieldName: "City") { errors.append(error) }
        if let error = Validator.isValidZip(zipCode) { errors.append(error) }
        if let error = Validator.isValidPhone(contactNumber, fieldName: "Contact Number") { errors.append(error) }
        if let error = Validator.isValidEmail(email) { errors.append(error) }
        if let error = Validator.isNotEmpty(firstName, fieldName: "First Name") { errors.append(error) }
        if let error = Validator.isNotEmpty(lastName, fieldName: "Last Name") { errors.append(error) }

        return errors
    }
}
