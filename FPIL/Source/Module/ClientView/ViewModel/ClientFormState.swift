//
//  ClientFormState.swift
//  FPIL
//
//  Created by OrganicFarmers on 25/10/25.
//

import Foundation
import SwiftUI
import MapKit

class ClientFormState: ObservableObject {
    @Published var id: String? = nil
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var geoLocationAddress = ""
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var address = ""
    @Published var contactNumber = ""
    @Published var email = ""
    @Published var street = ""
    @Published var city = ""
    @Published var zipCode = ""
    @Published var status: Int = 1
    @Published var parentId: String = UserDefaultsStore.profileDetail?.parentId ?? ""
    @Published var createdOn: Date? = nil
    @Published var clientType: ClientType? = nil
    @Published var organizationName: String? = nil
    @Published var notes: String? = nil
    @Published var coordinate = CLLocationCoordinate2D() {
        didSet {
            latitude = coordinate.latitude
            longitude = coordinate.longitude
        }
    }

    let buildings: [Building]
    let clientTypes: [ClientType]

    init(
        buildings: [Building],
        clientTypes: [ClientType],
        client: ClientModel? = nil
    ) {
        self.buildings = buildings
        self.clientTypes = clientTypes

        clientType = clientTypes.first
        
        if let clientData = client {
            id = clientData.id
            firstName = clientData.firstName
            lastName = clientData.lastName
            geoLocationAddress = clientData.gpsAddress
            latitude = clientData.latitude
            longitude = clientData.longitude
            address = clientData.address
            contactNumber = clientData.contactNumber
            email = clientData.email
            parentId = clientData.stationId
            city = clientData.city
            street = clientData.street
            zipCode = clientData.zipCode
            status = clientData.status
            createdOn = clientData.createdOn
            notes = clientData.notes
            clientType = clientData.clientType
            organizationName = clientData.organizationName
        }
    }

    func clearForm() {
        firstName = ""
        lastName = ""
        address = ""
        geoLocationAddress = ""
        latitude = 0.0
        longitude = 0.0
        contactNumber = ""
        email = ""
        street = ""
        city = ""
        zipCode = ""
        status = 1
        notes = nil
        clientType = clientTypes.first
        organizationName = nil
    }

    func buildInspector() -> ClientModel {
        ClientModel(
            id: id ?? UUID().uuidString,
            firstName: firstName,
            lastName: lastName,
            fullName: firstName + " " + lastName,
            gpsAddress: geoLocationAddress,
            address: address,
            latitude: latitude,
            longitude: longitude,
            contactNumber: contactNumber,
            alternateContactNumber: "",
            email: email,
            stationId: parentId,
            city: city,
            street: street,
            zipCode: zipCode,
            status: status,
            createdOn: createdOn,
            clientType: clientType,
            organizationName: organizationName,
            notes: notes,
            invoiceDetails: nil
        )
    }

    func validate() -> [String] {
        var errors: [String] = []
        if let error = Validator.isNotEmpty(geoLocationAddress, fieldName: "Geo Location Address") { errors.append(error) }
        if let error = Validator.isNotEmpty(address, fieldName: "Address") { errors.append(error) }
        if let error = Validator.isNotEmpty(street, fieldName: "Street") { errors.append(error) }
        if let error = Validator.isNotEmpty(city, fieldName: "City") { errors.append(error) }
        if let error = Validator.isValidZip(zipCode) { errors.append(error) }
        if let error = Validator.isValidPhone(contactNumber, fieldName: "Contact Number") { errors.append(error) }
        if let error = Validator.isValidEmail(email) { errors.append(error) }
        if let error = Validator.isNotEmpty(firstName, fieldName: "First Name") { errors.append(error) }
        if let error = Validator.isNotEmpty(lastName, fieldName: "Last Name") { errors.append(error) }

        return errors
    }
}
