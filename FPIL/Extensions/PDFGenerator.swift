//
//  PDFGenerator.swift
//  FPIL
//
//  Created by OrganicFarmers on 23/10/25.
//

import Foundation
import UIKit
import PDFKit
import SwiftUICore

struct PDFGenerator {
    
    static func generateInspectionPDF(
        siteInfo: JobModel?,
        checklistItems: CheckList?,
        fileName: String = "InspectionReport.pdf"
    ) -> URL? {
        
        guard let checklistItems else {
            return nil
        }
        
        guard let siteInfo else {
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
            let subTitleFont = ApplicationFont.bold(size: 16).uiValue
            let titleFont = ApplicationFont.regular(size: 14).uiValue
            let subValueFont = ApplicationFont.regular(size: 12).uiValue
            
            let header = "Fire Safety Plan Review Report"
            let headerFont = ApplicationFont.bold(size: 25).uiValue
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: headerFont
            ]

            // Measure header width
            let headerSize = header.size(withAttributes: headerAttributes)

            // Calculate centered x position
            let headerX = (pageWidth - headerSize.width) / 2
            let headerY = yPosition // typically top margin

            // Draw the header centered on the page
            header.draw(at: CGPoint(x: headerX, y: headerY), withAttributes: headerAttributes)

            // Update y position for next content
            yPosition += headerSize.height + 20
            
            let status = siteInfo.status == 1 ? "Approved" : siteInfo.status == 2 ? "Decline" : "Revision"
            
            let statusAttributes: [NSAttributedString.Key: Any] = [
                .font: subHeaderFont,
                .foregroundColor: siteInfo.status == 1 ? UIColor.green : siteInfo.status == 2 ? UIColor.red : UIColor.blue
            ]

            // Measure header width
            let statusSize = status.size(withAttributes: statusAttributes)

            // Calculate centered x position
            let statusX = (pageWidth - statusSize.width) / 2
            let statusY = yPosition // typically top margin

            // Draw the header centered on the page
            status.draw(at: CGPoint(x: statusX, y: statusY), withAttributes: statusAttributes)

            // Update y position for next content
            yPosition += statusSize.height + 5
            
            // MARK: - Header
            let title = "Inspection Report"
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: subHeaderFont])
            
            yPosition += 40
            
            // MARK: - Site Information Section
            func drawLine(label: String, value: String) {
                let labelFont = subTitleFont
                let valueFont = titleFont
                
                label.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: labelFont])
                value.draw(at: CGPoint(x: margin + 130, y: yPosition), withAttributes: [.font: valueFont])
                
                yPosition += 22
            }
            
            drawLine(label: "Site Name:", value: siteInfo.siteName)
            drawLine(label: "Site Address:", value: siteInfo.address)
            drawLine(label: "Inspector:", value: siteInfo.inspectorName ?? "No Inspector")
            drawLine(label: "Review Date:", value: Date().convertDateAloneFromFullDateFormat())
            drawLine(label: "Score:", value: "\(checklistItems.totalAverageScore ?? 0)%")
            
            yPosition += 20
            
            // MARK: - Checklist Section Header
            
            // Page setup
            let contentWidth = pageWidth - 2 * margin

            // --- Remarks Header ---
            let remarksHeader = "Review Comments"
            remarksHeader.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: CGFloat.greatestFiniteMagnitude),
                               withAttributes: [.font: subHeaderFont])
            yPosition += subHeaderFont.lineHeight + 5

            // --- Remarks Text ---
            let remarks = siteInfo.reviewNotes ?? "-"
            remarks.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: CGFloat.greatestFiniteMagnitude),
                         withAttributes: [.font: titleFont])
            yPosition += titleFont.lineHeight * CGFloat(remarks.components(separatedBy: "\n").count) + 10

            // --- Checklist Header ---
            let checklistHeader = "Inspection Checklist"
            checklistHeader.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: CGFloat.greatestFiniteMagnitude),
                                 withAttributes: [.font: subHeaderFont])
            yPosition += subHeaderFont.lineHeight + 10

            // --- Checklist Items ---
            for (index, item) in checklistItems.questions.enumerated() {
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = margin
                }

                // Question
                let itemTitle = "\(index + 1). \(item.question)"
                itemTitle.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: CGFloat.greatestFiniteMagnitude),
                               withAttributes: [.font: subTitleFont])
                yPosition += subTitleFont.lineHeight * CGFloat(itemTitle.components(separatedBy: "\n").count) + 5

                // Answers
                for (subIndex, subItem) in item.answers.enumerated() {
                    let statusLine = "\(subItem.answer)"
                    let lineHeight: CGFloat = 30
                    let checkboxSize: CGFloat = 16
                    
                    // Checkbox
                    let checkboxRect = CGRect(
                        x: margin + 15,
                        y: yPosition + (lineHeight - checkboxSize)/2,
                        width: checkboxSize,
                        height: checkboxSize
                    )
                    
                    let checkboxImageName = subItem.isSelected ? "check_done" : "check"
                    if let checkboxImage = UIImage(named: checkboxImageName) {
                        checkboxImage.draw(in: checkboxRect)
                    }

                    // Text next to checkbox
                    let textX = checkboxRect.maxX + 10
                    let textRect = CGRect(x: textX, y: yPosition, width: contentWidth - (textX - margin), height: CGFloat.greatestFiniteMagnitude)
                    let textColor: UIColor = subItem.isVoilated ?? false ? .warningBG : (subItem.isSelected ? .pdfAnsweredText : .black)
                    let textDrawAttributes: [NSAttributedString.Key: Any] = [
                        .font: titleFont,
                        .foregroundColor: textColor
                    ]
                    statusLine.draw(in: textRect, withAttributes: textDrawAttributes)
                    
                    // Compute height of the text for proper yPosition increment
                    let textHeight = statusLine.boundingRect(
                        with: CGSize(width: textRect.width, height: CGFloat.greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: textDrawAttributes,
                        context: nil
                    ).height
                    yPosition += max(lineHeight, textHeight) + 5

                    // Violation Description
                    if let description = subItem.voilationDescription {
                        let singleLine = description
                            .components(separatedBy: .newlines)
                            .filter { !$0.isEmpty }
                            .joined(separator: " ")
                        let voilationDesctiption = "Voilations: \(singleLine)"
                        let descriptionRect = CGRect(x: margin + 20, y: yPosition, width: contentWidth - 20, height: CGFloat.greatestFiniteMagnitude)
                        voilationDesctiption.draw(in: descriptionRect, withAttributes: [.font: subValueFont])
                        
                        let descriptionHeight = voilationDesctiption.boundingRect(
                            with: CGSize(width: descriptionRect.width, height: CGFloat.greatestFiniteMagnitude),
                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                            attributes: [.font: subValueFont],
                            context: nil
                        ).height
                        yPosition += descriptionHeight + 5
                    }
                }
            }

        }
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(siteInfo.id ?? fileName)
        do {
            try data.write(to: outputURL)
            print("✅ PDF created at \(outputURL.path)")
            return outputURL
        } catch {
            print("❌ PDF generation failed:", error)
            return nil
        }
    }
}
