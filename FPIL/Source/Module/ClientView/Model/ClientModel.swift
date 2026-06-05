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

struct AICheckListModel: Codable,Identifiable, Hashable {
    var id: String? = UUID().uuidString
    let created_at: Date?
    let pdf_url: String?
    let processing_started_at: Date?
    let processing_time_seconds: Double?
    let request_id: String?
    let status: String?
    let updated_at: Date?
    let compliance_report: ComplainceReport?
    let isVerified: Bool?
    let projectName: String?
    let client: ClientModel?
    let user_id: String?
}

struct ComplainceReport: Codable, Hashable {
    let checklist: [AICheckList]?
    let compliance_score: Double?
    let diagrams_analyzed: Bool?
    let pages_processed: Int?
    let recommendation: String?
    let summary: String?
    let violations: [AIViolations]?
}

struct AICheckList: Codable, Hashable {
    let category: String?
    let code_ref: String?
    let item: String?
    let notes: String?
    let status: String?
}

struct AIViolations: Codable, Hashable {
    let code: String?
    let description: String?
    let severity: String?
}
/*
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
 */
extension CheckList {
    
    init(aiModel: AICheckListModel) {
        
        let aiChecklist = aiModel.compliance_report?.checklist ?? []
        let violations = aiModel.compliance_report?.violations ?? []
        
        self.id = aiModel.request_id
        self.checkListName = aiModel.projectName ?? aiModel.request_id ?? ""
        
        self.questions = aiChecklist.map { item in
            
            let matchingViolation = violations.first {
                $0.code == item.code_ref
            }
            
            let answer = Answers(
                answer: item.notes ?? "Unknown",
                isSelected: true,
                isVoilated: matchingViolation != nil,
                voilationDescription: matchingViolation?.description,
                photoUrl: nil,
                status: item.status
            )
            
            return Question(
                question: item.item ?? "",
                answers: [answer],
                referenceCode: item.code_ref,
                category: item.category
            )
        }
        
        self.aiCheckListStatus = aiModel.status
        self.totalAverageScore = Int(aiModel.compliance_report?.compliance_score ?? 0)
        self.totalVoilations = violations.count
        self.totalImagesAttached = 0
        self.totalNotesAdded = aiChecklist.filter { !($0.notes?.isEmpty ?? true) }.count
        self.estimatedInspectionPrice = nil
    }
}
