//
//  SiteListView.swift
//  FPIL
//
//  Created by OrganicFarmers on 30/09/25.
//

import SwiftUI
import AVFoundation

struct SiteListView: View {
    @ObservedObject var viewModel: JobListViewModel
    @EnvironmentObject private var router: Router
    @State private var isScannerPresented = false
    @State private var cameraDenied = false
    @State private var qrCodeImage: UIImage?
    @State private var raiseRequestForJob: JobModel?
    @State private var startJob: Bool = false
    @State private var tempViewModel: JobListViewModel?

    var body: some View {
        ZStack {
                VStack {
                    SearchBarWithNormalAndQRView(text: $viewModel.searchText, onQRScan: {
                        checkCameraPermission {
                            startJob = false
                            isScannerPresented = true
                        }
                    })
                    .sheet(isPresented: $isScannerPresented) {
                        QRScannerRepresentable { result in
                            if startJob {
                                if let selectedJob = viewModel.selectedItem, selectedJob.id == result.trimmingCharacters(in: .whitespacesAndNewlines) {
                                    let startDate = Date()
                                    viewModel.updateStartOrStopInspectionDate(jobModel: selectedJob, updatedItems: ["jobStartDate": startDate]) { error in
                                        if error == nil {
                                            viewModel.selectedItem?.jobStartDate = startDate
                                            tempViewModel = viewModel
                                            router.navigate(to: .inspectionChecklist)
                                        }
                                    }
                                } else {
                                    viewModel.serviceError = NSError(domain: "Site Not Matching", code: 505)
                                }
                            } else {
                                viewModel.searchText = result.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                        }
                        .edgesIgnoringSafeArea(.all)
                    }

                    let all = viewModel.items.count
                    let inprogress = viewModel.items.filter { $0.jobStartDate != nil && $0.jobCompletionDate == nil && $0.isCompleted == false }.count
                    let completed = viewModel.items.filter { $0.isCompleted == true }.count
                    let assignedToday = viewModel.items.filter { $0.jobAssignedDate?.formatedDateAloneAsString() == Date().formatedDateAloneAsString() }.count

                    let dic: Dictionary<String, Any> = ["All Sites": all, "Today": assignedToday, "InProgress": inprogress, "Completed": completed]
                    let allKeys: [String] = ["All Sites", "Today", "InProgress", "Completed"]
                    SmallCardInfoView(cardInfo: dic, keys: allKeys)
                        .frame(maxWidth: .infinity)

                    Group {
                        if viewModel.filteredItems.isEmpty {
                            NoDataView(message: "No Inspections Available")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(viewModel.filteredItems, id:\.id) { job in
                                        JobCardView(job: job) {
                                            withAnimation { viewModel.toggleExpand(for: job) }
                                        } updateDetails: { updateJob in
                                        } showQRDetails: { qrImage in
                                            qrCodeImage = qrImage
                                            router.navigate(to: .showQRImage)
                                        } assignJob: { updateJob in
                                        } raiseRequestForJob: { requestForJob in
                                            raiseRequestForJob = requestForJob
                                            router.navigate(to: .raiseRequest)
                                        } startJob: { startedJob in
                                            if startedJob.jobStartDate != nil && startedJob.jobCompletionDate == nil && startedJob.isCompleted == false {
                                                viewModel.selectedItem = startedJob
                                                router.navigate(to: .inspectionChecklist)
                                            } else if startedJob.jobStartDate != nil && startedJob.jobCompletionDate != nil && startedJob.isCompleted == true {
                                                viewModel.selectedItem = startedJob
                                                router.navigate(to: .inspectionChecklist)
                                            } else {
                                                startJob = true
                                                viewModel.selectedItem = startedJob
                                                tempViewModel = viewModel
                                                isScannerPresented = true
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                                .background(Color.clear.edgesIgnoringSafeArea(.all))
                            } .refreshable {
                                await viewModel.refreshOrganisations()
                            }
                        }
                    }
                }
                .frame(alignment: .top)
                .navigationBarBackButtonHidden(true)
                .background(.applicationBGcolor)
                .ignoresSafeArea(edges: .bottom)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .createSite:
                        CreateOrUpdateSiteView(viewModel: viewModel) {
                            DispatchQueue.main.async { router.pop() }
                        }
                    case .showQRImage:
                        QRPreviewView(image: $qrCodeImage) {
                            qrCodeImage = nil
                            DispatchQueue.main.async { router.pop() }
                        }
                    case .raiseRequest:
                        RequestView(viewModel: viewModel) {
                            raiseRequestForJob = nil
                            DispatchQueue.main.async { router.pop() }
                        }
                    case .inspectionChecklist:
                        if let tempViewModel {
                            InspectionChecklistView(viewModel: tempViewModel) {
                                self.tempViewModel = nil
                                DispatchQueue.main.async { router.pop() }
                                Task { await viewModel.refreshOrganisations() }
                            }
                        } else {
                            InspectionChecklistView(viewModel: viewModel) {
                                DispatchQueue.main.async { router.pop() }
                                Task { await viewModel.refreshOrganisations() }
                            }
                        }
                    default:
                        EmptyView()
                    }
                }
                .alert(isPresented: $cameraDenied) {
                    Alert(
                        title: Text("Camera Access Denied"),
                        message: Text("Please enable camera access in Settings to scan QR codes."),
                        primaryButton: .default(Text("Open Settings")) {
                            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                            UIApplication.shared.open(url)
                        },
                        secondaryButton: .cancel()
                    )
                }


                if viewModel.isLoading {
                    LoadingView()
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.isLoading)
                }

                Group {
                    if let error = viewModel.serviceError {
                        let nsError = error as NSError
                        let title = nsError.code == 92001 ? "No Internet Connection" : "Error"
                        let message = nsError.code == 92001
                        ? "Please check your WiFi or cellular data."
                        : nsError.localizedDescription

                        CustomAlertView(
                            title: title,
                            message: message,
                            primaryButtonTitle: "OK",
                            primaryAction: { viewModel.serviceError = nil },
                            secondaryButtonTitle: nil,
                            secondaryAction: nil
                        )
                    }
                }

            }
    }

    private func checkCameraPermission(granted: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            granted()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { ok in
                DispatchQueue.main.async {
                    if ok { granted() } else { cameraDenied = true }
                }
            }
        case .denied, .restricted:
            cameraDenied = true
        @unknown default:
            cameraDenied = true
        }
    }
}

//#Preview {
//    SiteListView(viewModel: JobListViewModel())
//}
