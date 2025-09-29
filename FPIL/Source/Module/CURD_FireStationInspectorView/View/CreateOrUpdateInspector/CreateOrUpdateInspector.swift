//
//  CreateOrUpdateInspector.swift
//  FPIL
//
//  Created by OrganicFarmers on 27/09/25.
//

import SwiftUI

struct CreateOrUpdateInspector: View {
    @ObservedObject var viewModel: InspectorsListViewModel
    @StateObject private var form: InspectorFormState
    @State private var isEditMode: Bool = false
    var onClick: (() -> ())? = nil
    
    @State private var showConfirmationAlert = false
    @State private var alertType: AlertType? = nil

    enum AlertType {
        case update
        case toggleStatus
    }
    
    init(viewModel: InspectorsListViewModel, onClick: (() -> ())? = nil) {
        self.onClick = onClick
        self.viewModel = viewModel
        _form = StateObject(wrappedValue: InspectorFormState(
            positions: [
                FireStationEmployeeJobDesignations(id: "LxlaYK5OeeDpXLfO9mpm", position: "Inspector", userTypeId: 3),
                FireStationEmployeeJobDesignations(id: "mYzbfkzhM0nWIUOY9AV1", position: "Volunteer", userTypeId: 4)
            ],
            inspector: viewModel.selectedItem
        ))
    }
    
    var body: some View {
        ZStack {
            VStack {
                CustomNavBar(
                    title: viewModel.selectedItem == nil ? "Create Inspector" : "Inspector Details",
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
                        HeaderCell(titleString: "Inspector info")
                            .padding(5)
                            .padding(.top, 15)
                        VStack(alignment: .leading) {
                            BottomBorderTextField(text: $form.firstName, placeholder: "First Name")
                            BottomBorderTextField(text: $form.lastName, placeholder: "Last Name")
                            if form.selectedPosition.userTypeId == 3 {
                                BottomBorderTextField(text: $form.employeeId, placeholder: "Employee ID")
                            }
                            HStack {
                                Text("Position: ")
                                    .font(ApplicationFont.regular(size: 14).value)
                                    .foregroundStyle(.white)
                                Spacer()
                                CustomPicker(
                                    title: "Position",
                                    options: form.positions,
                                    selection: $form.selectedPosition,
                                    displayKey: \.position
                                )
                            }.padding(.vertical, 10)
                            BottomBorderTextField(text: $form.email, placeholder: "Official Email")
                            BottomBorderTextField(text: $form.stationCode, placeholder: "Firesation Code").disabled(true)
                            BottomBorderTextField(text: $form.address, placeholder: "Address")
                            BottomBorderTextField(text: $form.street, placeholder: "Street")
                            BottomBorderTextField(text: $form.city, placeholder: "City")
                            BottomBorderTextField(text: $form.zipCode, placeholder: "Zip Code")
                            BottomBorderTextField(text: $form.contactNumber, placeholder: "Contact Number").padding(.bottom, 20)
                        }.padding(5)
                            .disabled(viewModel.selectedItem != nil && !isEditMode)
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
                    message: Text("Are you sure you want to update this Inspector details?"),
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
        
        let newOrg = form.buildInspector()
        
        viewModel.addInspector(newOrg) { error in
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
        
        let newOrg = form.buildInspector()
        
        viewModel.updateInspector(newOrg) { error in
            if error == nil {
                DispatchQueue.main.async {
                    viewModel.selectedItem = nil
                    onClick?()
                }
            }
        }
    }
}
