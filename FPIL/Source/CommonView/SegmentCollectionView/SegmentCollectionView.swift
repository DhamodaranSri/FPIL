//
//  SegmentCollectionView.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import SwiftUI

struct HorizontalSelectorView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var selectedColor: Color = .appPrimary
    var unselectedColor: Color = .tabbarIconSelected
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 12) {
                let groupedArray = Dictionary(grouping: viewModel.items, by: { $0.buildingTyname })
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

@MainActor
class HorizontalSelectorViewModel: ObservableObject {
    @Published var items: [Site] = [
        Site(companyName: "Demo Construction Co.",
             address: "123 Safety Lane, Fire City, CA 90210",
             siteId: "SITE-DEMO-001",
             contactName: "Chief Johnson",
             phone: "555-FIRE-001",
             buildingType: 1,
             buildingTyname: "Commercial Buildings"
            ),
        Site(companyName: "Demo Construction Co.",
             address: "123 Safety Lane, Fire City, CA 90210",
             siteId: "SITE-DEMO-001",
             contactName: "Chief Johnson",
             phone: "555-FIRE-001",
             buildingType: 2,
             buildingTyname: "Residential Buildings"
            ),
        Site(companyName: "Demo Construction Co.",
             address: "123 Safety Lane, Fire City, CA 90210",
             siteId: "SITE-DEMO-001",
             contactName: "Chief Johnson",
             phone: "555-FIRE-001",
             buildingType: 2,
             buildingTyname: "Residential Buildings"
            )
    ]
    @Published var selectedId: String? = "All"
    
    func selectItem(id: String) {
        selectedId = id
    }
}
