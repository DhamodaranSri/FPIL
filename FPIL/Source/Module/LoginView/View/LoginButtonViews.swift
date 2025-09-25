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
            }, buttonTitle: "Login").navigationDestination(isPresented: $goToDashboard) {
                switch authVM.profile?.userType {
                case 1: OrganisationListView(viewModel: OrganisationViewModel())
                case 2: DashboardView()
                default: DashboardView()
                }
            }
            
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
