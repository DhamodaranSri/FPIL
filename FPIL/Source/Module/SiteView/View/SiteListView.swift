//
//  SiteListView.swift
//  FPIL
//
//  Created by OrganicFarmers on 30/09/25.
//

import SwiftUI
import AVFoundation

struct SiteListView: View {
    @Binding var path:NavigationPath
    @ObservedObject var viewModel: JobListViewModel
    @State private var isScannerPresented = false
    @State private var hasCameraPermissionChecked = false
    @State private var cameraDenied = false
    @State private var qrCodeImage: UIImage?
    @State private var raiseRequestForJob: JobModel?
    
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
                    
                    let all = viewModel.items.count
//                    let today = viewModel.items.filter { $0.jobAssignedDate?.convertDateAloneFromFullDateFormat() == Date().convertDateAloneFromFullDateFormat() }.count
                    let inprogress = viewModel.items.filter { ($0.lastVist?.count ?? 0) > 0 && $0.isCompleted == true }.count
                    let completed = viewModel.items.filter { $0.isCompleted == true }.count
                    
                    let dic: Dictionary<String, Any> = ["All Sites": all, "Today": "0", "InProgress": inprogress, "Completed": completed]
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
                                            raiseRequestForJob = requestForJob
                                            if path.count > 0 {
                                                path.removeLast()
                                            }
                                            path.append("raiseRequest")
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
                .navigationDestination(for: String.self) { value in
                    if value == "createSites" {
                        CreateOrUpdateSiteView(viewModel: viewModel) {
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        }
                    } else if value == "showQRImage" {
                        QRPreviewView(image: $qrCodeImage) {
                            qrCodeImage = nil
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        }
                    } else if value == "raiseRequest" {
                        RequestView(viewModel: viewModel) {
                            raiseRequestForJob = nil
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

//#Preview {
//    SiteListView(, path: <#Binding<NavigationPath>#>)
//}
