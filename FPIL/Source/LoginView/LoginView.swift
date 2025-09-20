//
//  LoginView.swift
//  FPIL
//
//  Created by OrganicFarmers on 11/08/25.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var textFieldValidators = TextFieldValidators()
    @State var passwordString: String = ""
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .center, spacing: 50) {
                Image("FPIL_Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 50)
                LoginTextFieldViews()
                LoginButtonViews()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.applicationBGcolor)
        }
        .environmentObject(authVM)
        .environmentObject(textFieldValidators)
    }
}

#Preview {
    LoginView()
}
