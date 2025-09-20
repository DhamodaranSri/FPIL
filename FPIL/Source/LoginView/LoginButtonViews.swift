//
//  LoginButtonViews.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/09/25.
//

import SwiftUI

struct LoginButtonViews: View {
    @State var goToDashboard: Bool = false
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var textFieldValidators: TextFieldValidators
    var body: some View {
        VStack (spacing: 15) {
            NavigationLink(destination: DashboardView(),
                           isActive: $goToDashboard) {
                EmptyView()
            }
            PrimaryButton(sendAction: {
                let email = textFieldValidators.email
                let password = textFieldValidators.password
                
                authVM.signIn(email: email, password: password) { result, error in
                    DispatchQueue.main.async {
                        if result {
                            goToDashboard = true
                        }
                    }
                }
            }, buttonTitle: "Login")
            
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    LoginButtonViews()
}
