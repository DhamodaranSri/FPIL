//
//  ClientListView.swift
//  FPIL
//
//  Created by OrganicFarmers on 24/10/25.
//

import SwiftUI

struct ClientListView: View {
    @ObservedObject var viewModel: ClientListViewModel
    @EnvironmentObject private var router: Router
    @State private var selectedPdfURL: URL?
    @State private var selectedQRImageJob: UIImage?
    @State var selectedItem: ClientModel?
    @StateObject private var jobViewModel = JobListViewModel()

    var body: some View {
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
                                            selectedItem = client
                                            viewModel.selectedItem = selectedItem
                                            router.navigate(to: isButton ? .createInspection : .createClient)
                                        } onTapCell: { client in
                                            selectedItem = client
                                            viewModel.selectedItem = selectedItem
                                            router.navigate(to: .clientDetails)
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
                    Task { await viewModel.refreshClientsList() }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .createClient:
                        CreateOrUpdateClientView(viewModel: viewModel) {
                            selectedItem = nil
                            viewModel.selectedItem = nil
                            Task { await viewModel.refreshClientsList() }
                            DispatchQueue.main.async { router.pop() }
                        }
                    case .createInspection:
                        InvoiceGenerationView(viewModel: InvoiceViewModel(items: UserDefaultsStore.servicesPerfomerdTypes ?? [], client: viewModel.selectedItem)) {
                            selectedItem = nil
                            viewModel.selectedItem = nil
                            Task { await viewModel.refreshClientsList() }
                            DispatchQueue.main.async { router.pop() }
                        }
                    case .clientDetails:
                        ClientDetailView(viewModel: ClientDetailViewModel(selectedItem: selectedItem)) {
                            selectedItem = nil
                            viewModel.selectedItem = nil
                            Task { await viewModel.refreshClientsList() }
                            router.pop()
                        } selectedPdfURL: { url in
                            selectedPdfURL = url
                        } selectedJob: { job in
                            jobViewModel.selectedItem = job
                        } selectedClient: { client, invoice in
                            viewModel.selectedClient = client
                            viewModel.selectedInvoice = invoice
                            router.navigate(to: .createNewInspection)
                        } selectedQRImage: { qrImage in
                            selectedQRImageJob = qrImage
                        }
                    case .pdfViewer:
                        PDFViewer(url: $selectedPdfURL) {
                            selectedPdfURL = nil
                            DispatchQueue.main.async { router.pop() }
                        }
                    case .inspectionChecklist:
                        InspectionDetailsPage(viewModel: jobViewModel) {
                            DispatchQueue.main.async { router.pop() }
                        } selectedPdfURL: { url in
                            selectedPdfURL = url
                        }
                    case .createNewInspection:
                        CreateInspection(viewModel: jobViewModel, clientModel: viewModel.selectedClient, inspectionForInvoice: viewModel.selectedInvoice) {
                            DispatchQueue.main.async {
                                viewModel.selectedClient = nil
                                viewModel.selectedInvoice = nil
                                router.pop()
                            }
                        }
                    case .qrCodePage:
                        QRPreviewView(image: $selectedQRImageJob) {
                            selectedQRImageJob = nil
                            DispatchQueue.main.async { router.pop() }
                        }
                    default:
                        EmptyView()
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
                            primaryAction: { viewModel.serviceError = nil },
                            secondaryButtonTitle: nil,
                            secondaryAction: nil
                        )
                    }
                }

            }
    }
}
