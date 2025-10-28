//
//  InvoiceGenerationView.swift
//  FPIL
//
//  Created by OrganicFarmers on 26/10/25.
//

import SwiftUI

struct InvoiceGenerationView: View {
    @StateObject private var form: InvoiceFormState
    var onClick: (() -> ())? = nil
    
    
    init(onClick: (() -> ())? = nil) {
        self.onClick = onClick
        _form = StateObject(
            wrappedValue:
                InvoiceFormState(buildings: UserDefaultsStore.buildings ?? [])
        )
    }
    
    var body: some View {
        ZStack {
            VStack {
                CustomNavBar(
                    title: "Estimated Invoice",
                    showBackButton: true,
                    actions: [],
                    backgroundColor: .applicationBGcolor,
                    titleColor: .appPrimary,
                    backAction: {
                        onClick?()
                    }
                )
                ScrollView {
                    VStack(alignment: .leading) {

                        VStack(alignment: .leading) {
                            HStack {
                                Text("Building Type: ")
                                    .font(ApplicationFont.regular(size: 14).value)
                                    .foregroundStyle(.white)
                                Spacer()
                                
                                CustomPickerOptionalSelection<Building>(
                                    title: "Building Type",
                                    options: form.buildings,
                                    selection: $form.building,
                                    displayKey: \.buildingName
                                )
                            }.padding(.vertical, 10)
                            
                            HStack {
                                Button {
                                    //toggleAnswerSelection(questionId: section.question, answerIndex: answerIndex)
                                } label: {
                                    Image("check_done")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                }
                                Text("Basic Fire Inspection")
                                    .font(ApplicationFont.regular(size: 12).value)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("$150")
                                    .font(ApplicationFont.bold(size: 13).value)
                                    .foregroundColor(.white)
                            }.frame(maxWidth: .infinity)
                            
                            HStack {
                                Button {
                                    //toggleAnswerSelection(questionId: section.question, answerIndex: answerIndex)
                                } label: {
                                    Image("check_done")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                }
                                Text("QR Site Registration")
                                    .font(ApplicationFont.regular(size: 12).value)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("$50")
                                    .font(ApplicationFont.bold(size: 13).value)
                                    .foregroundColor(.white)
                            }.frame(maxWidth: .infinity)

                        }.padding(5)
                    }.padding(5)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
                        .background(Color.inspectionCellBG)
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                }
                .padding()
                
                Button(action: saveOrganisation) {
                    Text("Generate Invoice & Share")
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(Color.appPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.padding()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarBackButtonHidden()
            .background(.applicationBGcolor)
            
//            if viewModel.isLoading {
//                LoadingView()
//                    .transition(.opacity)
//                    .animation(.easeInOut, value: viewModel.isLoading)
//            }
//            
//            Group {
//                if let error = viewModel.serviceError {
//                    let nsError = error as NSError
//                    let title = nsError.code == 92001 ? "No Internet Connection" : "Error"
//                    let message = nsError.code == 92001
//                    ? "Please check your WiFi or cellular data."
//                    : nsError.localizedDescription
//                    
//                    CustomAlertView(
//                        title: title,
//                        message: message,
//                        primaryButtonTitle: "OK",
//                        primaryAction: {
//                            viewModel.serviceError = nil
//                        },
//                        secondaryButtonTitle: nil,
//                        secondaryAction: nil
//                    )
//                }
//            }
        }
    }
    
    func saveOrganisation() {
        
    }
}

#Preview {
    InvoiceGenerationView()
}
