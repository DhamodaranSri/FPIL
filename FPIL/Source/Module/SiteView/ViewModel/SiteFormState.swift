//
//  SiteFormState.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/10/25.
//

import Foundation
import SwiftUI
import MapKit

class SiteFormState: ObservableObject {

    @Published var id: String? = nil
    @Published var siteName = ""
    @Published var inspectorId: String? = UserDefaultsStore.profileDetail?.userType == 2 ? nil : UserDefaultsStore.profileDetail?.id
    @Published var inspectorName: String? = UserDefaultsStore.profileDetail?.userType == 2 ? nil : (UserDefaultsStore.profileDetail?.firstName ?? "")
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var address = ""
    @Published var geoLocationAddress = ""
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var clientId: String? = nil
    @Published var contactNumber = ""
    @Published var email = ""
    @Published var street = ""
    @Published var city = ""
    @Published var zipCode = ""
    @Published var building: Building = UserDefaultsStore.buildings?.first ?? Building(id: "1FF1C7A4-0F21-4590-9BF9-F79C175CC642", buildingName: "Healthcare Facility", checkLists: [CheckList(id: "LrWMWxoBSz26oOBVVDOI",checkListName: "Healthcare Facility Fire Inspection Checklist", questions: [Question(question: "General Facility Safety", answers: [Answers(answer: "Facility address and building identification visible from the street", isSelected: false)])])])
    @Published var stationId: String = UserDefaultsStore.profileDetail?.parentId ?? ""
    @Published var inspectionFrequency: InspectionFrequency = UserDefaultsStore.frequency?.first ?? InspectionFrequency(id: "NfVuBtBLVT17dUUUhTB6", frequencyName: "Monthly")
    @Published var createdById: String? = UserDefaultsStore.profileDetail?.id
    @Published var isCompletedInspection: Bool = false
    @Published var jobCreatedDate: Date? = nil
    @Published var lastDateToInspection: Date = Date()
    @Published var jobAssignedDate: Date? = nil
    @Published var coordinate = CLLocationCoordinate2D() {
        didSet {
            latitude = coordinate.latitude
            longitude = coordinate.longitude
        }
    }
    @Published var inspector: FireStationInspectorModel? = nil
    @Published var client: ClientModel? = nil
    
    var lastDate: Date?

    let buildings: [Building]
    let frequencys: [InspectionFrequency]
    let isAssign: Bool
    let inspectors: [FireStationInspectorModel]
    let clients: [ClientModel]

    init(
        buildings: [Building],
        frequencys: [InspectionFrequency],
        site: JobModel? = nil,
        isAssign: Bool = false,
        inspectors: [FireStationInspectorModel] = [],
        clients: [ClientModel] = []
    ) {
        self.buildings = buildings
        self.frequencys = frequencys
        self.isAssign = isAssign
        self.inspectors = inspectors
        self.clients = clients

        inspector = inspectors.first(where: { insModel in
            insModel.id == site?.inspectorId
        })
        
        if let org = site {
            id = org.id
            firstName = org.firstName
            lastName = org.lastName
            address = org.address
            geoLocationAddress = org.geoLocationAddress
            contactNumber = org.phone
            email = org.email
            stationId = stationId
            street = org.street
            city = org.city
            zipCode = org.zipCode
            building = org.building
            siteName = org.siteName
            latitude = org.latitude
            longitude = org.longitude
            inspectionFrequency = org.inspectionFrequency
            createdById = org.createdById
            inspectorId = org.inspectorId
            inspectorName = org.inspectorName
            clientId = org.clientId
            isCompletedInspection = org.isCompleted
            jobCreatedDate = org.jobCreatedDate
            lastDateToInspection = org.lastDateToInspection ?? Date()
            lastDate = org.lastDateToInspection
        }
    }

    func clearForm() {
        firstName = ""
        lastName = ""
        address = ""
        geoLocationAddress = ""
        contactNumber = ""
        email = ""
        street = ""
        city = ""
        zipCode = ""
        building = UserDefaultsStore.buildings?.first ?? Building(id: "1FF1C7A4-0F21-4590-9BF9-F79C175CC642", buildingName: "Healthcare Facility", checkLists: [CheckList(id: "LrWMWxoBSz26oOBVVDOI",checkListName: "Healthcare Facility Fire Inspection Checklist", questions: [Question(question: "General Facility Safety", answers: [Answers(answer: "Facility address and building identification visible from the street", isSelected: false)])])])
        siteName = ""
        latitude = 0.0
        longitude = 0.0
        inspectionFrequency = UserDefaultsStore.frequency?.first ?? InspectionFrequency(id: "NfVuBtBLVT17dUUUhTB6", frequencyName: "Monthly")
        clientId = nil
        jobCreatedDate = nil
        isCompletedInspection = false
        jobAssignedDate = nil
        lastDateToInspection = Date()
        inspector = nil
    }

