//
//  AIQuestionDetailView.swift
//  FPIL
//
//  Created by OrganicFarmers on 19/05/26.
//

import SwiftUI

//struct AIQuestionDetailView: View {
//    
//    let question: Question
//    @ObservedObject var viewModel: JobListViewModel
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        ZStack {
//            
//            VStack {
//                CustomNavBar(
//                    title: question.question,
//                    showBackButton: true,
//                    actions: [],
//                    backgroundColor: .applicationBGcolor,
//                    titleColor: .appPrimary,
//                    backAction: {
//                        dismiss()
//                    }
//                )
//            }.frame(maxWidth: .infinity, maxHeight: .infinity)
//                .navigationBarBackButtonHidden()
//                .background(.applicationBGcolor)
//            
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
//        }
//        
////        ScrollView {
////            
////            VStack(alignment: .leading, spacing: 20) {
////                
////                VStack(alignment: .leading, spacing: 12) {
////                    
////                    Text(question.question)
////                        .font(.title3.bold())
////                        .foregroundColor(.white)
////                    
////                    if let reference = question.referenceCode {
////                        
////                        Text(reference)
////                            .font(.footnote)
////                            .foregroundColor(.orange)
////                    }
////                    
////                    if let category = question.category {
////                        
////                        Text(category)
////                            .font(.caption)
////                            .foregroundColor(.gray)
////                    }
////                }
////                
////                ForEach(question.answers.indices, id: \.self) { index in
////                    
////                    let answer = question.answers[index]
////                    
////                    VStack(alignment: .leading, spacing: 16) {
////                        
////                        HStack {
////                            
////                            Text(answer.status ?? "N/A")
////                                .font(.caption.bold())
////                                .foregroundColor(statusColor(answer.status ?? ""))
////                                .padding(.horizontal, 14)
////                                .padding(.vertical, 8)
////                                .background(
////                                    statusColor(answer.status ?? "")
////                                        .opacity(0.15)
////                                )
////                                .cornerRadius(12)
////                            
////                            Spacer()
////                        }
////                        
////                        Text(answer.answer)
////                            .foregroundColor(.white)
////                            .font(.body)
////                        
////                        if let violation = answer.voilationDescription,
////                           !violation.isEmpty {
////                            
////                            VStack(alignment: .leading, spacing: 8) {
////                                
////                                Text("Violation Notes")
////                                    .font(.headline)
////                                    .foregroundColor(.red)
////                                
////                                Text(violation)
////                                    .foregroundColor(.white)
////                            }
////                            .padding()
////                            .background(Color.red.opacity(0.12))
////                            .cornerRadius(16)
////                        }
////                    }
////                    .padding()
////                    .background(Color.white.opacity(0.05))
////                    .cornerRadius(18)
////                }
////            }
////            .padding()
////        }
////        .background(Color.black.ignoresSafeArea())
////        .navigationTitle("Question Detail")
////        .navigationBarTitleDisplayMode(.inline)
//    }
//    
//    private func statusColor(_ status: String) -> Color {
//        
//        switch status.lowercased() {
//        case "pass":
//            return .green
//            
//        case "fail":
//            return .red
//            
//        default:
//            return .yellow
//        }
//    }
//}



import SwiftUI

struct AIQuestionDetailView: View {
    
    let question: Question
    @ObservedObject var viewModel: JobListViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 20) {
                
                CustomNavBar(
                    title: "Selected Item Details",
                    showBackButton: true,
                    actions: [],
                    backgroundColor: .clear,
                    titleColor: .appPrimary,
                    backAction: {
                        dismiss()
                    }
                )
                if let answer = question.answers.first {
                    inspectionCard(answer: answer)
                    
//                    if showButton(answer.status ?? "") {
//                        actionButtons
//                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.08, green: 0.08, blue: 0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - UI Components
extension AIQuestionDetailView {
    
    private func inspectionCard(answer: Answers) -> some View {
        
        VStack(alignment: .leading, spacing: 22) {
            
            topSection(answer: answer)
            
            divider
            
            infoSection(
                title: "Category",
                value: question.category ?? "-"
            )
            
            infoSection(
                title: "Requirement",
                value: question.question
            )
            
            infoSection(
                title: "Code Reference",
                value: question.referenceCode ?? "-"
            )
            
            infoSection(
                title: "Notes / Observations",
                value: answer.voilationDescription ?? answer.answer
            )
            
//            infoSection(
//                title: "Recommendation",
//                value: answer.recommendation ?? "-"
//            )
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.06),
                            Color.white.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    private func topSection(answer: Answers) -> some View {
        
        HStack(alignment: .top, spacing: 14) {
            
            ZStack {
                
                Circle()
                    .fill(statusColor(answer.status ?? "").opacity(0.18))
                    .frame(width: 64, height: 64)
                
                Image(systemName: statusIcon(answer.status ?? ""))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(statusColor(answer.status ?? ""))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(question.question)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(question.referenceCode ?? "-")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            statusBadge(answer.status ?? "")
        }
    }
    
    private func statusBadge(_ status: String) -> some View {
        
        Text(status.capitalized)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(statusColor(status))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(statusColor(status).opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(statusColor(status).opacity(0.3), lineWidth: 1)
            )
    }
    
    private func infoSection(title: String, value: String) -> some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
            
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
            
            divider
        }
    }
    
    private var divider: some View {
        
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
    }
    
    private var actionButtons: some View {
        
        HStack(spacing: 14) {
            
            Button {
                
            } label: {
                
                HStack(spacing: 10) {
                    
                    Image(systemName: "checkmark")
                    
                    Text("Mark as Pass")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [
                            Color.orange,
                            Color.red.opacity(0.9)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
        }
    }
}

// MARK: - Helpers
extension AIQuestionDetailView {
    
    private func statusColor(_ status: String) -> Color {
        
        switch status.lowercased() {
        case "pass":
            return .green
            
        case "fail":
            return .red
            
        default:
            return .orange
        }
    }
    
    private func statusIcon(_ status: String) -> String {
        
        switch status.lowercased() {
        case "pass":
            return "checkmark"
            
        case "fail":
            return "xmark"
            
        default:
            return "exclamationmark"
        }
    }
    
    private func showButton(_ status: String) -> Bool {
        
        switch status.lowercased() {
        case "pass":
            return false
            
        case "fail":
            return true
            
        default:
            return true
        }
    }
}
