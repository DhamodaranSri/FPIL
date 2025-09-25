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
        ZStack {
            
            NavigationStack {
                ZStack {
                    Image("firefighter")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                    
                    VStack (alignment: .center, spacing: 50) {
                        Image("FPIL_Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding(.bottom, 30)
                        LoginTextFieldViews()
                        LoginButtonViews()
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//                    .background(Color.applicationBGcolor)
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .navigationBarBackButtonHidden(true)
            .environmentObject(authVM)
            .environmentObject(textFieldValidators)
            
            if authVM.isLoading {
                LoadingView()
                    .transition(.opacity)
                    .animation(.easeInOut, value: authVM.isLoading)
            }
        }
    }
}

#Preview {
    LoginView()
}
