//
//  OrganisationListView.swift
//  FPIL
//
//  Created by OrganicFarmers on 22/09/25.
//

import SwiftUI

// MARK: - List View
struct OrganisationListView: View {
    @ObservedObject var viewModel: OrganisationViewModel
    @State private var showCreateOrganisation = false
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    CustomNavBar(
                        title: "Firestations List",
                        showBackButton: false,
                        actions: [
                            NavBarAction(icon: "plus") {
                                showCreateOrganisation = true
                            },
                            NavBarAction(icon: "logout") {
                                viewModel.signout()
                            }
                        ],
                        backgroundColor: .applicationBGcolor,
                        titleColor: .appPrimary
                    )
                    
                    HStack (spacing: 15) {
                        VStack {
                            Text("\(viewModel.items.count)")
                                .foregroundColor(.appPrimary)
                                .font(ApplicationFont.bold(size: 26).value)
                            Text("All Firestations")
                                .foregroundColor(.white)
                                .font(ApplicationFont.regular(size: 14).value)
                        }
                        .frame(alignment: .center)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
                        .background(Color.inspectionCellBG)
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                        
                        VStack {
                            let activeStationsCount = viewModel.items.filter { $0.status == 1 }.count
                            Text("\(activeStationsCount)")
                                .foregroundColor(.appPrimary)
                                .font(ApplicationFont.bold(size: 26).value)
                            Text("Active Stations")
                                .foregroundColor(.white)
                                .font(ApplicationFont.regular(size: 14).value)
                        }.padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
                            .background(Color.inspectionCellBG)
                            .cornerRadius(12)
                            .contentShape(Rectangle())
                        
                        VStack {
                            let inactiveStationsCount = viewModel.items.filter { $0.status == 0 }.count
                            Text("\(inactiveStationsCount)")
                                .foregroundColor(.appPrimary)
                                .font(ApplicationFont.bold(size: 26).value)
                            Text("Inactive Stations")
                                .foregroundColor(.white)
                                .font(ApplicationFont.regular(size: 14).value)
                        }.padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
                            .background(Color.inspectionCellBG)
                            .cornerRadius(12)
                            .contentShape(Rectangle())
                    }.padding(5)
                    
                    HStack {
                        TextField(
                                "Search for Firestation",
                                text: $viewModel.searchText,
                                prompt: Text("Search for Firestation").foregroundColor(.gray) // placeholder gray
                            )
                            .foregroundColor(.white) // search text white
                            .padding()
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .padding(.horizontal, 10)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
                    .background(Color.inspectionCellBG)
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    
                    Group {
                        if viewModel.filteredItems.isEmpty {
                            // No Data
                            NoDataView(message: "No Firestations Available")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(viewModel.filteredItems, id:\.id) { organisation in
                                        OrganisationListCell(organisation: organisation) { org in
                                            viewModel.selectedItem = org
                                            showCreateOrganisation = true
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
                .navigationBarBackButtonHidden(true)
                .background(.applicationBGcolor)
                .ignoresSafeArea(edges: .bottom)
                .navigationDestination(isPresented: $showCreateOrganisation) {
                    CreateOrganisationView(viewModel: viewModel)
                }
                .navigationDestination(isPresented: $viewModel.isUserSignedOut) {
                    LoginView()
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

#Preview {
    OrganisationListView(viewModel: OrganisationViewModel())
}

struct NoDataView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text(message)
                .foregroundColor(.gray)
                .font(.headline)
        }
        .padding()
    }
}
