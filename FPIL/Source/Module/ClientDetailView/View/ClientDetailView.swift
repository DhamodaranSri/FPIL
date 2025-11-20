//
//  ClientDetailView.swift
//  FPIL
//
//  Created by OrganicFarmers on 30/10/25.
//

import SwiftUI

struct ClientDetailView: View {
    @ObservedObject var viewModel: ClientDetailViewModel
    @State private var selectedFilter: CustomerDetailFilter = .currentInspections
    @State private var selectedPdfURLClient: URL?
    @State private var selectedQRImageJob: UIImage?
    @Binding var path:NavigationPath
    var onClick: (() -> ())? = nil
    var selectedPdfURL: ((URL) -> Void)? = nil
    var selectedQRImage: ((UIImage) -> Void)? = nil
    var selectedJob: ((JobModel) -> Void)? = nil
    var selectedClient: ((ClientModel, InvoiceDetails) -> Void)? = nil
    var isBackButtonShown: Bool = true
    var jobViewModel: JobListViewModel = JobListViewModel()
    
    
    init(viewModel: ClientDetailViewModel, path: Binding<NavigationPath>, isBackButtonShown: Bool = true, onClick: (() -> ())? = nil, selectedPdfURL: ((URL) -> Void)? = nil, selectedJob: ((JobModel) -> Void)? = nil, selectedClient: ((ClientModel, InvoiceDetails) -> Void)? = nil, selectedQRImage: ((UIImage) -> Void)? = nil) {
        self.viewModel = viewModel
        self._path = path
        self.onClick = onClick
        self.selectedPdfURL = selectedPdfURL
        self.selectedJob = selectedJob
        self.selectedClient = selectedClient
        self.isBackButtonShown = isBackButtonShown
        self.selectedQRImage = selectedQRImage
    }
    
    var body: some View {
        if isBackButtonShown {
            customClientDetailView()
        } else {
            NavigationStack(path: _path) {
                customClientDetailView()
            }
        }
    }
    
