//
//  SiteCardView.swift
//  FPIL
//
//  Created by OrganicFarmers on 18/09/25.
//

import SwiftUI

struct SiteCardView: View {
    let site: Site
    let onToggle: () -> Void
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(site.companyName)
                        .font(ApplicationFont.bold(size: 14).value)
                        .foregroundColor(.white)
                    
                    Text(site.address)
                        .font(ApplicationFont.regular(size: 12).value)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Site ID:")
                            .font(ApplicationFont.bold(size: 12).value)
                        Text(site.siteId)
                            .font(ApplicationFont.regular(size: 12).value)
                    }
                    .foregroundColor(.white)
                }
                Spacer()
                
                if site.isExpanded {
                    Text("Due Soon (5 days)")
                        .font(ApplicationFont.regular(size: 10).value)
                        .padding(6)
                        .padding(.horizontal, 6)
                        .background(Color.warningBG.opacity(0.2))
                        .foregroundColor(.warningBG)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.warningBG, lineWidth: 1)
                        )
                }
            }
            
            // Contact Info
            HStack(spacing: 16) {
                IconLabel(labelTitle: site.contactName, imageName: "user", textColor: .white)
                Button(action: {
                    alertMessage = "Under Construction"
                    showAlert = true
                }) {
                    IconLabel(labelTitle: site.phone, imageName: "phone", textColor: .white)
                }
            }
            
            // Expanded Content
            if site.isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            alertMessage = "Under Construction"
                            showAlert = true
                        }) {
                            IconLabel(labelTitle: "Start", imageName: "play", textColor: .white)
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
                        
                        Button {
                            alertMessage = "Under Construction"
                            showAlert = true
                        } label: {
                            Text("Update Details")
                                .font(ApplicationFont.regular(size: 12).value)
                                .foregroundColor(.white)
                                .underline()
                        }
                        .contentShape(Rectangle())
                        
                        Spacer()
                        
                        Button(action: {
                            alertMessage = "Under Construction"
                            showAlert = true
                        }) {
                            Image("print")
                        }
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                    }
                                        
                    Text("Last Visit Details")
                        .font(ApplicationFont.bold(size: 12).value)
                        .bold()
                        .foregroundColor(.white)
                    
                    VStack(alignment: .center, spacing: 8) {
                        HStack(spacing: 20) {
                            IconLabel(labelTitle: "Inspector Mike", imageName: "user", textColor: .white)
                            IconLabel(labelTitle: "25/7/2025", imageName: "calander", textColor: .white)
                            IconLabel(labelTitle: "Monthly", imageName: "loop", textColor: .white)
                        }
                        
                        HStack(spacing: 5) {
                            IconLabel(labelTitle: "999", imageName: "timeline", textColor: .white)
                            Text(" | ").foregroundColor(.white)
                            IconLabel(labelTitle: "Commercial", imageName: "commercial", textColor: .white)
                            Text(" | ").foregroundColor(.white)
                            IconLabel(labelTitle: "1.2 Hrs", imageName: "clock", textColor: .white)
                            Text(" | ").foregroundColor(.white)
                            IconLabel(labelTitle: "100", imageName: "alert", textColor: .warningBG)
                        }
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.appPrimary, lineWidth: 1))
                    .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
        .background(Color.inspectionCellBG)
        .cornerRadius(10)
        .animation(.easeInOut, value: site.isExpanded)
        .onTapGesture {
            onToggle()
        }
        .contentShape(Rectangle())
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}
