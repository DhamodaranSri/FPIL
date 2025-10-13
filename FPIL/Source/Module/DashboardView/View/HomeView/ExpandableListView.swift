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
    let updateDetails: (JobModel) -> Void
    let showQRDetails: (UIImage) -> Void
    let assignJob: (JobModel) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                let groupedArray = Dictionary(grouping: viewModel.filteredItems, by: { $0.building.buildingName })
                    .sorted { $0.key < $1.key }
                ForEach(groupedArray, id: \.key) { key, value in
                    HeaderCell(titleString: key)
                    
                    let fetchBuildingNamedArray = viewModel.filteredItems.filter { $0.building.buildingName == key }
                                        
                    ForEach(fetchBuildingNamedArray, id:\.id) { job in
                        JobCardView(job: job) {
                            withAnimation {
                                viewModel.toggleExpand(for: job)
                            }
                        } updateDetails: { updateJob in
                            updateDetails(updateJob)
                        } showQRDetails: { qrImage in
                            showQRDetails(qrImage)
                        } assignJob: { updateJob in
                            assignJob(updateJob)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            .background(Color.clear.edgesIgnoringSafeArea(.all))
        }.refreshable {
            await viewModel.refreshOrganisations()
        }
    }
}

#Preview {
    ExpandableListView(viewModel: JobListViewModel(), updateDetails: {_ in }, showQRDetails: { _ in }, assignJob: { _ in })
}

