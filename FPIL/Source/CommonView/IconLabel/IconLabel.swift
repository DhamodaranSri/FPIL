//
//  IconLabel.swift
//  FPIL
//
//  Created by OrganicFarmers on 17/09/25.
//

import SwiftUI

struct IconLabel: View {
    let labelTitle: String
    let imageName: String
    let textColor: Color
    
    var body: some View {
        Label {
            Text(labelTitle)
                .font(ApplicationFont.regular(size: 12).value)
                .foregroundColor(textColor)
                .lineLimit(1)
        } icon: {
            Image(imageName)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
        }
    }
}

#Preview {
    IconLabel(labelTitle: "", imageName: "", textColor: .white)
}
