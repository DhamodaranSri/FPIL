//
//  DocReviewChecklistView.swift
//  FPIL
//
//  Created by OrganicFarmers on 12/01/26.
//

import SwiftUI

struct DocReviewChecklistView: View {
    @ObservedObject var viewModel: JobListViewModel
    var onClick: (() -> ())? = nil
    @State private var showPicker = false
    @State private var selectedFileName: String?
    @State private var projectName = ""
    @State private var squreFoot = ""
    @State private var occupancy = ""
    @StateObject private var form: DocReviewState
    @State private var expandedSections: Set<String> = []
    @State var createdById: String? = UserDefaultsStore.profileDetail?.id
    @State var stationId: String = UserDefaultsStore.profileDetail?.parentId ?? ""
    @FocusState private var focusedItemID: String?
    @State var checkList: CheckList? = CheckList(
        id:UUID().uuidString,
        checkListName: "Fire Code Compliance Checklist",
        questions: [
            Question(question: "Means of Egress", answers: [
                Answers(
                    answer: "Exit Width Calculation",
                    isSelected: true,
                    voilationDescription: "Required width: 30 minimum. Exit width meets requirements."
                ),
                Answers(
                    answer: "Number of Exits",
                    isSelected: true,
                    voilationDescription: "Two exits sufficient for this area."
                ),
                Answers(
                    answer: "Exit Separation Distance",
                    isSelected: true,
                    voilationDescription: "Exits separated by at least 1/2 diagonal distance of area served."
                ),
                Answers(
                    answer: "Dead-end Corridors",
                    isSelected: true,
                    isVoilated: true,
                    voilationDescription: "Dead-end corridors must not exceed 50 feet (NFPA 101)."
                )
            ]),
            Question(question: "Fire Protection Systems", answers: [
                Answers(
                    answer: "Sprinkler System Coverage",
                    isSelected: true,
                    voilationDescription: "NFPA 13 compliant sprinkler system required for this occupancy."
                ),
                Answers(
                    answer: "Fire Alarm System",
                    isSelected: true,
                    voilationDescription: "Addressable fire alarm system with voice evacuation capability."
                ),
                Answers(
                    answer: "Standpipe System",
                    isSelected: true,
                    isVoilated: true,
                    voilationDescription: "Class III standpipe system recommended for industrial facilities."
                )
            ]),
            Question(question: "Fire-Resistance Ratings", answers: [
                Answers(
                    answer: "Structural Frame",
                    isSelected: true,
                    voilationDescription: "2-hour fire-resistance rating required for Type II construction."
                ),
                Answers(
                    answer: "Shaft Enclosures",
                    isSelected: false,
                    voilationDescription: "2-hour rated enclosures for vertical shafts."
                ),
                Answers(
                    answer: "Fire Barriers",
                    isSelected: true,
                    voilationDescription: "1-hour fire barriers between occupancy separations."
                )
            ]),
            Question(question: "Accessibility & Special Hazards", answers: [
                Answers(
                    answer: "Areas of Refuge",
                    isSelected: true,
                    voilationDescription: "Areas of refuge provided on each floor above grade."
                ),
                Answers(
                    answer: "Hazardous Materials Storage",
                    isSelected: true,
                    voilationDescription: "Separate storage with appropriate ventilation and containment."
                ),
                Answers(
                    answer: "Emergency Vehicle Access",
                    isSelected: true,
                    voilationDescription: "Fire lane width minimum 20 feet with adequate turning radius."
                )
            ])
        ],
        totalAverageScore: 92,
        totalVoilations: 2,
        totalImagesAttached: 0,
        totalNotesAdded: 0,
        estimatedInspectionPrice: 0
    )
    
    init(viewModel: JobListViewModel, onClick: (() -> ())? = nil) {
        self.onClick = onClick
        self.viewModel = viewModel
        _form = StateObject(wrappedValue: DocReviewState(clients: UserDefaultsStore.allClientDetail ?? [], selectedClient: nil))
    }
    
