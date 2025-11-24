//
//  ClientListView.swift
//  FPIL
//
//  Created by OrganicFarmers on 24/10/25.
//

import SwiftUI

struct ClientListView: View {
    @ObservedObject var viewModel: ClientListViewModel
    @Binding var path:NavigationPath
    @State private var selectedPdfURL: URL?
    @State private var selectedQRImageJob: UIImage?
    var jobViewModel: JobListViewModel = JobListViewModel()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack {
                    SearchView(searchText: $viewModel.searchText, searchPlaceholder: "Search for Client")
                    Group {
                        if viewModel.filteredItems.isEmpty {
                            NoDataView(message: "No Clients Available")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            HorizontalClientFilterView(viewModel: viewModel)
                                .frame(height: 40, alignment: .top)
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(viewModel.filteredItems, id:\.id) { clientModel in
                                        ClientListCell(client: clientModel) { client, isButton in
                                            viewModel.selectedItem = client
                                            if path.count > 0 {
                                                path.removeLast()
                                            }
                                            path.append(isButton ? "createInspection" : "createClients")
                                        } onTapCell: { client in
                                            viewModel.selectedItem = client
                                            if path.count > 0 {
                                                path.removeLast()
                                            }
                                            path.append("ClientDetails")
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                                .background(Color.clear.edgesIgnoringSafeArea(.all))
                            } .refreshable {
                                await viewModel.refreshClientsList()
                            }
                        }
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.refreshClientsList()
                    }
                }
                .navigationDestination(for: String.self) { value in
                    if value == "createClients" {
                        CreateOrUpdateClientView(viewModel: viewModel) {
                            viewModel.selectedItem = nil
                            Task {
                                await viewModel.refreshClientsList()
                            }
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        }
                    } else if value == "createInspection" {
                        InvoiceGenerationView(viewModel: InvoiceViewModel(items: UserDefaultsStore.servicesPerfomerdTypes ?? [], client: viewModel.selectedItem)) {
                            viewModel.selectedItem = nil
                            Task {
                                await viewModel.refreshClientsList()
                            }
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        }
                    } else if value == "ClientDetails" {
                        ClientDetailView(viewModel: ClientDetailViewModel(selectedItem: viewModel.selectedItem), path: $path) {
                            viewModel.selectedItem = nil
                            Task {
                                await viewModel.refreshClientsList()
                            }
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        } selectedPdfURL: { url in
                            selectedPdfURL = url
                        } selectedJob: { job in
                            jobViewModel.selectedItem = job
                        } selectedClient: { client, invoice in
                            DispatchQueue.main.async {
                                viewModel.selectedClient = client
                                viewModel.selectedInvoice = invoice
                                if path.count > 0 {
                                    path.removeLast()
                                }
                                path.append("createNewInspection")
                            }
                        } selectedQRImage: { qrImage in
                            selectedQRImageJob = qrImage
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
                    } else if value == "inspectionChecklistPage" {
                        InspectionDetailsPage(viewModel: jobViewModel, path: $path) {
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        } selectedPdfURL: { url in
                            selectedPdfURL = url
                        }
//                        InspectionChecklistView(viewModel: jobViewModel, isReadable: true) {
//                            DispatchQueue.main.async {
//                                if path.count > 0 {
//                                    path.removeLast()
//                                }
//                            }
//                        }
                    } else if value == "createNewInspection" {
                        CreateInspection(viewModel: jobViewModel, clientModel: viewModel.selectedClient, inspectionForInvoice: viewModel.selectedInvoice) {
                            DispatchQueue.main.async {
                                viewModel.selectedClient = nil
                                viewModel.selectedInvoice = nil
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        }
                    } else if value == "QRCodePage" {
                        QRPreviewView(image: $selectedQRImageJob) {
                            selectedQRImageJob = nil
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        }
                    }
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
}
