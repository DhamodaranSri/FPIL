//
//  CreateOrganisationView.swift
//  FPIL
//
//  Created by OrganicFarmers on 22/09/25.
//

import SwiftUI

struct CreateOrganisationView: View {
    @ObservedObject var viewModel: OrganisationViewModel
    @StateObject private var form: OrganisationFormState
    @State private var isEditMode: Bool = false
    var onClick: (() -> ())? = nil
    
    @State private var showConfirmationAlert = false
    @State private var alertType: AlertType? = nil

    enum AlertType {
        case update
        case toggleStatus
    }
    
    init(viewModel: OrganisationViewModel, onClick: (() -> ())? = nil) {
        self.onClick = onClick
        self.viewModel = viewModel
        _form = StateObject(wrappedValue: OrganisationFormState(
            timeZones: [
                Timezone(id: "1", name: "CA"),
                Timezone(id: "2", name: "EST"),
                Timezone(id: "3", name: "IST")
            ],
            jurisdictions: [
                Jurisdiction(id: "1", name: "California", code: "CA"),
                Jurisdiction(id: "2", name: "Texas", code: "TX"),
                Jurisdiction(id: "3", name: "New York", code: "NY")
            ],
            codeReferences: [
                CodeReference(id: "1", name: "Ref-1"),
                CodeReference(id: "2", name: "Ref-2"),
                CodeReference(id: "3", name: "Ref-3")
            ],
            billingCycles: [
                BillingCycle(id: "1", name: "Monthly"),
                BillingCycle(id: "2", name: "Quarterly"),
                BillingCycle(id: "3", name: "Yearly")
            ],
            organisation: viewModel.selectedItem
        ))
    }
    
    var body: some View {
        ZStack {
            VStack {
                CustomNavBar(
                    title: viewModel.selectedItem == nil ? "Create Firestation" : viewModel.selectedItem?.firestationName ?? "",
                    showBackButton: true,
                    actions: (viewModel.selectedItem == nil || viewModel.selectedItem?.status == 0) ? [] : [
                        NavBarAction(icon: "edit") {
                            isEditMode = true
                        }
                    ],
                    backgroundColor: .applicationBGcolor,
                    titleColor: .appPrimary,
                    backAction: {
                        viewModel.selectedItem = nil
                        onClick?()
                    }
                )
                ScrollView {
                    VStack(alignment: .leading) {
                        HeaderCell(titleString: "Firestation Info")
                            .padding(5)
                            .padding(.top, 15)
                        VStack(alignment: .leading) {
                            BottomBorderTextField(text: $form.firestationName, placeholder: "Firestation Name")
                            BottomBorderTextField(text: $form.stationCode, placeholder: "Firesation Code")//.disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.firestationAddress, placeholder: "Firesation Address")//.disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.street, placeholder: "Street")//.disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.city, placeholder: "City")//.disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.zipCode, placeholder: "Zip Code")//.disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.firestationContactNumber, placeholder: "Firesation Contact Number")
                            BottomBorderTextField(text: $form.firestationAdminEmail, placeholder: "Firesation Admin Email")//.disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.firestationCheifFirstName, placeholder: "Firesation Cheif First Name")
                            BottomBorderTextField(text: $form.firestationCheifLastName, placeholder: "Last Name")
                            BottomBorderTextField(text: $form.firestationCheifContactNumber, placeholder: "Firesation Cheif Contact Number")
                        }.padding(5)
                            .disabled(viewModel.selectedItem != nil && !isEditMode)
                        
                        HeaderCell(titleString: "Additional Details")
                            .padding(5)
                        
                        VStack(alignment: .leading) {
                            
                            HStack {
                                Text("Jurisdiction: ")
                                    .font(ApplicationFont.regular(size: 14).value)
                                    .foregroundStyle(.white)
                                Spacer()
                                CustomPicker(
                                    title: "Jurisdiction",
                                    options: form.jurisdictions,
                                    selection: $form.selectedJurisdiction,
                                    displayKey: \.name
                                ).disabled(true)
                            }.padding(.horizontal, 10)
                            
                            HStack {
                                Text("Code Reference: ")
                                    .font(ApplicationFont.regular(size: 14).value)
                                    .foregroundStyle(.white)
                                Spacer()
                                CustomPicker(
                                    title: "Code Reference",
                                    options: form.codeReferences,
                                    selection: $form.selectedCodeReference,
                                    displayKey: \.name
                                ).disabled(true)
                            }.padding(.horizontal, 10)
                                .padding(.bottom, 20)
                            
                        }
                    }.padding(5)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
                        .background(Color.inspectionCellBG)
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                }
                .padding()
                
                if viewModel.selectedItem == nil {
                    HStack {
                        Button(action: form.clearForm) {
                            Text("Clear")
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: saveOrganisation) {
                            Text("Save")
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(Color.appPrimary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                } else {
                    if isEditMode || viewModel.selectedItem?.status == 0 {
                        VStack {
                            if viewModel.selectedItem?.status == 1 {
                                Button(action: {
                                    alertType = .update
                                    showConfirmationAlert = true
                                }) {
                                    Text("Update")
                                        .frame(height: 40)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.appPrimary)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }

                            Button(action: {
                                alertType = .toggleStatus
                                showConfirmationAlert = true
                            }) {
                                Text(viewModel.selectedItem?.status == 0 ? "Tap to Activate" : "Tap to Deactivate")
                                    .frame(height: 40)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                    }
                }
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
        }.alert(isPresented: $showConfirmationAlert) {
            switch alertType {
            case .update:
                return Alert(
                    title: Text("Confirm Update"),
                    message: Text("Are you sure you want to update this firestation details?"),
                    primaryButton: .destructive(Text("Yes")) {
                        updateOrganisation()
                    },
                    secondaryButton: .cancel()
                )
            case .toggleStatus:
                let isDeactivating = viewModel.selectedItem?.status == 1
                return Alert(
                    title: Text(isDeactivating ? "Confirm Deactivation" : "Confirm Activation"),
                    message: Text(isDeactivating ? "Do you really want to deactivate this account?" : "Do you want to activate this account?"),
                    primaryButton: .destructive(Text("Yes")) {
                        activateOrDeactivateAccount()
                    },
                    secondaryButton: .cancel()
                )
            case .none:
                return Alert(title: Text("Unknown Action"))
            }
        }

        
    }
    
    private func saveOrganisation() {

        let errors = form.validate()
        
        guard errors.isEmpty else {
            // Show alert with first error
            viewModel.serviceError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errors.first as Any])
            return
        }
        
        let newOrg = form.buildOrganisation()
        
        viewModel.addOrganisation(newOrg) { error in
            if error == nil {
                DispatchQueue.main.async {
                    viewModel.selectedItem = nil
                    onClick?()
                }
            }
        }
    }
    
    private func updateOrganisation() {
        updateFireStation()
    }
    
    private func activateOrDeactivateAccount() {
        form.status = viewModel.selectedItem?.status == 0 ? 1 : 0
        updateFireStation()
    }
    
    private func updateFireStation() {
        let errors = form.validate()
        
        guard errors.isEmpty else {
            // Show alert with first error
            viewModel.serviceError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errors.first as Any])
            return
        }
        
        let newOrg = form.buildOrganisation()
        
        viewModel.updateOrganisation(newOrg) { error in
            if error == nil {
                DispatchQueue.main.async {
                    viewModel.selectedItem = nil
                    onClick?()
                }
            }
        }
    }
}

#Preview {
    CreateOrganisationView(viewModel: OrganisationViewModel())
}
