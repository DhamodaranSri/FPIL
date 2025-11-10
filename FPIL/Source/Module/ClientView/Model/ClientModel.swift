//
//  ClientModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 24/10/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Model
struct ClientModel: Codable, Identifiable, Hashable {
    var id: String?
    let firstName: String
    let lastName: String
    let fullName: String
    let gpsAddress: String
    let address: String
    let latitude: Double
    let longitude: Double
    let contactNumber: String
    let alternateContactNumber: String
    let email: String
    let stationId: String
    let city: String
    let street: String
    let zipCode: String
    let status: Int
    let createdOn: Date?
    let clientType: ClientType?
    let organizationName: String?
    let notes: String?
    var invoiceDetails: [InvoiceDetails]?
}

struct ClientType: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    var clientTypeName: String
}

struct PaymentDetails: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    var isPreInspectionPaid: Bool?
    var totalAmountPaid: Double?
}

struct InvoiceDetails: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    var invoiceTitle: String?
    var inspectionsId: String?
    var clientId: String?
    var generatedOn: Date?
    var dueDate: Date?
    var paidDate: Date?
    var totalAmountDue: Double?
    var subtotal: Double?
    var taxAmount: Double?
    var taxRate: Double?
    var isPaid: Bool
    var status: Int? = 1
    var paymentMethod: String?
    var building: Building?
    var servicePerformed: [ServicePerformed]?
    var invoicePDFUrl: String?
}

struct ServicePerformed: Codable, Identifiable, Hashable {
    var id: String? = UUID().uuidString
    var serviceName: String?
    var isDefault: Bool?
    var price: Double?
    var isSelected: Bool? = false
}
