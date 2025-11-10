//
//  StatusInspectionCell.swift
//  FPIL
//
//  Created by OrganicFarmers on 31/10/25.
//

import SwiftUI

struct StatusInspectionCell: View {
    let job: JobModel
    let onToggle: ((_ job: JobModel) -> Void)
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    let (statusText, statusColor): (String, Color) = {
                        if job.jobStartDate == nil {
                            if job.inspectorId == nil {
                                return ("Created", .gray)
                            } else {
                                return ("Assigned", .gray)
                            }
                        } else if job.jobStartDate != nil, !job.isCompleted {
                            return ("In Progress", .yellow)
                        } else if job.isCompleted, job.status == nil {
                            return ("Completed", .appPrimary)
                        } else if job.isCompleted, job.status == 1 {
                            return ("Approved", .green)
                        } else if job.isCompleted, job.status == 2 {
                            return ("Declined", .red)
                        } else {
                            return ("Revision", .blue)
                        }
                    }()
                    HStack {
                        Text(job.siteName)
                            .font(ApplicationFont.bold(size: 14).value)
                            .foregroundColor(.white)
                        Spacer()
                        Text(statusText)
                            .font(ApplicationFont.regular(size: 10).value)
                            .padding(6)
                            .padding(.horizontal, 6)
                            .background(
                                statusColor.opacity(0.2)
                            )
                            .foregroundColor(
                                statusColor
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(statusColor, lineWidth: 1)
                            )
                    }
                    
                    Text(job.geoLocationAddress)
                        .font(ApplicationFont.regular(size: 12).value)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Site ID:")
                            .font(ApplicationFont.bold(size: 12).value)
                        Text(job.id ?? "")
                            .font(ApplicationFont.regular(size: 12).value)
                    }
                    .foregroundColor(.white)
                    if UserDefaultsStore.profileDetail?.userType == 2 && job.jobAssignedDate != nil  {
                        Text("Inspector: " + (job.inspectorName ?? "Nil"))
                            .font(ApplicationFont.regular(size: 12).value)
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
            onToggle(job)
        }
        .contentShape(Rectangle())
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

