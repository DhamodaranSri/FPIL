//
//  InspectionHistoryListView.swift
//  FPIL
//
//  Created by OrganicFarmers on 16/10/25.
//

import SwiftUI
import AVFoundation

struct InspectionHistoryListView: View {
    @ObservedObject var viewModel: JobListViewModel
    @EnvironmentObject private var router: Router
    @State private var isScannerPresented = false
    @State private var cameraDenied = false
    @State private var qrCodeImage: UIImage?
    @State private var selectedFilter: InspectionFilter = .review
    @State private var selectedPdfURL: URL?

    var body: some View {
        ZStack {
                VStack {
                    SearchBarWithNormalAndQRView(text: $viewModel.searchText, onQRScan: {
                        checkCameraPermission {
                            isScannerPresented = true
                        }
                    })
                    .sheet(isPresented: $isScannerPresented) {
                        QRScannerRepresentable { result in
                            viewModel.searchText = result.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        .edgesIgnoringSafeArea(.all)
                    }

                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(InspectionFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .tint(.white)
                    .onAppear {
                        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.appPrimary)
                        UISegmentedControl.appearance().backgroundColor = UIColor(Color.appPrimary.opacity(0.3))
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
                    }

                    Group {
                        if viewModel.filteredItems.isEmpty {
                            NoDataView(message: "No Inspections Available")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(viewModel.filteredItems.filter { job in
                                        switch selectedFilter {
                                        case .review:   return job.status == nil
                                        case .approved: return job.status == 1
                                        case .decline:  return job.status == 2
                                        case .revision: return job.status == 3
                                        }
                                    }, id: \.id) { job in
                                        JobCardView(job: job, isHistory: true) {
                                            withAnimation { viewModel.toggleExpand(for: job) }
                                        } updateDetails: { _ in
                                        } showQRDetails: { qrImage in
                                            qrCodeImage = qrImage
                                            router.navigate(to: .showQRImage)
                                        } assignJob: { _ in
                                        } raiseRequestForJob: { requestForJob in
                                            if let pdfURL = requestForJob.reportPdfUrl {
                                                selectedPdfURL = URL(string: pdfURL)
                                                router.navigate(to: .pdfViewer)
                                            }
                                        } startJob: { startedJob in
                                            if startedJob.jobStartDate != nil && startedJob.jobCompletionDate != nil && startedJob.isCompleted == true {
                                                viewModel.selectedItem = startedJob
                                                router.navigate(to: .inspectionChecklist)
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
                    case .reviewInspections:
                        DocReviewChecklistView(viewModel: viewModel) {
                            DispatchQueue.main.async { router.pop() }
                        }
                    case .showQRImage:
                        QRPreviewView(image: $qrCodeImage) {
                            qrCodeImage = nil
                            DispatchQueue.main.async { router.pop() }
                        }
                    case .inspectionChecklist:
                        InspectionChecklistView(viewModel: viewModel) {
                            DispatchQueue.main.async { router.pop() }
                        }
                    case .pdfViewer:
                        PDFViewer(url: $selectedPdfURL) {
                            selectedPdfURL = nil
                            DispatchQueue.main.async { router.pop() }
                        }
                    case .aiChecklist:
                        AIChecklistDetailView(viewModel: viewModel, checklist: viewModel.checkList) {
                            DispatchQueue.main.async { router.pop() }
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
                .onAppear {
                    Task { await viewModel.refreshOrganisations() }
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


enum InspectionFilter: String, CaseIterable, Identifiable {
    case review = "Review"
    case approved = "Approved"
    case decline = "Decline"
    case revision = "Revision"

    var id: String { rawValue }
}
