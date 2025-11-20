//
//  SegmentCollectionView.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import SwiftUI

struct HorizontalSelectorView: View {
    @ObservedObject var viewModel: JobListViewModel
    
    var selectedColor: Color = .appPrimary
    var unselectedColor: Color = .tabbarIconSelected
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 12) {
                let groupedArray = Dictionary(grouping: viewModel.items, by: { $0.building.buildingName })
                    .sorted { $0.key < $1.key }
                if groupedArray.count > 0 {
                    Button(action: {
                        viewModel.selectFilter("All")
                    }) {
                        Text("All")
                            .font(ApplicationFont.regular(size: 14).value)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.selectedFilter == "All" ? selectedColor.opacity(0.3) : unselectedColor.opacity(0.1))
                            )
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(viewModel.selectedFilter == "All" ? selectedColor : unselectedColor, lineWidth: 1)
                            )
                    }
                }
                ForEach(groupedArray, id: \.key) { key, value in
                    Button(action: {
                        viewModel.selectFilter(key)
                    }) {
                        Text(key)
                            .font(ApplicationFont.regular(size: 14).value)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.selectedFilter == key ? selectedColor.opacity(0.3) : unselectedColor.opacity(0.1))
                            )
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(viewModel.selectedFilter == key ? selectedColor : unselectedColor, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
        }
    }
}

struct HorizontalClientFilterView: View {
    @ObservedObject var viewModel: ClientListViewModel

    // Same UI style as your JobListView filter
    var selectedColor: Color = .appPrimary
    var unselectedColor: Color = .tabbarIconSelected
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                
                // MARK: ALL button
                Button(action: {
                    viewModel.selectFilter("All")
                }) {
                    filterButton(title: "All",
                                 isSelected: viewModel.selectedFilter == "All")
                }
                
                // MARK: Dynamic categories from clientType
                ForEach(viewModel.filterCategories, id: \.self) { typeName in
                    Button(action: {
                        viewModel.selectFilter(typeName)
                    }) {
                        filterButton(
                            title: typeName,
                            isSelected: viewModel.selectedFilter == typeName
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: Filter Button UI
    @ViewBuilder
    func filterButton(title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(ApplicationFont.regular(size: 14).value)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? selectedColor.opacity(0.3)
                                     : unselectedColor.opacity(0.1))
            )
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? selectedColor
                                       : unselectedColor,
                            lineWidth: 1)
            )
    }
}
