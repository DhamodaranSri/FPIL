//
//  ExpandableListView.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import SwiftUI

// MARK: - List View
struct ExpandableListView: View {
    @ObservedObject var viewModel: JobListViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                let groupedArray = Dictionary(grouping: viewModel.filteredItems, by: { $0.buildingName })
                    .sorted { $0.key < $1.key }
                ForEach(groupedArray, id: \.key) { key, value in
                    Text(key)
                        .font(ApplicationFont.bold(size: 14).value)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    let fetchBuildingNamedArray = viewModel.filteredItems.filter { $0.buildingName == key }
                                        
                    ForEach(fetchBuildingNamedArray, id:\.id) { job in
                        JobCardView(job: job) {
                            withAnimation {
                                viewModel.toggleExpand(for: job)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            .background(Color.clear.edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    ExpandableListView(viewModel: JobListViewModel())
}

