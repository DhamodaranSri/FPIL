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
    
    var lastVisits: [LastVisit] {
        job.lastVist ?? []
    }
    
    init(job: JobModel, onToggle: @escaping () -> Void, updateDetails: @escaping (JobModel) -> Void, showQRDetails: @escaping (UIImage) -> Void, assignJob: @escaping (JobModel) -> Void, raiseRequestForJob: ((JobModel) -> Void)? = nil, startJob: ((JobModel) -> Void)? = nil, showAlert: Bool = false, alertMessage: String = "") {
        self.job = job
        self.onToggle = onToggle
        self.updateDetails = updateDetails
        self.showAlert = showAlert
        self.alertMessage = alertMessage
        self.showQRDetails = showQRDetails
        self.assignJob = assignJob
        self.raiseRequestForJob = raiseRequestForJob
        self.startJob = startJob
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
                        Text("Assigned To: " + (job.inspectorName ?? ""))
                            .font(ApplicationFont.regular(size: 12).value)
                            .foregroundColor(.white)
                    }
                    
                }
                Spacer()
                if let dueDate = job.lastDateToInspection, job.isCompleted == false {
                    let days = abs(Calendar.current.dateComponents([.day], from: dueDate, to: Date()).day!)
                    
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
                if job.isCompleted {
                    Text("Completed")
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
            
            // Contact Info
            HStack(spacing: 16) {
                IconLabel(labelTitle: "\(job.firstName) \(job.lastName)", imageName: "user", textColor: .white)
                Button(action: {
                    alertMessage = "Under Construction"
                    showAlert = true
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
                                alertMessage = "Inspection is In-Progress Already, Can't start New. Please Complete the Exisit"
                                showAlert = true
                            }
                        } else {
                            startJob?(job)
                        }
                        
                    }) {
                        if job.jobStartDate != nil && job.jobCompletionDate == nil && job.isCompleted == false {
                            IconLabel(labelTitle: "Stop", imageName: "stop", textColor: .white)
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
                }
                if (UserDefaultsStore.profileDetail?.userType == 2) {
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

                /*
                 // Change Request Flow

                if UserDefaultsStore.profileDetail?.userType != 2 && job.isCompleted == false  {
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
                */
                
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
                                IconLabel(labelTitle: "\(lastVisit.totalScore)", imageName: "timeline", textColor: .white)
//                                Text(" | ").foregroundColor(.white)
//                                IconLabel(labelTitle: lastVisit.buildTypeName, imageName: "commercial", textColor: .white)
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
