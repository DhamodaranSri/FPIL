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
    @StateObject private var router = Router()
    @Environment(\.openURL) private var openURL
    @StateObject private var homeViewModel = JobListViewModel()
    @StateObject private var inspectorsListViewModel = InspectorsListViewModel()
    @StateObject private var siteJobListViewModel = JobListViewModel()
    @StateObject private var inspectionJobListViewModel = JobListViewModel(isHistoryLoaded: true)
    @StateObject private var clientListViewModel = ClientListViewModel()

    var tabBarHeight: CGFloat { 60 }

    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                VStack(spacing: 0) {
                    let name = (UserDefaultsStore.profileDetail?.firstName ?? "") + " " + (UserDefaultsStore.profileDetail?.lastName ?? "")
                    CustomNavBar(
                        title: viewModel.selectedTab?.name == "Home" ? name : viewModel.selectedTab?.navBarTitle ?? "",
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
                                HomeView(viewModel: homeViewModel)
                                    .background(.applicationBGcolor)
                                    .frame(alignment: .top)
                                    .padding(.bottom, tabBarHeight)
                            case "Inspectors":
                                InspectorsListView(viewModel: inspectorsListViewModel)
                                    .background(.applicationBGcolor)
                                    .frame(alignment: .top)
                                    .padding(.bottom, tabBarHeight)
                            case "Sites":
                                SiteListView(viewModel: siteJobListViewModel)
                                    .background(.applicationBGcolor)
                                    .frame(alignment: .top)
                                    .padding(.bottom, tabBarHeight)
                            case "History", "Review":
                                InspectionHistoryListView(viewModel: inspectionJobListViewModel)
                                    .background(.applicationBGcolor)
                                    .frame(alignment: .top)
                                    .padding(.bottom, tabBarHeight)
                            case "Clients":
                                ClientListView(viewModel: clientListViewModel)
                            case "AI Assistant":
                                AIAssistantView()
                                    .frame(alignment: .top)
                                    .padding(.bottom, tabBarHeight + 20)
                            default:
                                Text("Coming soon!").foregroundColor(.white)
                            }

                            BottomTabBar(
                                currentTab: $viewModel.selectedTab,
                                tabs: viewModel.tabs,
                                backgroundColor: .applicationBGcolor
                            ) { _ in
                                router.popToRoot()
                            }
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
                            primaryAction: { viewModel.serviceError = nil },
                            secondaryButtonTitle: nil,
                            secondaryAction: nil
                        )
                    }
                }
            }
        }
        .environmentObject(router)
    }

    private func getNavBarActions() -> [NavBarAction] {
        if viewModel.selectedTab?.name == "Services"
            || viewModel.selectedTab?.name == "Sites"
            || viewModel.selectedTab?.name == "History"
            || viewModel.selectedTab?.name == "AI Assistant" {
            return [NavBarAction(icon: "logout") { viewModel.signout() }]
        } else {
            return [
                NavBarAction(icon: "plus") {
                    if viewModel.selectedTab?.name == "Inspectors" {
                        router.navigate(to: .createFireInspector)
                    } else if viewModel.selectedTab?.name == "Home" {
                        router.navigate(to: .createSite)
                    } else if viewModel.selectedTab?.name == "Clients" {
                        router.navigate(to: .createClient)
                    } else if viewModel.selectedTab?.name == "Review" {
                        router.navigate(to: .reviewInspections)
                    } else {
                        alertMessage = "Under Construction"
                        showAlert = true
                    }
                },
                NavBarAction(icon: "logout") { viewModel.signout() }
            ]
        }
    }
}

#Preview {
    DashboardView()
}
