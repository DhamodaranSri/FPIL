//
//  PrimaryButton.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/09/25.
//

import SwiftUI

struct PrimaryButton: View {
    let sendAction: () -> Void
    var buttonTitle: String = ""
    var body: some View {
        Button(action: sendAction, label:{
            Text(buttonTitle)
                .font(ApplicationFont.bold(size: 18).value)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(
                        gradient: .init(colors: [Color("warningBG"), Color("appPrimaryColor")]),
                        startPoint: .init(x: -0.33, y: -0.33),
                        endPoint: .init(x: 0.66, y: 0.66)
                    ))
                .cornerRadius(5)
        })
    }
}

#Preview {
    PrimaryButton(sendAction: {}, buttonTitle: "Login")
}
