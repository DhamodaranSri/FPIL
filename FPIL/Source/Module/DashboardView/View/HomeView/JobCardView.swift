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
    let updateDetails: (JobModel) -> Void
    let showQRDetails: (UIImage) -> Void
    let assignJob: (JobModel) -> Void
    let raiseRequestForJob: ((JobModel) -> Void)?
    let startJob: ((JobModel) -> Void)?
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.openURL) private var openURL
    var isHistory: Bool = false
    
    var lastVisits: [LastVisit] {
        job.lastVist ?? []
    }
    
    init(job: JobModel, isHistory: Bool = false, onToggle: @escaping () -> Void, updateDetails: @escaping (JobModel) -> Void, showQRDetails: @escaping (UIImage) -> Void, assignJob: @escaping (JobModel) -> Void, raiseRequestForJob: ((JobModel) -> Void)? = nil, startJob: ((JobModel) -> Void)? = nil, showAlert: Bool = false, alertMessage: String = "") {
        self.job = job
        self.onToggle = onToggle
        self.updateDetails = updateDetails
        self.showAlert = showAlert
        self.alertMessage = alertMessage
        self.showQRDetails = showQRDetails
        self.assignJob = assignJob
        self.raiseRequestForJob = raiseRequestForJob
        self.startJob = startJob
        self.isHistory = isHistory
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(job.siteName)
                        .font(ApplicationFont.bold(size: 14).value)
                        .foregroundColor(.white)
                    
                    Text(job.address)
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
                        Text("Assigned To: " + (job.inspectorName ?? "Nil"))
                            .font(ApplicationFont.regular(size: 12).value)
                            .foregroundColor(.white)
                    }
                    
                }
                Spacer()
                if let dueDate = job.lastDateToInspection, job.isCompleted == false {
                    let days = Calendar.current.dateComponents([.day], from: dueDate, to: Date()).day!
                    
                    if (days > -6 && days <= 0) {
                        Text("Due Soon (\(abs(days)) days)")
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
                    } else if days > 0 {
                        Text("Due days expired")
                            .font(ApplicationFont.regular(size: 10).value)
                            .padding(6)
                            .padding(.horizontal, 6)
                            .background(Color.appPrimary.opacity(0.2))
                            .foregroundColor(.appPrimary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.appPrimary, lineWidth: 1)
                            )
                    }
                }
                if job.isCompleted && job.status == nil {
                    let status = UserDefaultsStore.profileDetail?.userType == 2 || isHistory ? "In-Review" : "Completed"
                    jobStatusView(status: status, color: Color.appPrimary, textColor: Color.appPrimary)
                } else if job.isCompleted && job.status == 1 {
                    jobStatusView(status: "Approved", color: .green, textColor: .white)
                } else if job.isCompleted && job.status == 2 {
                    jobStatusView(status: "Declined", color: .red, textColor: .white)
                } else if job.isCompleted && job.status == 3 {
                    jobStatusView(status: "Revision", color: .blue, textColor: .white)
                }
            }
            
            // Contact Info
            HStack(spacing: 16) {
                IconLabel(labelTitle: "\(job.firstName) \(job.lastName)", imageName: "user", textColor: .white)
                Button(action: {
                    PhoneCallManager.shared.call(job.phone, openURL: openURL)
                }) {
                    IconLabel(labelTitle: job.phone, imageName: "phone", textColor: .white)
                }
            }
            
            HStack(spacing: 20) {
                if (UserDefaultsStore.profileDetail?.userType != 2) {
                    Button(action: {
//                        alertMessage = "Start Inspection is Under In-Progress on development"
//                        showAlert = true
                        if UserDefaultsStore.jobStartedDate != nil {
                            if job.jobStartDate != nil && job.jobCompletionDate == nil && job.isCompleted == false {
                                startJob?(job)
                            } else {
                                if job.isCompleted == true {
                                    startJob?(job)
                                } else {
                                    alertMessage = "Inspection is In-Progress Already, Can't start New. Please Complete the Exisit"
                                    showAlert = true
                                }
                            }
                        } else {
                            startJob?(job)
                        }
                        
                    }) {
                        if job.jobStartDate != nil && job.jobCompletionDate == nil && job.isCompleted == false {
                            IconLabel(labelTitle: "Inspecting", imageName: "started", textColor: .white)
                                .font(ApplicationFont.bold(size: 12).value)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.appPrimary, lineWidth: 1)
                                )
                        } else if job.jobStartDate == nil && job.jobCompletionDate == nil && job.isCompleted == false {
                            IconLabel(labelTitle: "Start", imageName: "play", textColor: .white)
                                .font(ApplicationFont.bold(size: 12).value)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.appPrimary, lineWidth: 1)
                                )
                        } else if job.jobStartDate != nil && job.jobCompletionDate != nil && job.isCompleted == true {
                            IconLabel(labelTitle: "Preview", imageName: "notes", textColor: .white)
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
                } else {
                    Button(action: {
                        if job.isCompleted == true {
                            startJob?(job)
                        }
                    }) {
                        if job.jobStartDate != nil && job.jobCompletionDate != nil && job.isCompleted == true {
                            IconLabel(labelTitle: "Preview", imageName: "notes", textColor: .white)
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
                }
                if (UserDefaultsStore.profileDetail?.userType == 2), !job.isCompleted {
                    Button {
                        updateDetails(job)
                    } label: {
                        Text("Update Details")
                            .font(ApplicationFont.regular(size: 12).value)
                            .foregroundColor(.white)
                            .underline()
                    }
                    .contentShape(Rectangle())
                }
                
                Spacer()
                
                if UserDefaultsStore.profileDetail?.userType == 2 && job.jobAssignedDate == nil  {
                    Button(action: {
                        assignJob(job)
                    }) {
                        Image("handover")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                    }
                    .foregroundColor(.white)
                    .contentShape(Rectangle())
                }

                
                 // Change Request Flow

                if UserDefaultsStore.profileDetail?.userType == 2 && job.status != nil && job.reportPdfUrl != nil  {
                    Button(action: {
                        raiseRequestForJob?(job)
                    }) {
                        Image("request_ic_non")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    .foregroundColor(.white)
                    .contentShape(Rectangle())
                }
                
                
                Button(action: {
                    fetchQRCodeImage(for: job)
                }) {
                    Image("print")
                }
                .foregroundColor(.white)
                .contentShape(Rectangle())
            }
            
            // Expanded Content
            if job.isExpanded ?? false, lastVisits.count > 0 {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Buttons
                    
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
                                IconLabel(labelTitle: job.inspectionFrequency.frequencyName, imageName: "loop", textColor: .white)
                            }
                            
                            HStack(spacing: 5) {
                                IconLabel(labelTitle: "Score \(lastVisit.totalScore)", imageName: "timeline", textColor: .white)
//                                Text(" | ").foregroundColor(.white)
//                                IconLabel(labelTitle: lastVisit.buildTypeName, imageName: "commercial", textColor: .white)
                                Text(" | ").foregroundColor(.white)
                                IconLabel(labelTitle: lastVisit.totalSpentTime.formattedDuration(), imageName: "clock", textColor: .white)
                                Text(" | ").foregroundColor(.white)
                                IconLabel(labelTitle: "Voilations \(lastVisit.totalVoilations)", imageName: "alert", textColor: .warningBG)
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
    
    private func jobStatusView(status: String, color: Color, textColor: Color) -> some View {
        Text(status)
            .font(ApplicationFont.regular(size: 10).value)
            .padding(6)
            .padding(.horizontal, 6)
            .background(color.opacity(0.2))
            .foregroundColor(textColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color, lineWidth: 1)
            )
    }

    private func fetchQRCodeImage(for job: JobModel) {
        guard let qrURL = job.siteQRCodeImageUrl, !qrURL.isEmpty else {
            alertMessage = "QR Code not available for this job."
            showAlert = true
            return
        }
        
        FirebaseFileManager.shared.fetchImage(from: qrURL) { image in
            DispatchQueue.main.async {
                if let image = image {
                    self.showQRDetails(image)
                } else {
                    alertMessage = "Failed to load QR Code."
                    showAlert = true
                }

            }
        }
    }
}


struct QRPreviewView: View {
    @Binding var image: UIImage?
    var onClick: (() -> ())? = nil
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 40) {
                CustomNavBar(
                    title: "QR Code",
                    showBackButton: true,
                    actions: [],
                    backgroundColor: .applicationBGcolor,
                    titleColor: .appPrimary,
                    backAction: {
                        onClick?()
                    }
                )
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                } else {
                    ProgressView("Loading QR...")
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarBackButtonHidden()
            .background(.applicationBGcolor)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
