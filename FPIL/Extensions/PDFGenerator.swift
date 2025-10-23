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
            drawLine(label: "Inspector:", value: siteInfo.firstName + " " + siteInfo.lastName)
            drawLine(label: "Review Date:", value: Date().convertDateAloneFromFullDateFormat())
            drawLine(label: "Scroe:", value: "\(checklistItems.totalAverageScore ?? 0)%")
            
            yPosition += 20
            
            // MARK: - Checklist Section Header
            
            let remarksHeader = "Review Comments"
            remarksHeader.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: subHeaderFont])
            yPosition += 20
            
            let remarks = siteInfo.reviewNotes ?? "-"
            remarks.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: titleFont])
            yPosition += 30
            
            let checklistHeader = "Inspection Checklist"
            checklistHeader.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: subHeaderFont])
            
            yPosition += 30
            
            // MARK: - Checklist Items
            for (index, item) in checklistItems.questions.enumerated() {
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = margin
                }
                
                let itemTitle = "\(index + 1). \(item.question)"
                itemTitle.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: subTitleFont])
                yPosition += 18
                
                for (subIndex, subItem) in item.answers.enumerated() {
                    let statusLine = "\(subItem.answer)"
                    
                    // --- Fonts ---
                    let uiTitleFont = titleFont // make sure this is a UIFont, not SwiftUI Font
                    
                    let textAttributes: [NSAttributedString.Key: Any] = [.font: uiTitleFont]
                    let textSize = statusLine.size(withAttributes: textAttributes)
                    let lineHeight: CGFloat = 30
                    
                    // --- Checkbox ---
                    let checkboxSize: CGFloat = 16
                    let checkboxRect = CGRect(
                        x: margin + 15,
                        y: yPosition + (lineHeight - checkboxSize) / 2, // vertically centered
                        width: checkboxSize,
                        height: checkboxSize
                    )
                    
                    // Choose checkbox image based on selection
                    let checkboxImageName: String
                    if subItem.isSelected {
                        checkboxImageName = "check_done"  // ✅ Use your actual asset name
                    } else {
                        checkboxImageName = "check"
                    }
                    
                    if let checkboxImage = UIImage(named: checkboxImageName) {
                        checkboxImage.draw(in: checkboxRect)
                    }
                    
                    // --- Text next to checkbox ---
                    let textX = checkboxRect.maxX + 10
                    let textRect = CGRect(
                        x: textX,
                        y: yPosition,
                        width: textSize.width + 10,
                        height: lineHeight
                    )
                    
                    let textColor: UIColor = subItem.isVoilated == true
                    ? .warningBG
                    : (subItem.isSelected ? .pdfAnsweredText : .black)
                    
                    let textDrawAttributes: [NSAttributedString.Key: Any] = [
                        .font: uiTitleFont,
                        .foregroundColor: textColor
                    ]
                    
                    statusLine.draw(in: textRect.insetBy(dx: 5, dy: (lineHeight - uiTitleFont.lineHeight) / 2),
                                    withAttributes: textDrawAttributes)
                    
                    yPosition += lineHeight
                    
                    if let description = subItem.voilationDescription {
                        
                        let singleLine = description
                            .components(separatedBy: .newlines) // split by newlines
                            .filter { !$0.isEmpty }             // remove empty lines
                            .joined(separator: " ")
                        
                        let voilationDesctiption = "Voilations: \(singleLine)"
                        voilationDesctiption.draw(at: CGPoint(x: margin + 20, y: yPosition), withAttributes: [.font: subValueFont])
                        yPosition += 18
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