    var body: some View {
        ZStack {
            VStack {
                CustomNavBar(
                    title: "Review Inspection",
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
                    if selectedFileName == nil {
                        UploadDocumentView(message: "Please upload your document", buttonTitle: "Upload") {
                            showPicker = true
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 10) {
                            HStack(alignment: .center, spacing: 20) {
                                Text("Selected Document: ")
                                    .foregroundColor(.white)
                                    .font(ApplicationFont.regular(size: 18).value)
                                Text(selectedFileName ?? "")
                                    .foregroundColor(.white)
                                    .font(ApplicationFont.bold(size: 18).value)
                            }
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
                                .multilineTextAlignment(.trailing)
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
                            
                            if let client = form.client {
                                Text("Site Address: \(client.gpsAddress)")
                                    .font(ApplicationFont.regular(size: 14).value)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                
                                Text("Building Type: \(client.clientType?.clientTypeName ?? "")")
                                    .font(ApplicationFont.regular(size: 14).value)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                
                                HStack {
                                    Text("Square Footage: ")
                                        .font(ApplicationFont.regular(size: 14).value)
                                        .foregroundColor(.white)
                                    Spacer()
                                    TextField(
                                        "",
                                        text: $squreFoot
                                    )
                                    .focused($focusedItemID, equals: "answer.answer")
                                    .font(ApplicationFont.bold(size: 14).value)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 4)
                                    .background(Color.white)
                                    
                                }
                                HStack {
                                    Text("Occupancy Load: ")
                                        .font(ApplicationFont.regular(size: 14).value)
                                        .foregroundColor(.white)
                                    Spacer()
                                    TextField(
                                        "",
                                        text: $occupancy
                                    )
                                    .focused($focusedItemID, equals: "answer.answer")
                                    .font(ApplicationFont.bold(size: 14).value)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 4)
                                    .background(Color.white)
                                    
                                }
                            }
                            if let questions = checkList?.questions {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 16) {
                                        answerList(for: questions)
                                    }
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.5), lineWidth: 1))
                                }
                                
