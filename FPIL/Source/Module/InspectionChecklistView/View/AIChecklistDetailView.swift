//
//  AIChecklistDetailView.swift
//  FPIL
//
//  Created by OrganicFarmers on 14/05/26.
//

import SwiftUI

//
//  AIChecklistDetailView.swift
//  FPIL
//
//  Created by OrganicFarmers on 14/05/26.
//

import SwiftUI

struct AIChecklistDetailView: View {
    
    let checklist: CheckList?
    
    @ObservedObject var viewModel: JobListViewModel
    
    var onClick: (() -> ())? = nil
    
    @State private var expandedCategories: Set<String> = []
    @State private var isSummaryExpanded = false

    init(
        viewModel: JobListViewModel,
        checklist: CheckList?,
        onClick: (() -> ())? = nil
    ) {
        self.onClick = onClick
        self.viewModel = viewModel
        self.checklist = checklist
    }
    
    // MARK: - Summary Counts
    
    private var totalQuestions: Int {
        checklist?.questions.count ?? 0
    }
    
    private var passCount: Int {
        checklist?.questions.filter {
            $0.answers.first?.status?.lowercased() == "pass"
        }.count ?? 0
    }
    
    private var failCount: Int {
        checklist?.questions.filter {
            $0.answers.first?.status?.lowercased() == "fail"
        }.count ?? 0
    }
    
    private var naCount: Int {
        checklist?.questions.filter {
            $0.answers.first?.status?.lowercased() == "n/a"
        }.count ?? 0
    }
    
