//
//  PDFGenerator.swift
//  FPIL
//
//  Created by OrganicFarmers on 23/10/25.
//

import Foundation
import UIKit
import PDFKit
import SwiftUI

struct PDFGenerator {
    
    static func generateInspectionPDF(
        siteInfo: JobModel?,
        checklistItems: CheckList?,
        fileName: String = "InspectionReport"
    ) -> URL? {
        
        guard let checklistItems, let siteInfo else {
            return nil
        }
        
        let pdfMetaData = [
            kCGPDFContextCreator: "Inspection App",
            kCGPDFContextAuthor: "Inspection Team",
            kCGPDFContextTitle: "Site Inspection Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 40
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition = margin
            
            let subHeaderFont = ApplicationFont.bold(size: 20).uiValue
            let subTitleFont = ApplicationFont.bold(size: 14).uiValue
            let titleFont = ApplicationFont.regular(size: 12).uiValue
            let subValueFont = ApplicationFont.regular(size: 11).uiValue
            
            // --- Document Title Header ---
            let header = "Fire Safety Plan Review Report"
            let headerFont = ApplicationFont.bold(size: 25).uiValue
            let headerAttributes: [NSAttributedString.Key: Any] = [.font: headerFont]
            let headerSize = header.size(withAttributes: headerAttributes)
            let headerX = (pageWidth - headerSize.width) / 2
            
            header.draw(at: CGPoint(x: headerX, y: yPosition), withAttributes: headerAttributes)
            yPosition += headerSize.height + 15
            
            // --- Status Header ---
            let status = siteInfo.status == 1 ? "Approved" : siteInfo.status == 2 ? "Decline" : "Revision"
            let statusAttributes: [NSAttributedString.Key: Any] = [
                .font: subHeaderFont,
                .foregroundColor: siteInfo.status == 1 ? UIColor.green : siteInfo.status == 2 ? UIColor.red : UIColor.blue
            ]
            let statusSize = status.size(withAttributes: statusAttributes)
            let statusX = (pageWidth - statusSize.width) / 2
            
            status.draw(at: CGPoint(x: statusX, y: yPosition), withAttributes: statusAttributes)
            yPosition += statusSize.height + 25
            
            // --- Inspection Report Sub-Section Label ---
            let titleText = "Inspection Report"
            titleText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: subHeaderFont])
            yPosition += subHeaderFont.lineHeight + 15
            