    func buildJobModelForInspector() -> JobModel {
        
        return JobModel(
            id: id ?? "Site-\(getShortUUID())-\((createdById ?? "").getShortID())",
            inspectorId: inspector?.id ?? inspectorId,
            inspectorName: inspector?.firstName ?? inspectorName,
            siteName: siteName,
            address: address,
            city: city,
            street: street,
            zipCode: zipCode,
            geoLocationAddress: geoLocationAddress,
            latitude: latitude,
            longitude: longitude,
            firstName: firstName,
            lastName: lastName,
            phone: contactNumber,
            email: email,
            alternateContactNumber: "",
            building: building,
            inspectionFrequency: inspectionFrequency,
            isCompleted: isCompletedInspection,
            jobCreatedDate: jobCreatedDate ?? Date(),
            createdById: createdById,
            stationId: stationId,
            lastDateToInspection: (UserDefaultsStore.profileDetail?.userType == 2 && !isAssign) ? lastDate?.endOfDay : lastDateToInspection.endOfDay,
            jobAssignedDate: (UserDefaultsStore.profileDetail?.userType == 2 && jobAssignedDate == nil && !isAssign) ? nil : (jobAssignedDate ?? Date())
        )
    }

    func buildJobModelFromClient(client: ClientModel?) -> JobModel {
        return JobModel(
            id: id ?? "Site-\(getShortUUID())-\((createdById ?? "").getShortID())",
            inspectorId: inspector?.id ?? inspectorId,
            inspectorName: inspector?.firstName ?? inspectorName,
            siteName: siteName,
            address: address,
            city: city,
            street: street,
            zipCode: zipCode,
            geoLocationAddress: geoLocationAddress,
            latitude: latitude,
            longitude: longitude,
            firstName: firstName,
            lastName: lastName,
            phone: contactNumber,
            email: email,
            alternateContactNumber: "",
            building: building,
            inspectionFrequency: inspectionFrequency,
            isCompleted: isCompletedInspection,
            jobCreatedDate: jobCreatedDate ?? Date(),
            createdById: createdById,
            stationId: stationId,
            lastDateToInspection: (UserDefaultsStore.profileDetail?.userType == 2 && !isAssign) ? lastDate?.endOfDay : lastDateToInspection.endOfDay,
            jobAssignedDate: (UserDefaultsStore.profileDetail?.userType == 2 && jobAssignedDate == nil && !isAssign) ? nil : (jobAssignedDate ?? Date()),
            client: client
        )
    }


    func validate(client: ClientModel? = nil) -> [String] {
        if let org = client {
            email = org.email
            firstName = org.firstName
            lastName = org.lastName
        } else if let org = self.client {
            email = org.email
            firstName = org.firstName
            lastName = org.lastName
        }
        var errors: [String] = []
        if let error = Validator.isNotEmpty(street, fieldName: "Street") { errors.append(error) }
        if let error = Validator.isNotEmpty(address, fieldName: "Address") { errors.append(error) }
        if let error = Validator.isNotEmpty(geoLocationAddress, fieldName: "Geo Location Address") { errors.append(error) }
        if let error = Validator.isNotEmpty(city, fieldName: "City") { errors.append(error) }
        if let error = Validator.isValidZip(zipCode) { errors.append(error) }
        if let error = Validator.isValidPhone(contactNumber, fieldName: "Contact Number") { errors.append(error) }
        if let error = Validator.isValidEmail(email) { errors.append(error) }
        if let error = Validator.isNotEmpty(firstName, fieldName: "First Name") { errors.append(error) }
        if let error = Validator.isNotEmpty(lastName, fieldName: "Last Name") { errors.append(error) }
        if let error = Validator.isNotEmpty(siteName, fieldName: "Site Name") { errors.append(error) }

        return errors
    }
}


public func getShortUUID() -> String {
    String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(8))
}

extension String {
    func getShortID() -> String {
        String(self.replacingOccurrences(of: "-", with: "").prefix(4))
    }
}
