//
//  OrganisationListCell.swift
//  FPIL
//
//  Created by OrganicFarmers on 22/09/25.
//

import SwiftUI

struct OrganisationListCell: View {
    let organisation: OrganisationModel
    let onToggle: ((_ organisation: OrganisationModel) -> Void)
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(organisation.firestationName)
                            .font(ApplicationFont.bold(size: 14).value)
                            .foregroundColor(.white)
                        Spacer()
                        Text(organisation.status == 1 ? "Active" : "Inactive")
                            .font(ApplicationFont.regular(size: 10).value)
                            .padding(6)
                            .padding(.horizontal, 6)
                            .background(
                                organisation.status == 1 ? Color.green.opacity(0.2) : Color.appPrimary.opacity(0.2)
                            )
                            .foregroundColor(
                                organisation.status == 1 ? Color.green : .appPrimary
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(organisation.status == 1 ? Color.green : .appPrimary, lineWidth: 1)
                            )
                    }
                    
                    
//                    Text(organisation.businessOwnerName)
//                        .font(ApplicationFont.bold(size: 12).value)
//                        .foregroundColor(.white)
                    
                    Text(organisation.firestationAddress)
                        .font(ApplicationFont.regular(size: 12).value)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Firestation Cheif Contact:")
                            .font(ApplicationFont.bold(size: 12).value)
                    }
                    .foregroundColor(.white)
                    
                    // Contact Info
                    HStack(spacing: 16) {
                        IconLabel(labelTitle: "\(organisation.firestationCheifFirstName) \(organisation.firestationCheifLastName)", imageName: "user", textColor: .white)
                        Button(action: {
                            PhoneCallManager.shared.call(organisation.firestationCheifContactNumber, openURL: openURL)
                        }) {
                            IconLabel(labelTitle: organisation.firestationCheifContactNumber, imageName: "phone", textColor: .white)
                        }
                    }
                    
                    HStack {
                        Text("Firestation Contact:")
                            .font(ApplicationFont.bold(size: 12).value)
                    }
                    .foregroundColor(.white)
                    
                    // Contact Info
                    HStack(spacing: 16) {
                        Button(action: {
                            PhoneCallManager.shared.call(organisation.firestationContactNumber, openURL: openURL)
                        }) {
                            IconLabel(labelTitle: organisation.firestationContactNumber, imageName: "phone", textColor: .white)
                        }
                        
                        Button(action: {
                            PhoneCallManager.shared.sendEmail(to: organisation.firestationAdminEmail, openURL: openURL)
                        }) {
                            IconLabel(labelTitle: organisation.firestationAdminEmail, imageName: "email", textColor: .white)
                        }
                    }
                }
            }
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
        .background(Color.inspectionCellBG)
        .cornerRadius(10)
        .onTapGesture {
            onToggle(organisation)
        }
        .contentShape(Rectangle())
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

//#Preview {
//    OrganisationListCell(organisation: OrganisationModel(fir: "ABC FireStation", businessOwnerName: "Dhamodaran Sri", organisationAddress: "185, Ponder Street, VGN MayField Park, West Tambaram, Chennai - 600045", organisationContactNumber: "555-Demp-4532", businessOwnerContactNumber: "875-Demo-3445", organisationAdminEmail: "abc@fire.com", timeZone: Timezone(id: "1", name: "CA"), jurisdiction: Jurisdiction(id: "1", name: "California", code: "CA"), codeReference: CodeReference(id: "1", name: "Ref-1"), billingCycle: BillingCycle(id: "1", name: "Monthly"), stationCode: "12345", city: "San Francisco", street: "Penfold Street", zipCode: "94102", status: "Active"), onToggle: { })
//}