            // --- Site Information Fields ---
            func drawLine(label: String, value: String) {
                label.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: subTitleFont])
                value.draw(at: CGPoint(x: margin + 130, y: yPosition), withAttributes: [.font: titleFont])
                yPosition += 22
            }
            
            drawLine(label: "Site Name:", value: siteInfo.siteName)
            drawLine(label: "Site Address:", value: siteInfo.address)
            drawLine(label: "Inspector:", value: siteInfo.inspectorName ?? "No Inspector")
            drawLine(label: "Review Date:", value: Date().convertDateAloneFromFullDateFormat())
            drawLine(label: "Score:", value: "\(checklistItems.totalAverageScore ?? 0)%")
            
            yPosition += 15
            
            // Core bounding width constraint configuration
            let contentWidth = pageWidth - (2 * margin)
            
            // --- Dynamic Review Comments Section ---
            let remarksHeader = "Review Comments"
            remarksHeader.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: 30), withAttributes: [.font: subHeaderFont])
            yPosition += subHeaderFont.lineHeight + 8
            
            let remarks = siteInfo.reviewNotes ?? "-"
            let remarksAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.black]
            
            // 🚀 FIXED: Dynamic bounding layout size calculation for comments paragraph
            let remarksBoundingRect = remarks.boundingRect(
                with: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: remarksAttributes,
                context: nil
            )
            remarks.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: remarksBoundingRect.height), withAttributes: remarksAttributes)
            yPosition += remarksBoundingRect.height + 25
            
            // --- Inspection Checklist Header ---
            let checklistHeader = "Inspection Checklist"
            checklistHeader.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: 30), withAttributes: [.font: subHeaderFont])
            yPosition += subHeaderFont.lineHeight + 12
            
            // --- Core Checklist Query Loop ---
            for (index, item) in checklistItems.questions.enumerated() {
                
                // Construct text criteria values
                let itemTitle = "\(index + 1). \(item.question)"
                let questionAttributes: [NSAttributedString.Key: Any] = [.font: subTitleFont, .foregroundColor: UIColor.black]
                
                // 🚀 FIXED: Dynamic bounding layout computation for multi-line questions
                let questionBoundingRect = itemTitle.boundingRect(
                    with: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: questionAttributes,
                    context: nil
                )
                
                // Page-break prevention verification gate check
                if yPosition + questionBoundingRect.height + 40 > pageHeight - margin {
                    context.beginPage()
                    yPosition = margin
                }
                
                itemTitle.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: questionBoundingRect.height), withAttributes: questionAttributes)
                yPosition += questionBoundingRect.height + 8
                
                // --- Sub-Answers Core Layout loop ---
                for subItem in item.answers {
                    let statusLine = "\(subItem.answer)"
                    let rowHeight: CGFloat = 20
                    let checkboxSize: CGFloat = 14
                    
                    let textColor: UIColor = (subItem.isVoilated ?? false) ? .warningBG : ((subItem.isSelected) ? .pdfAnsweredText : .black)
                    let answerAttributes: [NSAttributedString.Key: Any] = [
                        .font: titleFont,
                        .foregroundColor: textColor
                    ]
                    
                    let textX = margin + 15 + checkboxSize + 10
                    let textWidth = contentWidth - (textX - margin)
                    
                    // 🚀 FIXED: Dynamic height calculation for multi-line checkbox answer text strings
                    let answerBoundingRect = statusLine.boundingRect(
                        with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: answerAttributes,
                        context: nil
                    )
                    
                    // Validate page space availability for this line item option row block
                    if yPosition + max(rowHeight, answerBoundingRect.height) + 15 > pageHeight - margin {
                        context.beginPage()
                        yPosition = margin
                    }
                    
                    // Render Context Checkbox Square Frame
                    let checkboxRect = CGRect(
                        x: margin + 15,
                        y: yPosition + (max(rowHeight, answerBoundingRect.height) - checkboxSize) / 2,
                        width: checkboxSize,
                        height: checkboxSize
                    )
                    
                    let checkboxImageName = subItem.isSelected ? "check_done" : "check"
                    if let checkboxImage = UIImage(named: checkboxImageName) {
                        checkboxImage.draw(in: checkboxRect)
                    }
                    
                    // Render row text string next to checkbox square
                    statusLine.draw(in: CGRect(x: textX, y: yPosition, width: textWidth, height: answerBoundingRect.height), withAttributes: answerAttributes)
                    yPosition += answerBoundingRect.height + 6
                    
                    // --- Handle Violation Descriptions Append Context ---
                    if let description = subItem.voilationDescription, !description.isEmpty {
                        let singleLine = description
                            .components(separatedBy: .newlines)
                            .filter { !$0.isEmpty }
                            .joined(separator: " ")
                        
                        let violationDescription = "Violations: \(singleLine)"
                        let violationAttributes: [NSAttributedString.Key: Any] = [.font: subValueFont, .foregroundColor: UIColor.red]
                        
                        let violationBoundingRect = violationDescription.boundingRect(
                            with: CGSize(width: contentWidth - 35, height: CGFloat.greatestFiniteMagnitude),
                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                            attributes: violationAttributes,
                            context: nil
                        )
                        
                        if yPosition + violationBoundingRect.height + 10 > pageHeight - margin {
                            context.beginPage()
                            yPosition = margin
                        }
                        
                        violationDescription.draw(in: CGRect(x: margin + 35, y: yPosition, width: contentWidth - 35, height: violationBoundingRect.height), withAttributes: violationAttributes)
                        yPosition += violationBoundingRect.height + 6
                    }
                }
                
                yPosition += 10 // Safe spacing spacer buffer block gap before next structural question begins
            }
        }
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(siteInfo.id ?? fileName).pdf")
        do {
            try data.write(to: outputURL)
            print("✅ PDF successfully created at \(outputURL.path)")
            return outputURL
        } catch {
            print("❌ PDF generation runtime execution failures caught:", error)
            return nil
        }
    }
}
