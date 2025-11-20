//
//  FireInspectorListCell.swift
//  FPIL
//
//  Created by OrganicFarmers on 27/09/25.
//

import SwiftUI

struct FireInspectorListCell: View {
    
    let inspector: FireStationInspectorModel
    let onToggle: ((_ inspector: FireStationInspectorModel) -> Void)
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack {
                            Text(inspector.firstName + " " + inspector.lastName)
                                .font(ApplicationFont.bold(size: 14).value)
                                .foregroundColor(.white)
                            if let inspector = inspector.employeeId, inspector.isEmpty {
                                Text(" - (Volunteer)")
                                    .font(ApplicationFont.regular(size: 12).value)
                                    .foregroundColor(.white)
                            } else {
                                Text(" - " + (inspector.employeeId ?? "(Volunteer)"))
                                    .font(ApplicationFont.regular(size: 12).value)
                                    .foregroundColor(.white)
                            }
                            
                        }
                        
                        Spacer()
                        Text(inspector.status == 1 ? "Active" : "Inactive")
                            .font(ApplicationFont.regular(size: 10).value)
                            .padding(6)
                            .padding(.horizontal, 6)
                            .background(
                                inspector.status == 1 ? Color.green.opacity(0.2) : Color.appPrimary.opacity(0.2)
                            )
                            .foregroundColor(
                                inspector.status == 1 ? Color.green : .appPrimary
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(inspector.status == 1 ? Color.green : .appPrimary, lineWidth: 1)
                            )
                    }
                    
                    Text(inspector.address)
                        .font(ApplicationFont.regular(size: 12).value)
                        .foregroundColor(.white)

                    HStack(spacing: 16) {
                        Button(action: {
                            PhoneCallManager.shared.call(inspector.contactNumber, openURL: openURL)
                        }) {
                            IconLabel(labelTitle: inspector.contactNumber, imageName: "phone", textColor: .white)
                        }
                        
                        Button(action: {
                            PhoneCallManager.shared.sendEmail(to: inspector.email, openURL: openURL)
                        }) {
                            IconLabel(labelTitle: inspector.email, imageName: "email", textColor: .white)
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
            onToggle(inspector)
        }
        .contentShape(Rectangle())
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

//#Preview {
//    FireInspectorListCell(inspector: <#FireStationInspectorModel#>, onToggle: <#(FireStationInspectorModel) -> Void#>)
//}
