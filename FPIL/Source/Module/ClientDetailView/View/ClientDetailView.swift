//
//  ClientDetailView.swift
//  FPIL
//
//  Created by OrganicFarmers on 30/10/25.
//

import SwiftUI

struct ClientDetailView: View {
    @ObservedObject var viewModel: ClientDetailViewModel
    @EnvironmentObject private var router: Router
    @State private var selectedFilter: CustomerDetailFilter = .currentInspections
    @State private var selectedPdfURLClient: URL?
    @State private var selectedQRImageJob: UIImage?
    @StateObject private var jobViewModel = JobListViewModel()
    var onClick: (() -> ())?
    var selectedPdfURL: ((URL) -> Void)?
    var selectedQRImage: ((UIImage) -> Void)?
    var selectedJob: ((JobModel) -> Void)?
    var selectedClient: ((ClientModel, InvoiceDetails) -> Void)?
    var isBackButtonShown: Bool = true

    init(viewModel: ClientDetailViewModel,
         isBackButtonShown: Bool = true,
         onClick: (() -> ())? = nil,
         selectedPdfURL: ((URL) -> Void)? = nil,
         selectedJob: ((JobModel) -> Void)? = nil,
         selectedClient: ((ClientModel, InvoiceDetails) -> Void)? = nil,
         selectedQRImage: ((UIImage) -> Void)? = nil) {
        self.viewModel = viewModel
        self.isBackButtonShown = isBackButtonShown
        self.onClick = onClick
        self.selectedPdfURL = selectedPdfURL
        self.selectedJob = selectedJob
        self.selectedClient = selectedClient
        self.selectedQRImage = selectedQRImage
    }

    var body: some View {
        ZStack {
            VStack {
                CustomNavBar(
                    title: viewModel.selectedItem?.fullName ?? viewModel.selectedItem?.firstName ?? "",
                    showBackButton: isBackButtonShown,
                    actions: isBackButtonShown ? [] : [
                        NavBarAction(icon: "logout") { viewModel.signout() }
                    ],
                    backgroundColor: .applicationBGcolor,
                    titleColor: .appPrimary,
                    backAction: { onClick?() }
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
                    } else if selectedFilter == .estimatedInvoices, viewModel.invoiceItems.filter({ invoice in
                        let isNotPaid = invoice.isPaid == false
                        let isInspectionEmpty = (invoice.inspectionsId?.count ?? 0) == 0
                        let statusMatch = UserDefaultsStore.profileDetail?.userType == 5
                            ? (invoice.status == 1 || invoice.status == 2)
                            : true
                        return isNotPaid && isInspectionEmpty && statusMatch
                    }).count == 0 {
                        NoDataView(message: "No Estimated Invoices Available")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                if selectedFilter == .currentInspections {
                                    ForEach(viewModel.currentInspectionItems, id: \.id) { job in
                                        StatusInspectionCell(job: job) { jobModel in
                                            jobViewModel.selectedItem = jobModel
                                            selectedJob?(jobModel)
                                            router.navigate(to: .inspectionChecklist)
                                        } qrcode: { qrImage in
                                            selectedQRImageJob = qrImage
                                            selectedQRImage?(qrImage)
                                            router.navigate(to: .qrCodePage)
                                        }
                                    }
                                } else if selectedFilter == .inspectionsHistory {
                                    ForEach(viewModel.inspectionItems, id: \.id) { job in
                                        StatusInspectionCell(job: job) { jobModel in
                                            jobViewModel.selectedItem = jobModel
                                            selectedJob?(jobModel)
                                            router.navigate(to: .inspectionChecklist)
                                        } qrcode: { _ in }
                                    }
                                } else if selectedFilter == .estimatedInvoices {
                                    ForEach(viewModel.invoiceItems.filter { invoice in
                                        let isNotPaid = invoice.isPaid == false
                                        let isInspectionEmpty = (invoice.inspectionsId?.count ?? 0) == 0
                                        let statusMatch = UserDefaultsStore.profileDetail?.userType == 5
                                            ? (invoice.status == 1 || invoice.status == 2)
                                            : true
                                        return isNotPaid && isInspectionEmpty && statusMatch
                                    }, id: \.id) { invoice in
                                        InvoiceListCell(invoice: invoice) { _ in
                                        } onPrintInvoice: { printInvoice in
                                            if let pdfURL = printInvoice.invoicePDFUrl {
                                                selectedPdfURLClient = URL(string: pdfURL)
                                                selectedPdfURL?(URL(string: pdfURL)!)
                                                router.navigate(to: .pdfViewer)
                                            }
                                        } onDeleteInvoice: { invoice in
                                            viewModel.deleteInvoiceItem(invoiceItem: invoice) { _ in onClick?() }
                                        } onProceedPaymentInvoice: { invoice, status in
                                            viewModel.paymentStatusUpdate(invoiceItem: invoice, status: status) { error in
                                                if error == nil {
                                                    Task { await viewModel.refreshClientsList() }
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
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .inspectionChecklist:
                    InspectionDetailsPage(viewModel: jobViewModel) {
                        jobViewModel.selectedItem = nil
                        router.pop()
                    } selectedPdfURL: { url in
                        selectedPdfURLClient = url
                    }
                case .pdfViewer:
                    PDFViewer(url: $selectedPdfURLClient) {
                        selectedPdfURLClient = nil
                        router.pop()
                    }
                case .qrCodePage:
                    QRPreviewView(image: $selectedQRImageJob) {
                        selectedQRImageJob = nil
                        router.pop()
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


enum CustomerDetailFilter: String, CaseIterable, Identifiable {
    case currentInspections = "Current Inspections"
    case inspectionsHistory = "Inspections Hisotry"
    case estimatedInvoices = "Estimated Invoices"

    var id: String { rawValue }
}
