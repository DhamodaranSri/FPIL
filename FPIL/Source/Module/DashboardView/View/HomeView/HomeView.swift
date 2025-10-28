//
//  HomeView.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var path:NavigationPath
    @StateObject private var viewModel = JobListViewModel()
    @Binding var qrCodeImage: UIImage?
    @State private var isAssignJobTapped: Bool = false
    var body: some View {
        NavigationStack(path: $path) {
            VStack() {
                
                Group {
                    if viewModel.filteredItems.isEmpty {
                        NoDataView(message: "No Sites Available")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        HorizontalSelectorView(viewModel: viewModel)
                            .frame(height: 60, alignment: .top)
                        ExpandableListView(viewModel: viewModel, updateDetails: { updateJob in
                            viewModel.selectedItem = updateJob
                            if path.count > 0 {
                                path.removeLast()
                            }
                            path.append("updateSites")
                        }, showQRDetails: { qrImage in
                            
                            qrCodeImage = qrImage
                            
                            if path.count > 0 {
                                path.removeLast()
                            }
                            path.append("showQRImage")
                        }, assignJob: { updateJob in
                            viewModel.selectedItem = updateJob
                            isAssignJobTapped = true
                            if path.count > 0 {
                                path.removeLast()
                            }
                            path.append("assignJob")
                        })
                    }
                }
            }.onAppear{
                ClientListViewModel()
            }
            .navigationDestination(for: String.self) { value in
                if value == "updateSites" {
                    CreateOrUpdateSiteView(viewModel: viewModel) {
                        DispatchQueue.main.async {
                            if path.count > 0 {
                                path.removeLast()
                            }
                        }
                    }
                } else if value == "createSites" {
//                    CreateOrUpdateSiteView(viewModel: viewModel) {
//                        DispatchQueue.main.async {
//                            if path.count > 0 {
//                                path.removeLast()
//                            }
//                        }
//                    }
                    CreateInspection(viewModel: viewModel) {
                        DispatchQueue.main.async {
                            if path.count > 0 {
                                path.removeLast()
                            }
                        }
                    }
                } else if value == "assignJob" {
                    CreateOrUpdateSiteView(viewModel: viewModel, onClick: {
                        isAssignJobTapped = false
                        DispatchQueue.main.async {
                            if path.count > 0 {
                                path.removeLast()
                            }
                        }
                    }, assignTheJob: true)
                } else if value == "showQRImage" {
                    QRPreviewView(image: $qrCodeImage) {
                        qrCodeImage = nil
                        DispatchQueue.main.async {
                            if path.count > 0 {
                                path.removeLast()
                            }
                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    HomeView()
//}
