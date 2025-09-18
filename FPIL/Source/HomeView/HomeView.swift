//
//  HomeView.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    var body: some View {
        VStack() {
            HorizontalSelectorView(viewModel: viewModel)
                .frame(height: 60, alignment: .top)
            ExpandableListView(viewModel: viewModel)
        }.onAppear {
            viewModel.loadSites()
        }
    }
}

#Preview {
    HomeView()
}


@MainActor
class HomeViewModel: ObservableObject {
    @Published var items: [Site] = []  // all sites
    @Published var selectedFilter: String = "All"  // default "All"
    
    var filteredItems: [Site] {
        if selectedFilter == "All" {
            return items
        } else {
            return items.filter { $0.buildingTyname == selectedFilter }
        }
    }
    
    func loadSites() {
        // load from Firestore or local for now
        self.items = [
            Site(companyName: "Demo Construction Co.",
                 address: "123 Safety Lane",
                 siteId: "SITE-DEMO-001",
                 contactName: "Chief Johnson",
                 phone: "555-FIRE-001",
                 buildingType: 1,
                 buildingTyname: "Commercial Buildings"),
            
            Site(companyName: "Demo Construction Co.",
                 address: "456 Fire Street",
                 siteId: "SITE-DEMO-002",
                 contactName: "Chief Adams",
                 phone: "555-FIRE-002",
                 buildingType: 2,
                 buildingTyname: "Residential Buildings"),

            Site(companyName: "Demo Construction Co.",
                 address: "456 Fire Street",
                 siteId: "SITE-DEMO-002",
                 contactName: "Chief Adams",
                 phone: "555-FIRE-002",
                 buildingType: 2,
                 buildingTyname: "Residential Buildings")
        ]
    }
    
    func selectFilter(_ filter: String) {
        selectedFilter = filter
    }

    func toggleExpand(for site: Site) {
        if let index = items.firstIndex(where: { $0.id == site.id }) {
            items[index].isExpanded.toggle()
        }
    }
}
