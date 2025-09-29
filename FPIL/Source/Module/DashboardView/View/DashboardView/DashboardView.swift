//
//  DashboardView.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/08/25.
//

import Foundation
import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var path = NavigationPath()
    
    var tabBarHeight: CGFloat {
        return 60 // match overlay padding
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                CustomNavBar(
                    title: viewModel.selectedTab?.navBarTitle ?? "",
                    showBackButton: false,
                    actions: viewModel.selectedTab?.name != "Services" ? [
                        NavBarAction(icon: "plus") {
                            if viewModel.selectedTab?.name == "Inspectors" {
                                if path.count > 0 {
                                    path.removeLast()
                                }
                                path.append("createFireInspector")
                            } else {
                                alertMessage = "Under Construction"
                                showAlert = true
                            }
                        },
                        NavBarAction(icon: "profile") {
                            alertMessage = "Under Construction"
                            showAlert = true
                        },
                        NavBarAction(icon: "logout") {
                            viewModel.signout()
                        }
                    ] : [
                        NavBarAction(icon: "profile") {
                            alertMessage = "Under Construction"
                            showAlert = true
                        },
                        NavBarAction(icon: "logout") {
                            viewModel.signout()
                        }
                    ],
                    backgroundColor: .applicationBGcolor,
                    titleColor: viewModel.selectedTab?.name == "Home" ? .appPrimary : .white
                ).alert(alertMessage, isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                }
                
                ZStack {
                    if let selectedTab = viewModel.selectedTab {
                        switch selectedTab.name {
                        case "Home":
                            HomeView()
                                .background(.applicationBGcolor)
                                .frame(alignment: .top)
                                .padding(.bottom, tabBarHeight)
                        case "Inspectors":
                            InspectorsListView(viewModel: InspectorsListViewModel(), path: $path)
                                .background(.applicationBGcolor)
                                .frame(alignment: .top)
                                .padding(.bottom, tabBarHeight)
                        default:
                            
                            Text("Coming soon!").foregroundColor(.white)
                        }
                        
                        BottomTabBar(
                            currentTab: $viewModel.selectedTab,
                            tabs: viewModel.tabs,
                            backgroundColor: .applicationBGcolor
                        )
                    } else if viewModel.isLoading {
                        ProgressView("Loading...")
                    } else {
                        Text("No Tabs Available")
                    }
                }
                .background(.clear)
            }
            .navigationBarBackButtonHidden(true)
            .background(.applicationBGcolor)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    DashboardView()
}
