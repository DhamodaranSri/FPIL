//
//  SiteListViewModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 18/09/25.
//

import Foundation

// MARK: - ViewModel
class SiteListViewModel: ObservableObject {
    @Published var sites: [Site] = [
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
            )
    ]
    
    func toggleExpand(for site: Site) {
        if let index = sites.firstIndex(where: { $0.id == site.id }) {
            sites[index].isExpanded.toggle()
        }
    }
}
