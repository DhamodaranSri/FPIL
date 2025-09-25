//
//  CustomAlertView.swift
//  FPIL
//
//  Created by OrganicFarmers on 24/09/25.
//

import Foundation
import SwiftUI

struct CustomAlertView: View {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    let secondaryButtonTitle: String?
    let secondaryAction: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Title
                Text(title)
                    .font(ApplicationFont.bold(size: 16).value)
                    .foregroundColor(.appPrimary)
                    .multilineTextAlignment(.center)
                
                // Message
                Text(message)
                    .font(ApplicationFont.regular(size: 14).value)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    // Secondary Button (optional)
                    if let secondaryButtonTitle = secondaryButtonTitle,
                       let secondaryAction = secondaryAction {
                        Button(action: secondaryAction) {
                            Text(secondaryButtonTitle)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    
                    // Primary Button
                    Button(action: primaryAction) {
                        Text(primaryButtonTitle)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
        }
    }
}
