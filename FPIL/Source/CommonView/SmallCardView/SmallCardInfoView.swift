//
//  SmallCardInfoView.swift
//  FPIL
//
//  Created by OrganicFarmers on 26/09/25.
//

import SwiftUI

struct SmallCardInfoView: View {
    var cardInfo: Dictionary<String, Any>
    var keys: [String]
    var body: some View {
        HStack (spacing: 10) {
            ForEach(keys, id: \.self) { key in
                if let value = self.cardInfo[key] {
                    VStack {
                        Text("\(value)")
                            .foregroundColor(.appPrimary)
                            .font(ApplicationFont.bold(size: 26).value)
                        Text("\(key)")
                            .foregroundColor(.white)
                            .font(ApplicationFont.regular(size: 14).value)
                    }
                    .frame(alignment: .center)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
                    .background(Color.inspectionCellBG)
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                }
            }
        }.padding(5)
    }
}

//#Preview {
//    SmallCardInfoView()
//}
