//
//  InspectionPage.swift
//  FPIL
//
//  Created by OrganicFarmers on 14/11/25.
//

import SwiftUI

struct InspectionPage: View {
    @StateObject private var router = Router()
    var clientViewModel: ClientDetailViewModel = ClientDetailViewModel(selectedItem: nil)

    var body: some View {
        NavigationStack(path: $router.path) {
            ClientDetailView(viewModel: clientViewModel, isBackButtonShown: false)
        }
        .environmentObject(router)
    }
}
