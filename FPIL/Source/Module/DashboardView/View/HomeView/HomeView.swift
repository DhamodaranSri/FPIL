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
    var body: some View {
        NavigationStack(path: $path) {
            VStack() {
                HorizontalSelectorView(viewModel: viewModel)
                    .frame(height: 60, alignment: .top)
                ExpandableListView(viewModel: viewModel, updateDetails: { updateJob in
                    viewModel.selectedItem = updateJob
                    if path.count > 0 {
                        path.removeLast()
                    }
                    path.append("updateSites")
                })
            }.navigationDestination(for: String.self) { value in
                if value == "updateSites" {
                    CreateOrUpdateSiteView(viewModel: viewModel) {
                        DispatchQueue.main.async {
                            if path.count > 0 {
                                path.removeLast()
                            }
                        }
                    }
                } else if value == "createSites" {
                    CreateOrUpdateSiteView(viewModel: viewModel) {
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
