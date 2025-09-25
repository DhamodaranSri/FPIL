//
//  CustomPicker.swift
//  FPIL
//
//  Created by OrganicFarmers on 23/09/25.
//

import SwiftUI

struct CustomPicker<T: Identifiable & Hashable>: View {
    var title: String
    var options: [T]
    @Binding var selection: T
    var displayKey: KeyPath<T, String> // lets us decide which property to show
    
    var body: some View {
        Menu {
            ForEach(options) { option in
                Button(action: { selection = option }) {
                    HStack {
                        Text(option[keyPath: displayKey])
                        if selection.id == option.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            VStack(alignment: .trailing) {
                HStack {
                    Text(selection[keyPath: displayKey])
                        .foregroundColor(.appPrimary)
                        .font(ApplicationFont.regular(size: 14).value)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 10)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.red.opacity(0.5))
                    .padding(.horizontal, 5)
            }
            
        }
    }
}
