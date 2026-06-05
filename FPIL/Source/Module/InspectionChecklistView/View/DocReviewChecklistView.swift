//
//  DocReviewChecklistView.swift
//  FPIL
//
//  Created by OrganicFarmers on 12/01/26.
//

import SwiftUI

struct DocReviewChecklistView: View {
    @Binding var path: NavigationPath
    @ObservedObject var viewModel: JobListViewModel
    var onClick: (() -> ())? = nil
    @State private var showPicker = false
    @State private var isLoading: Bool = false
    @State private var siteId: String?
    @State private var projectName = ""
    @StateObject private var form: DocReviewState
    @State private var expandedSections: Set<String> = []
    @State var createdById: String? = UserDefaultsStore.profileDetail?.id
    @State var stationId: String = UserDefaultsStore.profileDetail?.parentId ?? ""
    @FocusState private var focusedItemID: String?
    
    init(viewModel: JobListViewModel, path: Binding<NavigationPath>, onClick: (() -> ())? = nil) {
        self.onClick = onClick
        self.viewModel = viewModel
        self._path = path
        _form = StateObject(wrappedValue: DocReviewState(clients: UserDefaultsStore.allClientDetail ?? [], selectedClient: nil))
    }
    
    var body: some View {
        ZStack {
            VStack {
                CustomNavBar(
                    title: "AI - Review Inspection",
                    showBackButton: true,
                    actions: [],
                    backgroundColor: .applicationBGcolor,
                    titleColor: .appPrimary,
                    backAction: {
                        viewModel.selectedItem = nil
                        onClick?()
                    }
                )
                
                Group {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Project Name: ")
                                .font(ApplicationFont.regular(size: 14).value)
                                .foregroundColor(.white)
                            Spacer()
                            TextField(
                                "",
                                text: $projectName
                            )
                            .focused($focusedItemID, equals: "answer.answer")
                            .font(ApplicationFont.bold(size: 14).value)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.black)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 4)
                            .background(Color.white)
                        }
                        HStack {
                            Text("Client: ")
                                .font(ApplicationFont.regular(size: 14).value)
                                .foregroundStyle(.white)
                            Spacer()
                            CustomPickerOptionalSelection<ClientModel>(
                                title: "Client",
                                options: form.clients,
                                selection: $form.client,
                                displayKey: \.fullName
                            )
                        }.padding(.vertical, 10)
                        UploadDocumentView(message: "Please upload your document", buttonTitle: "Upload") {
                            if form.client != nil, projectName.count > 0 {
                                showPicker = true
                            }
                        }
                        
                        HStack {
                            Text("AI Generated Inspections List: ")
                                .font(ApplicationFont.regular(size: 14).value)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                aiCheckListGeneratedListView(for: viewModel.aiChecklistArray)
                            }
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 1))
                        .background(Color.inspectionCellBG)
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .onAppear {
                            viewModel.fetchAIGeneratedAllChecklists()
                        }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationBarBackButtonHidden()
                .background(.applicationBGcolor)
                .onAppear() {
                }
                .sheet(isPresented: $showPicker) {
                    DocumentPicker { result in

                        switch result {
                        case .success(let url):
                            siteId = "Site-\(getShortUUID())-\((createdById ?? "").getShortID())-AI"
                            isLoading = true
                            self.viewModel.uploadSitePlanReport(url: url, siteId: siteId ?? "", clientDetails: form.client, projectName: projectName) { error, uploadedUrl in
                                isLoading = false
                                if error == nil {
                                    self.viewModel.fetchAIGeneratedAllChecklists()
                                } else {
                                    isLoading = false
                                }
                            }
                        case .failure(let error):
                            isLoading = false
                            viewModel.serviceError = error
                            return
                        }
                    }
                }

            if viewModel.isLoading || isLoading {
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
    
    private func aiCheckListGeneratedListView(for checklists: [CheckList]) -> some View {
        VStack {
            ForEach(checklists, id: \.id) { checklist in
                HStack {
                    Text(checklist.checkListName)
                        .font(ApplicationFont.bold(size: 12).value)
                        .foregroundColor(.white)
                    Spacer()
                    Text(checklist.aiCheckListStatus ?? "")
                        .font(ApplicationFont.regular(size: 10).value)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.5), lineWidth: 1))
                .onTapGesture {
                    
                    if checklist.aiCheckListStatus?.caseInsensitiveCompare("completed") != .orderedSame {
                        viewModel.serviceError = NSError(domain: "Checklists can be opened only when the status is Completed.", code: 92002)
                        return
                    }
                    
                    guard let matchedChecklist = viewModel.aiGeneratedSiteChecklist.first(where: {
                        $0.request_id == checklist.id
                    }) else {
                        return
                    }
                    
                    guard let client = matchedChecklist.client else {
                        return
                    }

                    viewModel.checkList = checklist
                    viewModel.jobModelAIGenerated = buildJobModelForInspector(client: client, checkList: checklist)
                    viewModel.selectedAiChecklistModel = matchedChecklist
                    path.append("aiChecklistPage")
                }
            }
        }
    }
    
    func buildJobModelForInspector(client: ClientModel, checkList: CheckList) -> JobModel {
        let siteName = projectName.count > 0 ? projectName : (form.client?.fullName ?? siteId)
        return JobModel(
            id: checkList.id,
            siteName: checkList.checkListName,
            address: client.address,
            city: client.city,
            street: client.street,
            zipCode: client.zipCode,
            geoLocationAddress: client.gpsAddress,
            latitude: client.latitude,
            longitude: client.longitude,
            clientId: client.id,
            firstName: client.firstName,
            lastName: client.lastName,
            phone: client.contactNumber,
            email: client.email,
            alternateContactNumber: "",
            building: Building(buildingName: siteName ?? "", checkLists: [checkList]),
            inspectionFrequency: InspectionFrequency(frequencyName: "year"),
            isCompleted: true,
            jobCreatedDate: Date(),
            createdById: "\(createdById) - AI Generated",
            stationId: stationId,
            lastDateToInspection: Date(),
            jobAssignedDate: Date(),
            client: form.client
        )
    }
}

struct UploadDocumentView: View {
    let message: String
    let buttonTitle: String
    let primaryAction: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text(message)
                .foregroundColor(.gray)
                .font(.headline)
            Button(action: primaryAction) {
                Text(buttonTitle)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
