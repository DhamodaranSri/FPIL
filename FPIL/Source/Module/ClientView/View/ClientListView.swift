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

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack {
                    SearchView(searchText: .constant(""), searchPlaceholder: "Search for Client")
                    Group {
                        if viewModel.filteredItems.isEmpty {
                            NoDataView(message: "No Clients Available")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(viewModel.filteredItems, id:\.id) { clientModel in
                                        ClientListCell(client: clientModel) { client, isButton in
                                            viewModel.selectedItem = client
                                            if path.count > 0 {
                                                path.removeLast()
                                            }
                                            path.append(isButton ? "createInspection" : "createClients")
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
                .navigationDestination(for: String.self) { value in
                    if value == "createClients" {
                        CreateOrUpdateClientView(viewModel: viewModel) {
                            viewModel.selectedItem = nil
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        }
                    } else if value == "createInspection" {
                        InvoiceGenerationView() {
                            viewModel.selectedItem = nil
                            DispatchQueue.main.async {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                            }
                        }
//                        CreateInspection(viewModel: JobListViewModel(), clientModel: viewModel.selectedItem) {
//                            viewModel.selectedItem = nil
//                            DispatchQueue.main.async {
//                                if path.count > 0 {
//                                    path.removeLast()
//                                }
//                            }
//                        }
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
