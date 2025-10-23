//
//  InspectionHistoryListView.swift
//  FPIL
//
//  Created by OrganicFarmers on 16/10/25.
//

import SwiftUI
import AVFoundation

struct InspectionHistoryListView: View {
    @Binding var path:NavigationPath
    @ObservedObject var viewModel: JobListViewModel
    @State private var isScannerPresented = false
    @State private var cameraDenied = false
    @State private var qrCodeImage: UIImage?
    @State private var selectedFilter: InspectionFilter = .review
    @State private var selectedPdfURL: URL?
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack {
                    SearchBarWithNormalAndQRView(text: $viewModel.searchText, onQRScan: {
                        checkCameraPermission {
                            isScannerPresented = true
                        }
                    })
                    .sheet(isPresented: $isScannerPresented) {
                        QRScannerRepresentable { result in
                            // assign to search field (trim if needed)
                            viewModel.searchText = result.trimmingCharacters(in: .whitespacesAndNewlines)
                            // you can also trigger a search action here
                            // performSearch(with: searchText)
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
                                        case .review:
                                            return job.status == nil
                                        case .approved:
                                            return job.status == 1
                                        case .decline:
                                            return job.status == 2
                                        case .revision:
                                            return job.status == 3
                                        }
                                    }, id: \.id) { job in
                                        JobCardView(job: job) {
                                            withAnimation {
                                                viewModel.toggleExpand(for: job)
                                            }
                                        } updateDetails: { updateJob in
                                            
                                        } showQRDetails: { qrImage in
                                            qrCodeImage = qrImage
                                            
                                            if path.count > 0 {
                                                path.removeLast()
                                            }
                                            path.append("showQRImage")
                                        } assignJob: { updateJob in
                                        } raiseRequestForJob: { requestForJob in
                                            if let pdfURL = requestForJob.reportPdfUrl {
                                                selectedPdfURL = URL(string: pdfURL)
                                                if path.count > 0 {
                                                    path.removeLast()
                                                }
                                                path.append("PDFViewer")
                                                
//                                                UIApplication.shared.open(URL(string: pdfURL)!)
//                                                let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
//                                                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
//                                                    rootVC.present(activityVC, animated: true)
//                                                }
                                            }
                                        } startJob: { startedJob in
                                            if startedJob.jobStartDate != nil && startedJob.jobCompletionDate != nil && startedJob.isCompleted == true {
                                                viewModel.selectedItem = startedJob
                                                
                                                if path.count > 0 {
                                                    path.removeLast()
                                                }
                                                path.append("inspectionChecklistPage")
                                            }
                                        }
                                    }
                                    
//                                    ForEach(viewModel.filteredItems, id:\.id) { job in
//                                        JobCardView(job: job) {
//                                            withAnimation {
//                                                viewModel.toggleExpand(for: job)
//                                            }
//                                        } updateDetails: { updateJob in
//                                            
//                                        } showQRDetails: { qrImage in
//                                            qrCodeImage = qrImage
//                                            
//                                            if path.count > 0 {
//                                                path.removeLast()
//                                            }
//                                            path.append("showQRImage")
//                                        } assignJob: { updateJob in
//                                        } raiseRequestForJob: { requestForJob in
//                                            
//                                        } startJob: { startedJob in
//                                            if startedJob.jobStartDate != nil && startedJob.jobCompletionDate != nil && startedJob.isCompleted == true {
//                                                viewModel.selectedItem = startedJob
//                                                
//                                                if path.count > 0 {
//                                                    path.removeLast()
//                                                }
//                                                path.append("inspectionChecklistPage")
//                                            }
//                                        }
//                                    }
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
                .navigationDestination(for: String.self) { value in
                    if value == "showQRImage" {
                        QRPreviewView(image: $qrCodeImage) {
                            qrCodeImage = nil
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        }
                    } else if value == "inspectionChecklistPage" {
                        InspectionChecklistView(viewModel: viewModel) {
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        }
                    } else if value == "PDFViewer" {
                        
                        PDFViewer(url: $selectedPdfURL) {
                            selectedPdfURL = nil
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        }
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
                            primaryAction: {
                                viewModel.serviceError = nil
                            },
                            secondaryButtonTitle: nil,
                            secondaryAction: nil
                        )
                    }
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
