//
//  CreateOrUpdateClientView.swift
//  FPIL
//
//  Created by OrganicFarmers on 24/10/25.
//

import SwiftUI

struct CreateOrUpdateClientView: View {
    @ObservedObject var viewModel: ClientListViewModel
    @StateObject private var form: ClientFormState
    @State private var isEditMode: Bool = false
    var onClick: (() -> ())? = nil
    @FocusState private var focusedItemID: String?
    
    @State private var showConfirmationAlert = false
    @State private var alertType: AlertType? = nil
    @State private var showSearch = false

    enum AlertType {
        case update
        case toggleStatus
    }
    
    init(viewModel: ClientListViewModel, onClick: (() -> ())? = nil) {
        self.onClick = onClick
        self.viewModel = viewModel
        _form = StateObject(
            wrappedValue:
                ClientFormState(
                    buildings: UserDefaultsStore.buildings ?? [],
                    clientTypes: UserDefaultsStore.clientType ?? [],
                    client: viewModel.selectedItem
                )
        )
    }
    
    var body: some View {
        ZStack {
            VStack {
                CustomNavBar(
                    title: viewModel.selectedItem == nil ? "Create Client" : "Client Details",
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
                        HeaderCell(titleString: "Client info")
                            .padding(5)
                            .padding(.top, 15)
                        VStack(alignment: .leading) {
                            BottomBorderTextField(text: $form.firstName, placeholder: "First Name")
                            BottomBorderTextField(text: $form.lastName, placeholder: "Last Name")
                            HStack {
                                Text("Client Type: ")
                                    .font(ApplicationFont.regular(size: 14).value)
                                    .foregroundStyle(.white)
                                Spacer()
                                
                                CustomPickerOptionalSelection<ClientType>(
                                    title: "Client Type",
                                    options: form.clientTypes,
                                    selection: $form.clientType,
                                    displayKey: \.clientTypeName
                                )
                            }.padding(.vertical, 10)
                            BottomBorderTextField(text: Binding(
                                get: { form.organizationName ?? "" },
                                set: { form.organizationName = $0 }
                            ), placeholder: "Organization Name")
                            BottomBorderTextField(text: $form.email, placeholder: "Email")
                            Button {
                                showSearch = true
                            } label: {
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    if form.geoLocationAddress.count > 0 {
                                        Text(form.geoLocationAddress)
                                            .font(ApplicationFont.regular(size: 14).value)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 8)
                                            .multilineTextAlignment(.leading)
                                    } else {
                                        Text("Geo Location Address")
                                            .foregroundColor(.gray)
                                            .font(ApplicationFont.regular(size: 14).value)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 8)
                                            .multilineTextAlignment(.leading)
                                    }

                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.red.opacity(0.5)) // bottom border
                                }
                                
                            }
                            BottomBorderTextField(text: $form.address, placeholder: "Address")
                            BottomBorderTextField(text: $form.street, placeholder: "Street")
                            BottomBorderTextField(text: $form.city, placeholder: "City")
                            BottomBorderTextField(text: $form.zipCode, placeholder: "Zip Code")
                            BottomBorderTextField(text: $form.contactNumber, placeholder: "Contact Number")
                            
                            Text("Notes:")
                                .font(ApplicationFont.regular(size: 10).value)
                                .foregroundColor(.white)
                                TextEditor(
                                    text: Binding(
                                        get: {
                                            form.notes ?? ""
                                        },
                                        set: { newValue in
                                            form.notes = newValue
                                        }
                                    )
                                )
                                .focused($focusedItemID, equals: "Notes:")
                                .scrollContentBackground(.hidden)
                                .background(.white)
                                .frame(height: 50)
                                .font(.system(size: 13))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()

                        }.padding(5)
                            .disabled(viewModel.selectedItem != nil && !isEditMode)
                    }.padding(5)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
                        .background(Color.inspectionCellBG)
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    focusedItemID = nil
                                }
                                .tint(.blue)
                            }
                        }
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

//                            Button(action: {
//                                alertType = .toggleStatus
//                                showConfirmationAlert = true
//                            }) {
//                                Text(viewModel.selectedItem?.status == 0 ? "Tap to Activate" : "Tap to Deactivate")
//                                    .frame(height: 40)
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.gray)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(10)
//                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                    }
                }
                
            }
            .sheet(isPresented: $showSearch) {
                AppleLocationSearchView(selectedAddress: $form.geoLocationAddress, coordinate: $form.coordinate)
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
                    message: Text("Are you sure you want to update this Client details?"),
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
        
        viewModel.addClient(newOrg) { error in
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
        
        viewModel.updateClient(newOrg) { error in
            if error == nil {
                DispatchQueue.main.async {
                    viewModel.selectedItem = nil
                    onClick?()
                }
            }
        }
    }
}
