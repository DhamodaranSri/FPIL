//
//  HomeView.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = JobListViewModel()
    var body: some View {
        VStack() {
            HorizontalSelectorView(viewModel: viewModel)
                .frame(height: 60, alignment: .top)
            ExpandableListView(viewModel: viewModel)
        }
    }
}

#Preview {
    HomeView()
}
