//
//  InvoiceListCell.swift
//  FPIL
//
//  Created by OrganicFarmers on 05/11/25.
//

import SwiftUI

struct InvoiceListCell: View {
    let invoice: InvoiceDetails
    let onToggle: ((_ invoice: InvoiceDetails) -> Void)
    let onPrintInvoice: ((_ invoice: InvoiceDetails) -> Void)
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(invoice.invoiceTitle ?? "")
                            .font(ApplicationFont.bold(size: 14).value)
                            .foregroundColor(.white)
                        Spacer()
                        let statusText = invoice.status == 3 ? "Declined" : (invoice.isPaid == false ? "Unpaid" : "Paid")
                        Text(statusText)
                            .font(ApplicationFont.regular(size: 10).value)
                            .padding(6)
                            .padding(.horizontal, 6)
                            .background(
                                invoice.isPaid == true ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
                            )
                            .foregroundColor(
                                invoice.isPaid == true ? Color.green : Color.red
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(invoice.isPaid == true ? Color.green : Color.red, lineWidth: 1)
                            )
                    }
                    
                    Text(invoice.building?.buildingName ?? "")
                        .font(ApplicationFont.regular(size: 12).value)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Invoice ID:")
                            .font(ApplicationFont.bold(size: 12).value)
                        Text(invoice.id ?? "")
                            .font(ApplicationFont.regular(size: 12).value)
                    }
                    .foregroundColor(.white)
                    HStack {
                        Text("Total Amount: $\(String(format: "%.2f", invoice.totalAmountDue ?? 0.0))")
                            .font(ApplicationFont.bold(size: 12).value)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            onPrintInvoice(invoice)
                        }) {
                            Image("print")
                        }
                        .foregroundColor(.white)
                    }
                    
                    if invoice.status == 2 && !invoice.isPaid {
                        Button(action: {
                        }) {
                            IconLabel(labelTitle: "Mark as Paid", imageName: "paid", textColor: .white)
                                .font(ApplicationFont.bold(size: 12).value)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.appPrimary, lineWidth: 1)
                                )
                        }
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                    }
                }
            }
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
        .background(Color.inspectionCellBG)
        .cornerRadius(10)
        .onTapGesture {
            onToggle(invoice)
        }
        .contentShape(Rectangle())
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}
