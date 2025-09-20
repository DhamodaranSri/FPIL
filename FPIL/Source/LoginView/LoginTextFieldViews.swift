//
//  LoginTextFieldViews.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/09/25.
//

import SwiftUI

struct LoginTextFieldViews: View {
    @EnvironmentObject var textFieldValidators: TextFieldValidators
    @State var passwordString: String = ""
    @State private var isPasswordVisible: Bool = false
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack (spacing: 20) {
            if !textFieldValidators.email.isEmpty &&
                !textFieldValidators.isValidEmail(textFieldValidators.email) {
                Text("Invalid email address")
                    .font(ApplicationFont.regular(size: 10).value)
                    .foregroundColor(.red)
                    .padding(.vertical, 0)
            }
            
            ZStack(alignment: .leading) {
                if textFieldValidators.email.isEmpty {
                    Text("Email")
                        .font(ApplicationFont.regular(size: 18).value)
                        .foregroundColor(.gray) // 👈 placeholder color
                        .padding(.leading, 12)
                }
                
                PrimaryTextField(placeholder: "Email").environmentObject(textFieldValidators)
                    .onChange(of: textFieldValidators.email) { oldValue, newValue in
                        textFieldValidators.email = textFieldValidators.validate(inputText: newValue, for: .email, maxLength: 35)
                    }
            }
            
            ZStack(alignment: .leading) {
                if textFieldValidators.password.isEmpty {
                    Text("Password")
                        .font(ApplicationFont.regular(size: 18).value)
                        .foregroundColor(.gray) // 👈 placeholder color
                        .padding(.leading, 12)
                }
                
                HStack {
                    Group {
                        if isPasswordVisible {
                            TextField("", text: $textFieldValidators.password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                        } else {
                            SecureField("", text: $textFieldValidators.password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                        }
                    }
                    .font(ApplicationFont.regular(size: 18).value)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .frame(height: 50)
                    .onChange(of: textFieldValidators.password) { oldValue, newValue in
                        passwordString = textFieldValidators.validate(
                            inputText: newValue,
                            for: .all,
                            maxLength: 20
                        )
                    }
                    
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 8)
                }.overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .strokeBorder(Color.white, lineWidth: 1.0)
                )
            }.onChange(of: textFieldValidators.password) { _, newValue in
                authVM.errorMessage = nil
            }
        }
    }
}

#Preview {
    LoginTextFieldViews()
}
