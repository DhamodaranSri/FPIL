//
//  HomeView.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack() {
            HorizontalSelectorView(viewModel: MockVM())
                .frame(height: 60, alignment: .top)
            ExpandableListView()
        }
//        ScrollView {
//            LazyVStack {
//                HorizontalSelectorView(viewModel: MockVM())
//            }
//        }
    }
}

#Preview {
    HomeView()
}
