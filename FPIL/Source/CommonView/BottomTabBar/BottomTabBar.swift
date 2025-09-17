//
//  BottomTabBar.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/08/25.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Common TabBar Component
struct BottomTabBar: View {
    
    @Binding var currentTab: TabBarItem?
    var tabs: [TabBarItem]
    var backgroundColor: Color = .applicationBGcolor
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 0) {
                ForEach(Array(tabs), id: \.self) { tab in
                    TabButton(tab: tab)
                }
                .padding(.vertical)
                .padding(.bottom, getSafeArea().bottom == 0 ? 5 : (getSafeArea().bottom - 15))
                .background(backgroundColor)
            }
        }
        .background(.clear)
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    @ViewBuilder
    private func TabButton(tab: TabBarItem) -> some View {
        GeometryReader { _ in
            Button {
                currentTab = tab
            } label: {
                VStack(spacing: 5) {
                    Image(currentTab?.name == tab.name ? tab.iconName : "\(tab.iconName)_non")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .frame(maxWidth: .infinity)
                    
                    Text(tab.name)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .bold(currentTab?.name == tab.name)
                }
            }
        }
        .frame(height: 25)
    }
}

// MARK: - Safe Area Helper
extension View {
    func getSafeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        return safeArea
    }
}

#Preview {
    BottomTabBar(currentTab: .constant(TabBarItem(name: "Home", iconName: "home_ic", userType: [UserType(id: 0, type: "user")], userTypeIds: [0])), tabs: [TabBarItem(name: "Home", iconName: "home_ic", userType: [UserType(id: 0, type: "user")], userTypeIds: [0])])
}
