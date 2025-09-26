//
//  LoginButtonViews.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/09/25.
//

import SwiftUI

struct LoginButtonViews: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var textFieldValidators: TextFieldValidators
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    var body: some View {
        VStack (spacing: 15) {
            PrimaryButton(sendAction: {
                let email = textFieldValidators.email
                let password = textFieldValidators.password
                
                authVM.signIn(email: email, password: password) { result, error in
                    DispatchQueue.main.async {
                        if result {
                            isLoggedIn = true
                        }
                    }
                }
            }, buttonTitle: "Login")
            
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.white)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    LoginButtonViews()
}
