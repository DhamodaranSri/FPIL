//
//  JobCardView.swift
//  FPIL
//
//  Created by OrganicFarmers on 18/09/25.
//

import SwiftUI

struct JobCardView: View {
    let job: JobModel
    let onToggle: () -> Void
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var lastVisits: [LastVisit] {
        job.lastVist ?? []
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(job.companyName)
                        .font(ApplicationFont.bold(size: 14).value)
                        .foregroundColor(.white)
                    
                    Text(job.address)
                        .font(ApplicationFont.regular(size: 12).value)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Site ID:")
                            .font(ApplicationFont.bold(size: 12).value)
                        Text(job.siteId)
                            .font(ApplicationFont.regular(size: 12).value)
                    }
                    .foregroundColor(.white)
                }
                Spacer()
                
                let days = abs(Calendar.current.dateComponents([.day], from: (job.lastDateToInspection ?? Date()), to: Date()).day!)
                                
                if (days < 6) {
                    Text("Due Soon (\(days) days)")
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
                IconLabel(labelTitle: job.contactName, imageName: "user", textColor: .white)
                Button(action: {
                    alertMessage = "Under Construction"
                    showAlert = true
                }) {
                    IconLabel(labelTitle: job.phone, imageName: "phone", textColor: .white)
                }
            }
            
            // Expanded Content
            if job.isExpanded ?? false {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Buttons
                    HStack(spacing: 20) {
                        if (UserDefaultsStore.profileDetail?.userType != 2) {
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
                        }
                        
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
                    
                    if lastVisits.count > 0 {
                        Text("Last Visit Details")
                            .font(ApplicationFont.bold(size: 12).value)
                            .bold()
                            .foregroundColor(.white)
                    }
                                        
                    ForEach(lastVisits) { lastVisit in
                        VStack(alignment: .center, spacing: 8) {
                            HStack(spacing: 20) {
                                IconLabel(labelTitle: lastVisit.inspectorName, imageName: "user", textColor: .white)
                                IconLabel(labelTitle: lastVisit.visitDate.formatedDateAloneAsString(), imageName: "calander", textColor: .white)
                                IconLabel(labelTitle: lastVisit.cycleName, imageName: "loop", textColor: .white)
                            }
                            
                            HStack(spacing: 5) {
                                IconLabel(labelTitle: "\(lastVisit.totalScore)", imageName: "timeline", textColor: .white)
                                Text(" | ").foregroundColor(.white)
                                IconLabel(labelTitle: lastVisit.buildTypeName, imageName: "commercial", textColor: .white)
                                Text(" | ").foregroundColor(.white)
                                IconLabel(labelTitle: lastVisit.totalSpentTime.formattedDuration(), imageName: "clock", textColor: .white)
                                Text(" | ").foregroundColor(.white)
                                IconLabel(labelTitle: "\(lastVisit.totalVoilations)", imageName: "alert", textColor: .warningBG)
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
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
        .background(Color.inspectionCellBG)
        .cornerRadius(10)
        .animation(.easeInOut, value: job.isExpanded)
        .onTapGesture {
            onToggle()
        }
        .contentShape(Rectangle())
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}
