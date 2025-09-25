//
//  BottomBorderTextField.swift
//  FPIL
//
//  Created by OrganicFarmers on 23/09/25.
//

import SwiftUI

struct BottomBorderTextField: View {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if isSecure {
                SecureField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .font(ApplicationFont.regular(size: 14).value)
                    }
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .font(ApplicationFont.regular(size: 14).value)
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
            } else {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .font(ApplicationFont.regular(size: 14).value)
                    }
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .font(ApplicationFont.regular(size: 14).value)
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.red.opacity(0.5)) // bottom border
        }
    }
}

// MARK: - ViewModifier for Placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow { placeholder() }
            self
        }
    }
}
#Preview {
    BottomBorderTextField(text: .constant(""), placeholder: "Test")
}
