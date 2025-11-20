//
//  InspectionPage.swift
//  FPIL
//
//  Created by OrganicFarmers on 14/11/25.
//

import SwiftUI

struct InspectionPage: View {
    @State private var path = NavigationPath()
    var clientViewModel: ClientDetailViewModel = ClientDetailViewModel(selectedItem: nil)
    
    var body: some View {
        NavigationStack(path: $path) {
            ClientDetailView(viewModel: clientViewModel, path: $path, isBackButtonShown: false) {
            } selectedPdfURL: { url in
            } selectedJob: { job in
            }
        }
    }
}
