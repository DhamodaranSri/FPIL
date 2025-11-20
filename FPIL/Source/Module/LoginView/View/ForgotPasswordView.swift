//
//  ForgotPasswordView.swift
//  FPIL
//
//  Created by OrganicFarmers on 18/11/25.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @EnvironmentObject var textFieldValidators: TextFieldValidators

    var body: some View {
        ZStack {
            Image("firefighter")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Reset Password")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                VStack {
                    if !textFieldValidators.email.isEmpty &&
                        !textFieldValidators.isValidEmail(textFieldValidators.email) {
                        Text("Invalid email address")
                            .font(ApplicationFont.regular(size: 10).value)
                            .foregroundColor(.white)
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
                }
                
                PrimaryButton(sendAction: {
                    resetPassword()
                }, buttonTitle: "Send Reset Link")
                Spacer()
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    dismiss()
                })
            }
        }
    }

    private func resetPassword() {
        if textFieldValidators.email.isEmpty ||
            !textFieldValidators.isValidEmail(textFieldValidators.email) {
            alertMessage = "Please enter your valid email"
            showAlert = true
            return
        }
//        guard !email.isEmpty else {
//            alertMessage = "Please enter your email"
//            showAlert = true
//            return
//        }

        Auth.auth().sendPasswordReset(withEmail: textFieldValidators.email) { error in
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "Password reset link sent to \(email)"
            }
            showAlert = true
        }
    }
}

