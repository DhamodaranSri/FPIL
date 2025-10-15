//
//  InspectionChecklistView.swift
//  FPIL
//
//  Created by OrganicFarmers on 08/10/25.
//

import SwiftUI

struct InspectionChecklistView: View {
    @ObservedObject var viewModel: JobListViewModel
    var onClick: (() -> ())? = nil
    @State private var expandedSections: Set<String> = []
    @State private var selectedPhotoAnswerID: String?
    @FocusState private var focusedItemID: String?
    
    init(viewModel: JobListViewModel, onClick: (() -> ())? = nil) {
        self.onClick = onClick
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack {
                CustomNavBar(
                    title: "Inspection Checklist",
                    showBackButton: true,
                    actions: [],
                    backgroundColor: .applicationBGcolor,
                    titleColor: .appPrimary,
                    backAction: {
                        viewModel.selectedItem = nil
                        onClick?()
                    }
                )
                let progress = viewModel.totalQuestions() == 0 ? 0 : Double(viewModel.totalSelected()) / Double(viewModel.totalQuestions())
                VStack {
                    HStack{
                        HStack(alignment: .center, spacing: 20) {
                            let textColor: Color = Int(progress * 100) >= 90 ? .green : Int(progress * 100) >= 80 && Int(progress * 100) < 90 ? .blue : .appPrimary
                            Text("\(Int(progress * 100))%")
                                .foregroundColor(textColor)
                                .font(ApplicationFont.bold(size: 26).value)
                            VStack(alignment: .leading) {
                                Image("score")
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                let score = Int(progress * 100) >= 90 ? "Excellent Score" : Int(progress * 100) >= 80 && Int(progress * 100) < 90 ? "Good Score" : "Bad Score"
                                Text(score)
                                    .foregroundColor(.white)
                                    .font(ApplicationFont.regular(size: 12).value)
                            }
                        }.frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 1))
                            .background(Color.inspectionCellBG)
                            .cornerRadius(8)
                            .contentShape(Rectangle())
                        
                        HStack(alignment: .center, spacing: 20) {
                            Text("\(viewModel.totalViolations())")
                                .foregroundColor(.appPrimary)
                                .font(ApplicationFont.bold(size: 26).value)
                            VStack(alignment: .leading) {
                                Image("violations")
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                Text("Violations")
                                    .foregroundColor(.white)
                                    .font(ApplicationFont.regular(size: 12).value)
                            }
                        }.frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 1))
                            .background(Color.inspectionCellBG)
                            .cornerRadius(8)
                            .contentShape(Rectangle())
                    }.padding(.horizontal, 10)
                    
                    HStack{
                        HStack(alignment: .center, spacing: 20) {
                            Text("\(0)")
                                .foregroundColor(.appPrimary)
                                .font(ApplicationFont.bold(size: 26).value)
                            VStack(alignment: .leading) {
                                Image("image")
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                Text("Photos Addes")
                                    .foregroundColor(.white)
                                    .font(ApplicationFont.regular(size: 12).value)
                            }
                        }.frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 1))
                            .background(Color.inspectionCellBG)
                            .cornerRadius(8)
                            .contentShape(Rectangle())
                        
                        HStack(alignment: .center, spacing: 20) {
                            Text("\(viewModel.totalNotesAdded())")
                                .foregroundColor(.appPrimary)
                                .font(ApplicationFont.bold(size: 26).value)
                            VStack(alignment: .leading) {
                                Image("notes")
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                Text("Notes Added")
                                    .foregroundColor(.white)
                                    .font(ApplicationFont.regular(size: 12).value)
                            }
                        }.frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 1))
                            .background(Color.inspectionCellBG)
                            .cornerRadius(8)
                            .contentShape(Rectangle())
                    }.padding(.horizontal, 10)
                }.padding(.horizontal, 5)
                
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(viewModel.checkList?.checkListName ?? "")
                                .font(ApplicationFont.bold(size: 14).value)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 0) {
                                Text("\(viewModel.totalSelected())")
                                    .font(ApplicationFont.bold(size: 13).value)
                                    .foregroundColor(.appPrimary)
                                Text("/\(viewModel.totalQuestions()) Items Checked")
                                    .font(ApplicationFont.regular(size: 12).value)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            HStack {
                                ProgressView(value: progress)
                                    .tint(.appPrimary)
                                    .frame(width: 80, height: 10)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                Text("\(Int(progress * 100))%")
                                    .font(ApplicationFont.regular(size: 12).value)
                                    .foregroundColor(.appPrimary)
                                Spacer()
                            }
                            
                        }
                        
                        if let questions = viewModel.checkList?.questions {
                            answerList(for: questions)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.5), lineWidth: 1))
                    
                }.padding(.horizontal, 15)
                    .padding(.bottom, 10)
                    
                if (viewModel.selectedItem?.isCompleted ?? false) == false {
                    HStack {
                        VStack (alignment: .leading){
                            HStack (alignment: .center) {
                                Text(viewModel.selectedItem?.inspectorName ?? "")
                                    .foregroundColor(.white)
                                    .font(ApplicationFont.bold(size: 12).value)
                                Text("Active")
                                    .foregroundColor(.white)
                                    .font(ApplicationFont.regular(size: 8).value)
                            }
                            HStack {
                                ProgressView(value: progress)
                                    .tint(.appPrimary)
                                    .frame(width: 80, height: 10)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                Text("\(Int(progress * 100))%")
                                    .font(ApplicationFont.regular(size: 12).value)
                                    .foregroundColor(.appPrimary)
                                Spacer()
                            }
                        }
                        
                        // ⏱ Add timer here
                        if let selectedItem = viewModel.selectedItem {
                            Group {
                                let elapsed = Date().timeIntervalSince(selectedItem.jobStartDate ?? Date())
                                Spacer()
                                TimerView(isRunning: true, startTime: elapsed)
                            }
                        }
                        
                        Button {
                            let completedDate = Date()
                            var updatedItems: [String: Any] = [
                                "isCompleted": true,
                                "jobCompletionDate": completedDate
                            ]
                            
                            if var selectedItem = viewModel.selectedItem {
                               // let duration = completedDate.timeIntervalSince(selectedItem.jobStartDate ?? Date())
                                let elapsed = completedDate.timeIntervalSince(selectedItem.jobStartDate ?? Date())
                                if let lastVisit = LastVisit(id: UUID().uuidString, inspectorId: UserDefaultsStore.profileDetail?.id ?? "", inspectorName: (UserDefaultsStore.profileDetail?.firstName ?? "") + " " + (UserDefaultsStore.profileDetail?.lastName ?? ""), visitDate: selectedItem.jobStartDate ?? Date(), inspectionFrequency: selectedItem.inspectionFrequency, totalScore: Int(progress * 100), totalSpentTime: elapsed, totalVoilations: viewModel.totalViolations()).toFirestoreData() {
                                    updatedItems["lastVist"] = [lastVisit]
                                }
                                
                                if let checkList = viewModel.checkList {
                                    selectedItem.building.checkLists[0] = checkList
                                }
                                
                                if let building = selectedItem.building.toFirestoreData() {
                                    updatedItems["building"] = building
                                }
                                
                                viewModel.updateStartOrStopInspectionDate(jobModel: selectedItem, updatedItems: updatedItems) { error in
                                    DispatchQueue.main.async {
                                        if error == nil {
                                            UserDefaultsStore.jobStartedDate = nil
                                            UserDefaultsStore.startedJobDetail = nil
                                            viewModel.selectedItem = nil
                                            onClick?()
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image("pause")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.appPrimary.opacity(0.2))
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationBarBackButtonHidden()
                .background(.applicationBGcolor)
                .onAppear() {
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
                                        toggleAnswerSelection(questionId: section.question, answerIndex: answerIndex)
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
                                    
                                    // ✅ Image Preview
//                                    if let uiImage = answersState[answer.answer ?? ""]?.photo {
//                                        Image(uiImage: uiImage)
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(height: 120)
//                                            .clipped()
//                                            .cornerRadius(10)
//                                            .padding(.leading, 28)
//                                    }
                                    HStack {
                                        let isSelected = answer.isVoilated ?? false
                                        RadioButton(
                                            title: "Yes",
                                            isSelected: isSelected
                                        ) {
                                            toggleVolationSelection(questionId: section.question, answerIndex: answerIndex, isVolation: true)
                                        }
                                        
                                        RadioButton(
                                            title: "No",
                                            isSelected: !isSelected
                                        ) {
                                            toggleVolationSelection(questionId: section.question, answerIndex: answerIndex, isVolation: false)
                                        }
                                        Spacer()
                                        CameraCaptureView(
                                            existingPhotoURL: answer.photoUrl,
                                            onUploadComplete: { image in
                                                viewModel.uploadInspectionPhotoToFirebase(image: image, job: viewModel.selectedItem) { error, url in
                                                    if error == nil, let url {
                                                        updatePhotos(questionId: section.question, answerIndex: answerIndex, photoUrl: url)
                                                    }
                                                }
                                            },
                                            removeUploadedPhoto: {
                                                if let url = answer.photoUrl {
                                                    viewModel.deleteUploadedImage(url: url) { error, isDeleteComplete in
                                                        if isDeleteComplete {
                                                            updatePhotos(questionId: section.question, answerIndex: answerIndex, photoUrl: "")
                                                        }
                                                    }
                                                }
                                            }
                                        )
//                                        Button{
//                                            
//                                        } label:{
//                                            Image(systemName: "camera")
//                                                .foregroundColor(.white)
//                                        }
                                    }
                                    Text("Notes / Violations:")
                                        .font(ApplicationFont.regular(size: 10).value)
                                        .foregroundColor(.white)
//                                    if answer.isVoilated ?? false {
                                        TextEditor(
                                            text: Binding(
                                                get: {
                                                    answer.voilationDescription ?? ""
                                                },
                                                set: { newValue in
                                                    updateVoilationDescription(
                                                        questionId: section.question,
                                                        answerIndex: answerIndex,
                                                        description: newValue
                                                    )
                                                }
                                            )
                                        )
                                        .focused($focusedItemID, equals: answer.answer)
                                        .scrollContentBackground(.hidden)
                                        .background(.white)
                                        .frame(height: 50)
                                        .font(.system(size: 13))
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
//                                    }
                                }
                            }
                            .disabled(viewModel.selectedItem?.isCompleted ?? false)
                            .padding(.bottom, 5)
                        }
                    }
                    .padding(.top, 10)
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
//                                                    hideKeyboard()
                }
                .tint(.blue)
            }
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func toggleAnswerSelection(questionId: String, answerIndex: Int) {
        guard var checkList = viewModel.checkList else { return }
        
        if let questionIndex = checkList.questions.firstIndex(where: { $0.question == questionId }) {
            checkList.questions[questionIndex].answers[answerIndex].isSelected.toggle()
            viewModel.checkList = checkList // reassign to trigger @Published update
            UserDefaultsStore.startedJobDetail?.building.checkLists[0] = checkList
        }
    }

    private func toggleVolationSelection(questionId: String, answerIndex: Int, isVolation: Bool) {
        guard var checkList = viewModel.checkList else { return }
        
        if let questionIndex = checkList.questions.firstIndex(where: { $0.question == questionId }) {
            checkList.questions[questionIndex].answers[answerIndex].isVoilated = isVolation
            viewModel.checkList = checkList // reassign to trigger @Published update
            UserDefaultsStore.startedJobDetail?.building.checkLists[0] = checkList
        }
    }

    private func updateVoilationDescription(questionId: String, answerIndex: Int, description: String) {
        guard var checkList = viewModel.checkList else { return }
        
        if let questionIndex = checkList.questions.firstIndex(where: { $0.question == questionId }) {
            checkList.questions[questionIndex].answers[answerIndex].voilationDescription = description
            viewModel.checkList = checkList // reassign to trigger update
            UserDefaultsStore.startedJobDetail?.building.checkLists[0] = checkList
        }
    }
    
    private func updatePhotos(questionId: String, answerIndex: Int, photoUrl: String) {
        guard var checkList = viewModel.checkList else { return }
        
        if let questionIndex = checkList.questions.firstIndex(where: { $0.question == questionId }) {
            checkList.questions[questionIndex].answers[answerIndex].photoUrl = photoUrl.isEmpty ? nil : photoUrl
            viewModel.checkList = checkList // reassign to trigger update
            UserDefaultsStore.startedJobDetail?.building.checkLists[0] = checkList
        }
    }

}

//#Preview {
//    InspectionChecklistView()
//}

struct RadioButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(.appPrimary)
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 13))
            }
        }
        .buttonStyle(.plain)
    }
}
