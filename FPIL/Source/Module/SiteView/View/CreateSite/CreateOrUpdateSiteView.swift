//
//  CreateOrUpdateSiteView.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/10/25.
//

import SwiftUI
import MapKit

struct CreateOrUpdateSiteView: View {
    @ObservedObject var viewModel: JobListViewModel
    @StateObject private var form: SiteFormState
    var onClick: (() -> ())? = nil
    
    @State private var showConfirmationAlert = false
    @State private var alertType: AlertType? = nil
    @State private var calendarId: Int = 0
    
    @State private var showSearch = false
    @State private var assignTheJob: Bool? = true

    enum AlertType {
        case update
    }
    
    init(viewModel: JobListViewModel, onClick: (() -> ())? = nil, assignTheJob: Bool? = true) {
        self.onClick = onClick
        self.viewModel = viewModel
        self.assignTheJob = assignTheJob
        _form = StateObject(wrappedValue: SiteFormState(buildings: UserDefaultsStore.buildings ?? [], frequencys: UserDefaultsStore.frequency ?? [], site: viewModel.selectedItem, isAssign: assignTheJob ?? false, inspectors: UserDefaultsStore.inspectorsList ?? []))
    }
    
    var body: some View {
        ZStack {
            VStack {
                CustomNavBar(
                    title: viewModel.selectedItem == nil ? "Create Site" : "Update Site Details",
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
                    VStack(alignment: .leading) {
                        let selectedItem = viewModel.selectedItem?.siteName ?? ""
                        HeaderCell(titleString: viewModel.selectedItem == nil ? "Register New Site" : selectedItem)
                            .padding(5)
                            .padding(.top, 15)
                        if viewModel.selectedItem != nil {
                            Text("Site ID: \(viewModel.selectedItem?.id ?? "0")")
                                .font(ApplicationFont.regular(size: 10).value)
                                .foregroundStyle(.white)
                                .padding(.leading, 5)
                        }
                        VStack(alignment: .leading) {
                            BottomBorderTextField(text: $form.siteName, placeholder: "Site Name")
                            HStack {
                                Text("Site Type: ")
                                    .font(ApplicationFont.regular(size: 14).value)
                                    .foregroundStyle(.white)
                                Spacer()
                                CustomPicker(
                                    title: "Site Type",
                                    options: form.buildings,
                                    selection: $form.building,
                                    displayKey: \.buildingName
                                )
                            }.padding(.vertical, 10)
                                .disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.firstName, placeholder: "First Name")
                                .disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.lastName, placeholder: "Last Name")
                                .disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.email, placeholder: "Email")
                                .disabled(viewModel.selectedItem != nil)
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
                                }.disabled(viewModel.selectedItem != nil)
                                
                            }
                            BottomBorderTextField(text: $form.address, placeholder: "Address")
                                .disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.street, placeholder: "Street")
                                .disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.city, placeholder: "City")
                                .disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.zipCode, placeholder: "Zip Code")
                                .disabled(viewModel.selectedItem != nil)
                            BottomBorderTextField(text: $form.contactNumber, placeholder: "Contact Number")
                                .disabled(viewModel.selectedItem != nil)
                            if let isAssign = assignTheJob, (isAssign == true || UserDefaultsStore.profileDetail?.userType == 2) {
                                if isAssign {
                                    HStack {
                                        Text("Assign To: ")
                                            .font(ApplicationFont.regular(size: 14).value)
                                            .foregroundStyle(.white)
                                        Spacer()
                                        
                                        CustomPickerOptionalSelection<FireStationInspectorModel>(
                                            title: "Assign To",
                                            options: form.inspectors,
                                            selection: $form.inspector,
                                            displayKey: \.firstName
                                        )
                                    }.padding(.vertical, 10)
                                }
                                HStack {
                                    Text("Inspection End Date: ")
                                        .font(ApplicationFont.regular(size: 14).value)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 0) {
                                        ZStack {
                                            DatePicker(
                                                "",
                                                selection: Binding (get: {
                                                    form.lastDateToInspection
                                                }, set: { newValue in
                                                    form.lastDateToInspection = newValue
                                                }),
                                                in: Date()...,
                                                displayedComponents: .date
                                            )
                                                .labelsHidden()
                                                .datePickerStyle(.compact)
                                                .id(calendarId)
                                                .onChange(of: form.lastDateToInspection) { _ in
                                                  calendarId += 1
                                                }
                                                .blendMode(.destinationOver)
                                            HStack {
                                                Text(formattedDate(form.lastDateToInspection))
                                                    .foregroundColor(.appPrimary)   // ✅ custom color
                                                    .font(ApplicationFont.regular(size: 14).value)
                                                Image(systemName: "chevron.down")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.red.opacity(0.5))
                                    }
                                }
                                .padding(.vertical, 10)
                            }
                            HStack {
                                Text("Inspection Frequency: ")
                                    .font(ApplicationFont.regular(size: 14).value)
                                    .foregroundStyle(.white)
                                Spacer()
                                CustomPicker(
                                    title: "Inspection Frequency",
                                    options: form.frequencys,
                                    selection: $form.inspectionFrequency,
                                    displayKey: \.frequencyName
                                )
                            }.padding(.vertical, 10)
                                .padding(.bottom, 20)
                                .disabled(viewModel.selectedItem != nil)
                        }.padding(5)
                    }.padding(5)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
                        .background(Color.inspectionCellBG)
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                }
                .padding()
                
                if viewModel.selectedItem == nil {
                    VStack {
                        Button(action: {
                            saveOrganisation()
                        }) {
                            Text("Register & Generate QR")
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color.appPrimary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: form.clearForm) {
                            Text("Clear")
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                } else {
                    VStack {
                        Button(action: {
                            alertType = .update
                            showConfirmationAlert = true
                        }) {
                            Text("Update & Re-Generate QR")
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color.appPrimary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
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
                    message: Text("Are you sure you want to update this Site details?"),
                    primaryButton: .destructive(Text("Yes")) {
                        saveOrganisation(isInvoiceGenerate: false)
                    },
                    secondaryButton: .cancel()
                )
            case .none:
                return Alert(title: Text("Unknown Action"))
            }
        }

        
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    private func saveOrganisation(isInvoiceGenerate: Bool = true) {

        let errors = form.validate()
        
        guard errors.isEmpty else {
            // Show alert with first error
            viewModel.serviceError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errors.first as Any])
            return
        }
        
        let jobModel: JobModel = form.buildJobModelForInspector()
        
        viewModel.addOrUpdateInspection(jobModel, isInvoiceGenerate: isInvoiceGenerate) { error in
            if error == nil {
                DispatchQueue.main.async {
                    viewModel.selectedItem = nil
                    onClick?()
                }
            }
        }
    }
}
