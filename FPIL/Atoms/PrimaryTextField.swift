//
//  PrimaryTextField.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/09/25.
//

import SwiftUI

struct PrimaryTextField: View {
    @EnvironmentObject var textFieldValidators: TextFieldValidators
    var placeholder: String = ""
    var body: some View {
        TextField(placeholder, text: $textFieldValidators.email)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .font(ApplicationFont.regular(size: 18).value)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .frame(height: 50)
            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color(.white), style: StrokeStyle(lineWidth: 1.0)))
    }
}

#Preview {
    PrimaryTextField(placeholder: "Enter your mobile number").environmentObject(TextFieldValidators())
}
