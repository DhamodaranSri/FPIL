//
//  RequestView.swift
//  FPIL
//
//  Created by OrganicFarmers on 07/10/25.
//

import SwiftUI

struct RequestView: View {
    
    @ObservedObject var viewModel: JobListViewModel
    var onClick: (() -> ())? = nil
    
    init(viewModel: JobListViewModel, onClick: (() -> ())? = nil) {
        self.onClick = onClick
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack {
                CustomNavBar(
                    title: "Create Service Request",
                    showBackButton: true,
                    actions: [],
                    backgroundColor: .applicationBGcolor,
                    titleColor: .appPrimary,
                    backAction: {
                        viewModel.selectedItem = nil
                        onClick?()
                    }
                )
                
                ScrollView {
                    
                }.padding()
                
                VStack {
                    Button(action: {
                        
                    }) {
                        Text("Raise a Request")
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.appPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                
                
                if viewModel.isLoading {
                    LoadingView()
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.isLoading)
                }
                
                Group {
                    if let error = viewModel.serviceError {
                        let nsError = error as NSError
                        let title = nsError.code == 92001 ? "No Internet Connection" : "Error"
                        let message = nsError.code == 92001
                        ? "Please check your WiFi or cellular data."
                        : nsError.localizedDescription
                        
                        CustomAlertView(
                            title: title,
                            message: message,
                            primaryButtonTitle: "OK",
                            primaryAction: {
                                viewModel.serviceError = nil
                            },
                            secondaryButtonTitle: nil,
                            secondaryAction: nil
                        )
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationBarBackButtonHidden()
                .background(.applicationBGcolor)
        }
    }
}