                                HStack(alignment: .top) {
                                    Button("Approve") {
                                        planReview(status: 1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    Button("Decline") {
                                        planReview(status: 2)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    
                                    Button("Revision") {
                                        planReview(status: 3)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }.frame(maxWidth: .infinity)
                                .padding(.bottom, 20)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 1))
                            .background(Color.inspectionCellBG)
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                        
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationBarBackButtonHidden()
                .background(.applicationBGcolor)
                .onAppear() {
                }
                .sheet(isPresented: $showPicker) {
                    DocumentPicker { url in
                        guard let url = url else {
                            selectedFileName = nil
                            return
                        }
                        selectedFileName = url.lastPathComponent
                        // TODO: Handle uploading here
                        print("Picked File URL:", url)
                    }
                }
            
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
    
    private func planReview(status: Int) {
        var selectedItem = buildJobModelForInspector()
        
        selectedItem.status = status
        
        if let pdfURL = PDFGenerator.generateInspectionPDF(siteInfo: selectedItem, checklistItems: checkList) {
            
            viewModel.uploadReviewReport(url: pdfURL) { error, url in
                if error == nil, let url {
                    selectedItem.reportPdfUrl = url
                    
                    viewModel.addOrUpdateInspection(selectedItem, isInvoiceGenerate: false) { error in
                        DispatchQueue.main.async {
                            if error == nil {
                                viewModel.selectedItem = nil
                                onClick?()
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    func buildJobModelForInspector() -> JobModel {
        
        return JobModel(
            id: "Site-\(getShortUUID())-\((createdById ?? "").getShortID())",
            siteName: projectName,
            address: form.client?.address ?? "",
            city: form.client?.city ?? "",
            street: form.client?.street ?? "",
            zipCode: form.client?.zipCode ?? "",
            geoLocationAddress: form.client?.gpsAddress ?? "",
            latitude: form.client?.latitude ?? 0.0,
            longitude: form.client?.longitude ?? 0.0,
            clientId: form.client?.id,
            firstName: form.client?.firstName ?? "",
            lastName: form.client?.lastName ?? "",
            phone: form.client?.contactNumber ?? "",
            email: form.client?.email ?? "",
            alternateContactNumber: "",
            building: Building(buildingName: "Fire Code Compliance", checkLists: [checkList!]),
            inspectionFrequency: InspectionFrequency(frequencyName: "year"),
            isCompleted: true,
            jobCreatedDate: Date(),
            createdById: createdById,
            stationId: stationId,
            lastDateToInspection: Date(),
            jobAssignedDate: Date(),
            client: form.client
        )
    }
    
    private func answerList(for questions: [Question]) -> some View {
        VStack {
            ForEach(questions, id: \.question) { section in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedSections.contains(section.question) },
                        set: { newValue in
                            if newValue {
                                expandedSections.insert(section.question)
                            } else {
                                expandedSections.remove(section.question)
                            }
                        }
                    )
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(section.answers.indices, id: \.self) { answerIndex in
                            let answer = section.answers[answerIndex]
                            
                            VStack(alignment: .leading) {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.red.opacity(0.5))
                                    .padding(.vertical, 10)
                                HStack {
                                    Button {
                                        //toggleAnswerSelection(questionId: section.question, answerIndex: answerIndex)
                                    } label: {
                                        Image(answer.isSelected ? "check_done" : "check")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.white)
                                    }
                                    Text(answer.answer)
                                        .font(ApplicationFont.regular(size: 12).value)
                                        .foregroundColor(.white)
                                    Spacer()
                                }.frame(maxWidth: .infinity)
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("is violated?")
                                            .font(ApplicationFont.regular(size: 10).value)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("Add Photos")
                                            .font(ApplicationFont.regular(size: 10).value)
                                            .foregroundColor(.white)
                                    }
                                    HStack {
                                        let isSelected = answer.isVoilated ?? false
                                        RadioButton(
                                            title: "Yes",
                                            isSelected: isSelected
                                        ) {
                                            //toggleVolationSelection(questionId: section.question, answerIndex: answerIndex, isVolation: true)
                                        }
                                        
                                        RadioButton(
                                            title: "No",
                                            isSelected: !isSelected
                                        ) {
                                           // toggleVolationSelection(questionId: section.question, answerIndex: answerIndex, isVolation: false)
                                        }
                                        Spacer()
                                        CameraCaptureView(
                                            existingPhotoURL: answer.photoUrl,
                                            onUploadComplete: { image in
                                            },
                                            removeUploadedPhoto: {
                                               
                                            }
                                        )
                                    }
                                    Text("Notes / Violations:")
                                        .font(ApplicationFont.regular(size: 10).value)
                                        .foregroundColor(.white)
                                        TextEditor(
                                            text: Binding(
                                                get: {
                                                    answer.voilationDescription ?? ""
                                                },
                                                set: { newValue in
                                                    
                                                }
                                            )
                                        )
//                                        .focused($focusedItemID, equals: answer.answer)
                                        .scrollContentBackground(.hidden)
                                        .background(.white)
                                        .frame(height: 50)
                                        .font(.system(size: 13))
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                }
                            }
                            .disabled(true)
                            .padding(.bottom, 5)
                        }
                    }
                    .padding(.top, 20)
                } label: {
                    Text(section.question)
                        .font(ApplicationFont.bold(size: 12).value)
                        .foregroundColor(.white)
                }
                .tint(Color.white)
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                )
            }
        }
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

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL?) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {

        let supportedTypes: [UTType] = [
            .pdf,
            .image,
            UTType(filenameExtension: "docx")!, // docx support
            UTType(filenameExtension: "doc")!   // optional doc support
        ]
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                parent.onPick(nil)
                return
            }
            parent.onPick(url)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onPick(nil)
        }
    }
}


class DocReviewState: ObservableObject {


    @Published var client: ClientModel? = nil
    
    let clients: [ClientModel]

    init(
        clients: [ClientModel] = [],
        selectedClient: ClientModel? = nil
    ) {
        self.clients = clients
        self.client = selectedClient
    }
}
