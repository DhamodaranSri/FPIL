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
    
    var tabBarHeight: CGFloat {
        return 60 // match overlay padding
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(
                title: "AI Fire Inspector Pro",
                showBackButton: false,
                actions: [
                    NavBarAction(icon: "plus") {
                        alertMessage = "Under Construction"
                        showAlert = true
                    },
                    NavBarAction(icon: "profile") {
                        alertMessage = "Under Construction"
                        showAlert = true
                    }
                ],
                backgroundColor: .applicationBGcolor,
                titleColor: .appPrimary
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
                            .padding(.bottom, tabBarHeight) // ensures ScrollView doesn't hide behind tab bar
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
        .background(.applicationBGcolor)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    DashboardView()
}