    private var compliancePercentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return (Double(passCount) / Double(totalQuestions)) * 100
    }
    
    // MARK: - Grouped Categories
    
    private var groupedCategories: [String: [Question]] {
        Dictionary(grouping: checklist?.questions ?? []) {
            $0.category ?? "Others"
        }
    }
    
    // MARK: - Body
    
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
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 20) {
                        
                        complianceCard
                        
                        inspectionSummaryCard
                        
                        categoryExpandableList
                        
                        actionButtons
                    }
                    .padding()
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
        }
    }
    
    private func planReview(status: Int) {
        guard var selectedItem = viewModel.jobModelAIGenerated else { return }
        
        let date = Date()
        
        selectedItem.status = status
        selectedItem.jobCompletionDate = date
        selectedItem.lastDateToInspection = date
        selectedItem.jobCreatedDate = date
        selectedItem.jobAssignedDate = date
        selectedItem.jobStartDate = date
        selectedItem.reviewNotes = viewModel.selectedAiChecklistModel?.compliance_report?.summary
        
        if let pdfURL = PDFGenerator.generateInspectionPDF(siteInfo: selectedItem, checklistItems: viewModel.checkList) {
            
            viewModel.uploadReviewReport(url: pdfURL) { error, url in
                if error == nil, let url {
                    selectedItem.reportPdfUrl = url
                    viewModel.addOrUpdateInspection(selectedItem, isInvoiceGenerate: false) { error in
                        if error == nil {
                            viewModel.updateStatusAIGeneratedChecklist(id: viewModel.checkList?.id ?? "", updatedItems: ["isVerified":true]) { error in
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
        }
    }
}

// MARK: - Compliance Card

extension AIChecklistDetailView {
    
    private var complianceCard: some View {
        
        VStack(spacing: 20) {
            
            HStack(alignment: .center, spacing: 20) {
                
                ZStack {
                    
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 22)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0, to: compliancePercentage / 100)
                        .stroke(
                            Color.green,
                            style: StrokeStyle(
                                lineWidth: 22,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 150, height: 150)
                    
                    VStack {
                        
                        Text("\(Int(compliancePercentage))%")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Compliant")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 18) {
                    
                    statusRow(
                        color: .green,
                        title: "Pass",
                        value: passCount,
                        percentage: percentage(passCount)
                    )
                    
                    statusRow(
                        color: .red,
                        title: "Fail",
                        value: failCount,
                        percentage: percentage(failCount)
                    )
                    
                    statusRow(
                        color: .yellow,
                        title: "N/A",
                        value: naCount,
                        percentage: percentage(naCount)
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.08))
        .cornerRadius(20)
    }
}

// MARK: - Summary Card

extension AIChecklistDetailView {
    
    private var inspectionSummaryCard: some View {
        
        let summary = viewModel.selectedAiChecklistModel?.compliance_report?.summary ?? ""
        
        return VStack(alignment: .leading, spacing: 16) {
            
            HStack(alignment: .top) {
                
                Text("Inspection Summary")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if summary.count > 150 {
                    Button {
                        withAnimation(.easeInOut) {
                            isSummaryExpanded.toggle()
                        }
                    } label: {
                        Text(isSummaryExpanded ? "Less" : "More")
                            .font(.caption)
                            .foregroundColor(.appPrimary)
                    }
                }
            }
            
            Text(summary)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(isSummaryExpanded ? nil : 6)
                .animation(.easeInOut, value: isSummaryExpanded)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.08))
        .cornerRadius(20)
    }
}

// MARK: - Category Expandable List

extension AIChecklistDetailView {
    
    private var categoryExpandableList: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Category")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(groupedCategories.keys.sorted(), id: \.self) { category in
                
                let questions = groupedCategories[category] ?? []
                
                DisclosureGroup(
                    isExpanded: Binding(
                        get: {
                            expandedCategories.contains(category)
                        },
                        set: { newValue in
                            
                            if newValue {
                                expandedCategories.insert(category)
                            } else {
                                expandedCategories.remove(category)
                            }
                        }
                    )
                ) {
                    
                    VStack(spacing: 14) {
                        
                        ForEach(questions, id: \.question) { question in
                            
                            NavigationLink {
                                
                                AIQuestionDetailView(question: question, viewModel: viewModel)
                                
                            } label: {
                                
                                questionRow(question: question)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 12)
                    
                } label: {
                    
                    categoryHeaderView(
                        category: category,
                        questions: questions
                    )
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.08))
                .cornerRadius(18)
                .accentColor(.white)
            }
        }
    }
}

// MARK: - Category Header

extension AIChecklistDetailView {
    
    @ViewBuilder
    private func categoryHeaderView(
        category: String,
        questions: [Question]
    ) -> some View {
        
        let passedCount = questions.filter {
            $0.answers.first?.status?.lowercased() == "pass"
        }.count
        
        let percentage = Int(
            (Double(passedCount) / Double(max(questions.count, 1))) * 100
        )
        
        HStack {
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(category)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(passedCount)/\(questions.count) Completed")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            ZStack {
                
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                    .frame(width: 55, height: 55)
                
                Circle()
                    .trim(from: 0, to: CGFloat(percentage) / 100)
                    .stroke(
                        progressColor(
                            Double(percentage) / 100
                        ),
                        style: StrokeStyle(
                            lineWidth: 6,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 55, height: 55)
                
                Text("\(percentage)%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Question Row

extension AIChecklistDetailView {
    
    @ViewBuilder
    private func questionRow(question: Question) -> some View {
        
        let status = question.answers.first?.status ?? "N/A"
        
        HStack(spacing: 14) {
            
            Circle()
                .fill(statusColor(status))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(question.question)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                if let reference = question.referenceCode {
                    
                    Text(reference)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text(status)
                .font(.caption.weight(.semibold))
                .foregroundColor(statusColor(status))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(statusColor(status).opacity(0.15))
                .cornerRadius(12)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
    }
}

// MARK: - Action Buttons

extension AIChecklistDetailView {
    
    private var actionButtons: some View {
        
        HStack(spacing: 14) {
            
            actionButton(
                title: "Approve",
                color: .green
            ) {
                planReview(status: 1)
            }
            
            actionButton(
                title: "Decline",
                color: .red
            ) {
                planReview(status: 2)
            }
            
            actionButton(
                title: "Revision",
                color: .blue
            ) {
                planReview(status: 3)
            }
        }
    }
}

// MARK: - Helpers

extension AIChecklistDetailView {
    
    private func percentage(_ value: Int) -> String {
        
        guard totalQuestions > 0 else {
            return "0%"
        }
        
        let result = (Double(value) / Double(totalQuestions)) * 100
        
        return String(format: "%.1f%%", result)
    }
    
    private func progressColor(_ value: Double) -> Color {
        
        if value > 0.7 {
            return .green
        } else if value > 0.4 {
            return .yellow
        } else {
            return .red
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        
        switch status.lowercased() {
        case "pass":
            return .green
            
        case "fail":
            return .red
            
        default:
            return .yellow
        }
    }
}

// MARK: - Status Row

extension AIChecklistDetailView {
    
    @ViewBuilder
    private func statusRow(
        color: Color,
        title: String,
        value: Int,
        percentage: String
    ) -> some View {
        
        HStack(spacing: 10) {
            
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
            
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14))
            
            Spacer()
            
            Text("\(value) (\(percentage))")
                .foregroundColor(.white)
                .font(.system(size: 14))
        }
    }
}

// MARK: - Summary Box

extension AIChecklistDetailView {
    
    @ViewBuilder
    private func summaryBox(
        icon: String,
        title: String,
        count: Int,
        color: Color
    ) -> some View {
        
        VStack(spacing: 10) {
            
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
    }
}

// MARK: - Action Button

extension AIChecklistDetailView {
    
    @ViewBuilder
    private func actionButton(
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action) {
            
            Text(title)
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(color)
                .cornerRadius(14)
        }
    }
}
