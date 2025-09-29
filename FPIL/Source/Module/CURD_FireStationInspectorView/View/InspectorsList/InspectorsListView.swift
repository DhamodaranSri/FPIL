//
//  InspectorsListView.swift
//  FPIL
//
//  Created by OrganicFarmers on 26/09/25.
//

import SwiftUI

struct InspectorsListView: View {
    @ObservedObject var viewModel: InspectorsListViewModel
    @Binding var path:NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack {
                    let all = viewModel.items.count
                    let active = viewModel.items.filter { $0.status == 1 }.count
                    let inActive = viewModel.items.filter { $0.status == 0 }.count
                    let dic: Dictionary<String, Any> = ["All Inspectors": all, "Active Inspectors": active, "Inactive Inspectors": inActive]
                    let allKeys: [String] = ["All Inspectors", "Active Inspectors", "Inactive Inspectors"]
                    SmallCardInfoView(cardInfo: dic, keys: allKeys)
                        .frame(maxWidth: .infinity)
                    
                    SearchView(searchText: $viewModel.searchText, searchPlaceholder: "Search for Inspector")
                    
                    Group {
                        if viewModel.filteredItems.isEmpty {
                            NoDataView(message: "No Inspectors Available")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(viewModel.filteredItems, id:\.id) { inspectorModel in
                                        FireInspectorListCell(inspector: inspectorModel) { ins in
                                            viewModel.selectedItem = ins
                                            if path.count > 0 {
                                                path.removeLast()
                                            }
                                            path.append("createFireInspector")
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                                .background(Color.clear.edgesIgnoringSafeArea(.all))
                            } .refreshable {
                                await viewModel.refreshInspectorsList()
                            }
                        }
                    }
                    
                }
                .frame(alignment: .top)
                .navigationBarBackButtonHidden(true)
                .background(.applicationBGcolor)
                .ignoresSafeArea(edges: .bottom)
                .navigationDestination(for: String.self) { value in
                    if value == "createFireInspector" {
                        CreateOrUpdateInspector(viewModel: viewModel) {
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

//#Preview {
//    InspectorsListView(viewModel: InspectorsListViewModel())
//}
