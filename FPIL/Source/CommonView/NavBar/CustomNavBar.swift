//
//  CustomNavBar.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import Foundation
import SwiftUI

struct CustomNavBar: View {
    let title: String
    let showBackButton: Bool
    let actions: [NavBarAction]
    let backgroundColor: Color
    let titleColor: Color
    
    var backAction: (() -> Void)?
    
    var body: some View {
        HStack {
            // Back Button
            if showBackButton {
                Button(action: {
                    backAction?()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(titleColor)
                }
            }
            
//            Spacer()
            
            // Title
            Text(title)
                .font(ApplicationFont.bold(size: 18).value)
                .foregroundColor(titleColor)
            
            Spacer()
            
            // Actions
            HStack (spacing: 20) {
                ForEach(actions) { actionItem in
                    Button(action: actionItem.action) {
                        Image(actionItem.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .font(.title2)
                            .foregroundColor(titleColor)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(backgroundColor.ignoresSafeArea(edges: .top))
    }
}

struct NavBarAction: Identifiable, Hashable {
    let id = UUID().uuidString
    let icon: String
    let action: () -> Void
    
    // Equatable (synthesized via Hashable but demonstrate explicitly)
    static func == (lhs: NavBarAction, rhs: NavBarAction) -> Bool {
        lhs.id == rhs.id
    }

    // Hashable (hash only the id)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    CustomNavBar(
        title: "AI Fire Inspector Pro",
        showBackButton: false,
        actions: [
            NavBarAction(icon: "plus") {

            }
        ],
        backgroundColor: .applicationBGcolor,
        titleColor: .appPrimary
    )
}
