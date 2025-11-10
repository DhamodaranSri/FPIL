//
//  InvoiceGenerationView.swift
//  FPIL
//
//  Created by OrganicFarmers on 26/10/25.
//

import SwiftUI

struct InvoiceGenerationView: View {
    @StateObject private var form: InvoiceFormState
    @ObservedObject var viewModel: InvoiceViewModel
    var onClick: (() -> ())? = nil
    
    
    init(viewModel: InvoiceViewModel, onClick: (() -> ())? = nil) {
        self.viewModel = viewModel
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
                            
                            ForEach(viewModel.items, id: \.serviceName) { section in
                                HStack(spacing: 10) {
                                    Button {
                                        viewModel.chooseTheService(item: section)
                                        //toggleAnswerSelection(questionId: section.question, answerIndex: answerIndex)
                                    } label: {
                                        if (section.isDefault ?? false) == true || (section.isSelected ?? false) == true {
                                            Image("check_done")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(.white)
                                        } else {
                                            Image("check")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(.white)
                                        }
                                        
                                    }
                                    Text(section.serviceName ?? "")
                                        .font(ApplicationFont.regular(size: 12).value)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(String(format: "$%.2f", section.price ?? 0.00))
                                        .font(ApplicationFont.bold(size: 13).value)
                                        .foregroundColor(.white)
                                }.frame(maxWidth: .infinity)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 10)
                            }

                        }.padding(5)
                    }.padding(5)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
                        .background(Color.inspectionCellBG)
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                }
                .padding()
                VStack (spacing: 5) {
                    let subTotal = viewModel.items
                        .filter { ($0.isSelected ?? false) || ($0.isDefault ?? false) }
                        .reduce(0.0) { $0 + ($1.price ?? 0.0) }
                    let tax = subTotal * 8 / 100
                    let totalAmount = subTotal + tax
                    HStack {
                        Text("Sub Total:")
                            .font(ApplicationFont.bold(size: 15).value)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(String(format: "$%.2f", subTotal))
                            .font(ApplicationFont.bold(size: 15).value)
                            .foregroundStyle(.white)
                    }
                    HStack {
                        Text("Tax (8%):")
                            .font(ApplicationFont.bold(size: 15).value)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(String(format: "$%.2f", tax))
                            .font(ApplicationFont.bold(size: 15).value)
                            .foregroundStyle(.white)
                    }
                    HStack {
                        Text("Estimated Total:")
                            .font(ApplicationFont.bold(size: 18).value)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(String(format: "$%.2f", totalAmount))
                            .font(ApplicationFont.bold(size: 18).value)
                            .foregroundStyle(.white)
                    }
                }.padding(.horizontal, 15)
                    .padding(.vertical, 5)
                
                
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
        }
    }
    
    func saveOrganisation() {
        let errors = form.validateForm()
        
        guard errors.isEmpty else {
            // Show alert with first error
            viewModel.serviceError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errors.first as Any])
            return
        }
        guard let building = form.building else {
            viewModel.serviceError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Need Building"])
            return
        }
        viewModel.generateInvoice(building: building) { invoice, result in
            DispatchQueue.main.async {
                if result == nil {
                    viewModel.client = nil
                    onClick?()
                }
            }
        }
    }
}

