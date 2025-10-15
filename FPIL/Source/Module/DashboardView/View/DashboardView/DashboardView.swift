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
    @StateObject private var jobListViewModel = JobListViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var path = NavigationPath()
    @State private var qrCodeImage: UIImage? = nil
    
    var tabBarHeight: CGFloat {
        return 60 // match overlay padding
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack(spacing: 0) {
                    CustomNavBar(
                        title: viewModel.selectedTab?.navBarTitle ?? "",
                        showBackButton: false,
                        actions: getNavBarActions(),
                        backgroundColor: .applicationBGcolor,
                        titleColor: viewModel.selectedTab?.name == "Home" ? .appPrimary : .white
                    ).alert(alertMessage, isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        if let selectedTab = viewModel.selectedTab {
                            switch selectedTab.name {
                            case "Home":
                                HomeView(path: $path, qrCodeImage: $qrCodeImage)
                                    .background(.applicationBGcolor)
                                    .frame(alignment: .top)
                                    .padding(.bottom, tabBarHeight)
                            case "Inspectors":
                                InspectorsListView(viewModel: InspectorsListViewModel(), path: $path)
                                    .background(.applicationBGcolor)
                                    .frame(alignment: .top)
                                    .padding(.bottom, tabBarHeight)
                            case "Sites":
                                SiteListView(path: $path, viewModel: jobListViewModel)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationBarBackButtonHidden(true)
                .background(.applicationBGcolor)
                .ignoresSafeArea(edges: .bottom)
                
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
    
    private func getNavBarActions() -> [NavBarAction] {
        if viewModel.selectedTab?.name == "Services" || viewModel.selectedTab?.name == "Sites" {
            return [
                NavBarAction(icon: "profile") {
                    alertMessage = "Under Construction"
                    showAlert = true
                },
                NavBarAction(icon: "logout") {
                    viewModel.signout()
                }
            ]
        } else {
            return [
                NavBarAction(icon: "plus") {
                    if viewModel.selectedTab?.name == "Inspectors" {
                        if path.count > 0 {
                            path.removeLast()
                        }
                        path.append("createFireInspector")
                    } else if viewModel.selectedTab?.name == "Home" {
                        if path.count > 0 {
                            path.removeLast()
                        }
                        path.append("createSites")
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
            ]
        }
    }
}

#Preview {
    DashboardView()
}
