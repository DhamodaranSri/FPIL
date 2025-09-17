//
//  ExpandableListView.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import SwiftUI

// MARK: - Model
struct Site: Identifiable {
    let id = UUID()
    let companyName: String
    let address: String
    let siteId: String
    let contactName: String
    let phone: String
    var isExpanded: Bool = false
    let buildingType:Int
    let buildingTyname: String
}

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

// MARK: - View
struct SiteCardView: View {
    let site: Site
    let onToggle: () -> Void
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(site.companyName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(site.address)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Site ID:")
                            .font(.subheadline)
                            .bold()
                        Text(site.siteId)
                            .font(.subheadline)
                    }
                    .foregroundColor(.white)
                }
                Spacer()
                
                if site.isExpanded {
                    Text("Due Soon (5 days)")
                        .font(.caption)
                        .padding(6)
                        .padding(.horizontal, 6)
                        .background(Color.warningBG.opacity(0.2))
                        .foregroundColor(.warningBG)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.warningBG, lineWidth: 1)
                        )
                }
            }
            
            // Contact Info
            HStack(spacing: 16) {
                IconLabel(labelTitle: site.contactName, imageName: "user", textColor: .white)
                Button(action: {
                    alertMessage = "Under Construction"
                    showAlert = true
                }) {
                    IconLabel(labelTitle: site.phone, imageName: "phone", textColor: .white)
                }
            }
            .font(.subheadline)
            
            // Expanded Content
            if site.isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            alertMessage = "Under Construction"
                            showAlert = true
                        }) {
                            IconLabel(labelTitle: "Start", imageName: "play", textColor: .white)
                                .font(.subheadline)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.appPrimary, lineWidth: 1)
                                )
                        }
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                        
                        Button {
                            alertMessage = "Under Construction"
                            showAlert = true
                        } label: {
                            Text("Update Details")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .underline()
                        }
                        .contentShape(Rectangle())
                        
                        Spacer()
                        
                        Button(action: {
                            alertMessage = "Under Construction"
                            showAlert = true
                        }) {
                            Image("print")
                        }
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                    }
                    
                    Spacer(minLength: 5)
                    
                    Text("Last Visit Details")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    
                    VStack(alignment: .center, spacing: 8) {
                        HStack(spacing: 10) {
                            IconLabel(labelTitle: "Inspector Mike", imageName: "user", textColor: .white)
                            IconLabel(labelTitle: "25/7/2025", imageName: "calander", textColor: .white)
                            IconLabel(labelTitle: "Monthly", imageName: "loop", textColor: .white)
                        }
                        .font(.subheadline)
                        
                        HStack(spacing: 5) {
                            IconLabel(labelTitle: "999", imageName: "timeline", textColor: .white)
                            Text(" | ").foregroundColor(.white)
                            IconLabel(labelTitle: "Commercial", imageName: "commercial", textColor: .white)
                            Text(" | ").foregroundColor(.white)
                            IconLabel(labelTitle: "1.2 Hrs", imageName: "clock", textColor: .white)
                            Text(" | ").foregroundColor(.white)
                            IconLabel(labelTitle: "100", imageName: "alert", textColor: .warningBG)
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.appPrimary, lineWidth: 1))
                    .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
        .background(Color.inspectionCellBG)
        .cornerRadius(10)
        .animation(.easeInOut, value: site.isExpanded)
        .onTapGesture {
            onToggle()
        }
        .contentShape(Rectangle())
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}


// MARK: - List View
struct ExpandableListView: View {
    @StateObject private var viewModel = SiteListViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                let groupedArray = Dictionary(grouping: viewModel.sites, by: { $0.buildingTyname })
                    .sorted { $0.key < $1.key } // alphabetically sort companies
                
                ForEach(groupedArray, id: \.key) { key, value in
                    Text(key)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(value) { site in
                        SiteCardView(site: site) {
                            withAnimation {
                                viewModel.toggleExpand(for: site)
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
    ExpandableListView()
}

