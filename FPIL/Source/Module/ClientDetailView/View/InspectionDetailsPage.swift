//
//  InspectionDetailsPage.swift
//  FPIL
//
//  Created by OrganicFarmers on 06/11/25.
//

import SwiftUI

struct InspectionDetailsPage: View {
    @ObservedObject var viewModel: JobListViewModel
    @State private var selectedFilter: InspectionDetailFilter = .checklist
    var onClick: (() -> ())? = nil
    
    var body: some View {
        ZStack {
            VStack {
                CustomNavBar(
                    title: "Inspection Details",
                    showBackButton: true,
                    actions: [],
                    backgroundColor: .applicationBGcolor,
                    titleColor: .appPrimary,
                    backAction: {
                        viewModel.selectedItem = nil
                        onClick?()
                    }
                )
                
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(InspectionDetailFilter.allCases) { filter in
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
                    if selectedFilter == .invoiceHistory, (viewModel.selectedItem?.invoiceDetails?.count ?? 0) == 0 {
                        NoDataView(message: "No Invoice Available")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            if selectedFilter == .checklist {
                                InspectionChecklistView(viewModel: viewModel, isReadable: true, isNavigationNeeded: false) {
                                }
                            } else {
                                VStack (spacing: 16) {
                                    ForEach(viewModel.selectedItem?.invoiceDetails ?? [], id: \.id) { invoice in
                                        InvoiceListCell(invoice: invoice) { invoiceModel in
                                
                                        } onPrintInvoice: { printInvoice in
                                            if let pdfURL = printInvoice.invoicePDFUrl {
//                                                selectedPdfURL?(URL(string: pdfURL)!)
//                                                path.append("PDFViewer")
                                            }
                                        }
                                    }
                                }.padding(.horizontal)
                                    .padding(.bottom, 20)
                                    .background(Color.clear.edgesIgnoringSafeArea(.all))
                            }
                            
                        }.padding(.vertical, 15)
                    }
                }
                
//                Group {
//                    if selectedFilter == .checklist, (viewModel.selectedItem?.invoiceDetails?.count ?? 0) == 0 {
//                        NoDataView(message: "No Invoice Available")
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    } else {
//                        ScrollView {
//                            VStack (spacing: 16) {
//                                if selectedFilter == .checklist {
//
//                                } else if selectedFilter == .invoiceHistory {
//
//                                }
//                            }.padding(.horizontal)
//                                .padding(.bottom, 20)
//                                .background(Color.clear.edgesIgnoringSafeArea(.all))
//                        }.refreshable {
//                            await viewModel.refreshClientsList()
//                        }.padding(.vertical, 15)
//                            .padding(.horizontal, 10)
//                    }
//                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationBarBackButtonHidden()
                .background(.applicationBGcolor)
            
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

enum InspectionDetailFilter: String, CaseIterable, Identifiable {
    case checklist = "Inspection Checklist"
    case invoiceHistory = "Invoice History"
    
    var id: String { rawValue }
}
