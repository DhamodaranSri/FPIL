//
//  LoadingView.swift
//  FPIL
//
//  Created by OrganicFarmers on 24/09/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle(tint: .appPrimary))
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
        }
    }
}
#Preview {
    LoadingView()
}