    @ViewBuilder
    private func customClientDetailView() -> some View {
        ZStack {
            VStack {
                CustomNavBar(
                    title: viewModel.selectedItem?.fullName ?? viewModel.selectedItem?.firstName ?? "",
                    showBackButton: isBackButtonShown,
                    actions: isBackButtonShown ? [] : [
                        NavBarAction(icon: "logout") {
                            viewModel.signout()
                        }
                    ],
                    backgroundColor: .applicationBGcolor,
                    titleColor: .appPrimary,
                    backAction: {
                        onClick?()
                    }
                )
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(CustomerDetailFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .tint(.white)
                .onAppear {
                    let selectedAttributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.white,
                        .font: ApplicationFont.regular(size: 12).uiValue
                    ]
                    let normalAttributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.lightGray,
                        .font: ApplicationFont.regular(size: 12).uiValue
                    ]
                    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.appPrimary)
                    UISegmentedControl.appearance().backgroundColor = UIColor(Color.appPrimary.opacity(0.3))
                    UISegmentedControl.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
                    UISegmentedControl.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
                }
                Group {
                    if selectedFilter == .currentInspections, viewModel.currentInspectionItems.isEmpty {
                        NoDataView(message: "No Inspections Available")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if selectedFilter == .inspectionsHistory, viewModel.inspectionItems.isEmpty {
                        NoDataView(message: "No Inspections Available")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if selectedFilter == .estimatedInvoices, viewModel.invoiceItems.filter ({ invoice in
                        // Common filters
                        let isNotPaid = invoice.isPaid == false
                        let isInspectionEmpty = (invoice.inspectionsId?.count ?? 0) == 0
                        
                        // Apply status condition ONLY if userType == 5
                        let statusMatch =
                        UserDefaultsStore.profileDetail?.userType == 5
                        ? (invoice.status == 1 || invoice.status == 2)
                        : true   // show all statuses when userType != 5
                        
                        return isNotPaid && isInspectionEmpty && statusMatch

//                        $0.isPaid == false && ($0.status == 1 || $0.status == 2) && ($0.inspectionsId?.count ?? 0) == 0
                    }).count == 0 {
                        NoDataView(message: "No Estimated Invoices Available")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack (spacing: 16) {
                                if selectedFilter == .currentInspections {
                                    ForEach(viewModel.currentInspectionItems, id: \.id) { job in
                                        StatusInspectionCell(job: job) { jobModel in
                                            if !isBackButtonShown {
                                                jobViewModel.selectedItem = jobModel
                                                if path.count > 0 {
                                                    path.removeLast()
                                                }
                                            }
                                            
                                            selectedJob?(jobModel)
                                            path.append("inspectionChecklistPage")
                                        } qrcode: { qrImage in
                                            if !isBackButtonShown {
                                                selectedQRImageJob = qrImage
                                                if path.count > 0 {
                                                    path.removeLast()
                                                }
                                            }
                                            selectedQRImage?(qrImage)
                                            path.append("QRCodePage")
                                        }
                                    }
                                } else if selectedFilter == .inspectionsHistory {
                                    ForEach(viewModel.inspectionItems, id: \.id) { job in
                                        StatusInspectionCell(job: job) { jobModel in
                                            if !isBackButtonShown {
                                                jobViewModel.selectedItem = jobModel
                                                if path.count > 0 {
                                                    path.removeLast()
                                                }
                                            }
                                            selectedJob?(jobModel)
                                            path.append("inspectionChecklistPage")
                                        } qrcode: { jobModel in }
                                    }
                                } else if selectedFilter == .estimatedInvoices {
                                    ForEach(viewModel.invoiceItems.filter { invoice in
                                        // Common filters
                                        let isNotPaid = invoice.isPaid == false
                                        let isInspectionEmpty = (invoice.inspectionsId?.count ?? 0) == 0
                                        
                                        // Apply status condition ONLY if userType == 5
                                        let statusMatch =
                                        UserDefaultsStore.profileDetail?.userType == 5
                                        ? (invoice.status == 1 || invoice.status == 2)
                                        : true   // show all statuses when userType != 5
                                        
                                        return isNotPaid && isInspectionEmpty && statusMatch
                                        
                                    }, id: \.id) { invoice in
                                        InvoiceListCell(invoice: invoice) { invoiceModel in
                                
                                        } onPrintInvoice: { printInvoice in
                                            if let pdfURL = printInvoice.invoicePDFUrl {
                                                if !isBackButtonShown {
                                                    selectedPdfURLClient = URL(string: pdfURL)
                                                    if path.count > 0 {
                                                        path.removeLast()
                                                    }
                                                }
                                                selectedPdfURL?(URL(string: pdfURL)!)
                                                path.append("PDFViewer")
                                            }
                                        } onDeleteInvoice: { invoice in
                                            viewModel.deleteInvoiceItem(invoiceItem: invoice) { error in
                                                onClick?()
                                            }
                                        } onProceedPaymentInvoice: { invoice, status in
                                            viewModel.paymentStatusUpdate(invoiceItem: invoice, status: status) { error in
                                                if error == nil {
                                                    Task {
                                                        await viewModel.refreshClientsList()
                                                    }
                                                }
                                            }
                                        } createInspection: { invoice in
                                            let siteId = viewModel.createNewSiteId()
                                            var selectedInvoice = invoice
                                            if let client = viewModel.createClientModelwithNewInvoice(invoiceItem: selectedInvoice, siteId: siteId) {
                                                selectedInvoice.inspectionsId = siteId
                                                selectedInvoice.isPaid = true
                                                selectedInvoice.paidDate = Date()
                                                selectedClient?(client, selectedInvoice)
                                            }
                                        }
                                    }
                                    
                                }
                            }.padding(.horizontal)
                                .padding(.bottom, 20)
                                .background(Color.clear.edgesIgnoringSafeArea(.all))
                        }.refreshable {
                            await viewModel.refreshClientsList()
                        }.padding(.vertical, 15)
                            .padding(.horizontal, 10)
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarBackButtonHidden()
            .background(.applicationBGcolor)
            .navigationDestination(for: String.self) { value in
                if !isBackButtonShown {
                    if value == "inspectionChecklistPage" {
                        InspectionDetailsPage(viewModel: jobViewModel, path: $path) {
                            jobViewModel.selectedItem = nil
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        } selectedPdfURL: { url in
                            selectedPdfURLClient = url
                        }
                    } else if value == "PDFViewer" {
                        PDFViewer(url: $selectedPdfURLClient) {
                            selectedPdfURLClient = nil
                            DispatchQueue.main.async {
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

    
    func saveOrganisation() {
        
    }
}


enum CustomerDetailFilter: String, CaseIterable, Identifiable {
    case currentInspections = "Current Inspections"
    case inspectionsHistory = "Inspections Hisotry"
    case estimatedInvoices = "Estimated Invoices"
    
    var id: String { rawValue }
}
