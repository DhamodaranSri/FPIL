//
//  ClientListCell.swift
//  FPIL
//
//  Created by OrganicFarmers on 26/10/25.
//

import SwiftUI

struct ClientListCell: View {
    
    let client: ClientModel
    let onToggle: ((_ client: ClientModel, _ isButtonTapped: Bool) -> Void)
    let onTapCell: ((_ client: ClientModel) -> Void)
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    if let clientTypeName = client.clientType?.clientTypeName {
                        Text(clientTypeName)
                            .font(ApplicationFont.bold(size: 15).value)
                            .foregroundColor(.white)
                    }
                    if let organizationName = client.organizationName {
                        Text(organizationName)
                            .font(ApplicationFont.bold(size: 14).value)
                            .foregroundColor(.white)
                    }
                    HStack {
                        Text(client.fullName)
                            .font(ApplicationFont.bold(size: 13).value)
                            .foregroundColor(.white)
                        Spacer()
                        let totalAmountDue = client.invoiceDetails?
                            .filter { $0.isPaid == false }
                            .compactMap { $0.totalAmountDue }
                            .reduce(0, +) ?? 0
                        if client.invoiceDetails?.count ?? 0 > 0, totalAmountDue > 0.0 {
                            Text(totalAmountDue == 0.0 ? "Paid" : "Due Amount: \(String(format: "$%.2f", totalAmountDue))")
                                .font(ApplicationFont.regular(size: 10).value)
                                .padding(6)
                                .padding(.horizontal, 6)
                                .background(
                                    totalAmountDue == 0.0 ? Color.green.opacity(0.2) : Color.appPrimary.opacity(0.2)
                                )
                                .foregroundColor(
                                    totalAmountDue == 0.0 ? Color.green : .appPrimary
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(totalAmountDue == 0.0 ? Color.green : .appPrimary, lineWidth: 1)
                                )
                        }
                    }
                    
                    Text(client.gpsAddress)
                        .font(ApplicationFont.regular(size: 12).value)
                        .foregroundColor(.white)

                    HStack(spacing: 16) {
                        Button(action: {
                            PhoneCallManager.shared.sendEmail(to: client.email, openURL: openURL)
                        }) {
                            IconLabel(labelTitle: client.email, imageName: "email", textColor: .white)
                        }
                        Button(action: {
                            PhoneCallManager.shared.call(client.contactNumber, openURL: openURL)
                        }) {
                            IconLabel(labelTitle: client.contactNumber, imageName: "phone", textColor: .white)
                        }
                    }
                    
                    HStack {
                        Button(action: {
                            onToggle(client, true)
                        }) {
                            
                            if (client.invoiceDetails?
                                    .filter { ($0.inspectionsId?.count ?? 0) == 0 }
                                    .count ?? 0) == 0 {
                                
                                IconLabel(labelTitle: "Share Quotation", imageName: "notes", textColor: .white)
                                    .font(ApplicationFont.bold(size: 12).value)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.appPrimary, lineWidth: 1)
                                    )
                            }
                        }
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                        Spacer()
                        Button(action: {
                            onToggle(client, false)
                        }) {
                            Image("edit")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
        .background(Color.inspectionCellBG)
        .cornerRadius(10)
        .onTapGesture {
            onTapCell(client)
        }
        .contentShape(Rectangle())
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}
