//
//  HomeView.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: JobListViewModel
    @EnvironmentObject private var router: Router
    @State private var qrCodeImage: UIImage?
    @State private var isAssignJobTapped: Bool = false

    var body: some View {
        VStack() {
            Group {
                if viewModel.filteredItems.isEmpty {
                    NoDataView(message: "No Sites Available")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    HorizontalSelectorView(viewModel: viewModel)
                        .frame(height: 60, alignment: .top)
                    ExpandableListView(viewModel: viewModel, updateDetails: { updateJob in
                        viewModel.selectedItem = updateJob
                        router.navigate(to: .updateSite)
                    }, showQRDetails: { qrImage in
                        qrCodeImage = qrImage
                        router.navigate(to: .showQRImage)
                    }, assignJob: { updateJob in
                        viewModel.selectedItem = updateJob
                        isAssignJobTapped = true
                        router.navigate(to: .assignJob)
                    })
                }
            }
        }
        .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .updateSite:
                CreateOrUpdateSiteView(viewModel: viewModel) {
                    DispatchQueue.main.async { router.pop() }
                }
            case .createSite:
                CreateInspection(viewModel: viewModel) {
                    DispatchQueue.main.async { router.pop() }
                }
            case .assignJob:
                CreateOrUpdateSiteView(viewModel: viewModel, onClick: {
                    isAssignJobTapped = false
                    DispatchQueue.main.async { router.pop() }
                }, assignTheJob: true)
            case .showQRImage:
                QRPreviewView(image: $qrCodeImage) {
                    qrCodeImage = nil
                    DispatchQueue.main.async { router.pop() }
                }
            default:
                EmptyView()
            }
        }
    }
}

//#Preview {
//    HomeView()
//}
