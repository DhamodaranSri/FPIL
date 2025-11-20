//
//  InvoicePDFGenerator.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/11/25.
//

import Foundation
import UIKit
import PDFKit

struct InvoicePDFGenerator {

    static func generateInvoicePDF(invoice: InvoiceDetails,
                                   jobModel: JobModel?,
                                   clientModel: ClientModel?,
                                   fileName: String = "Invoice") -> URL? {
        
        guard let clientModel else { return nil }

        let pdfMetaData = [
            kCGPDFContextCreator: "FPIL App",
            kCGPDFContextAuthor: "Organic Farmers",
            kCGPDFContextTitle: "Invoice"
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

            // MARK: - Header
            let titleFont = UIFont.boldSystemFont(ofSize: 20)
            let headerFont = UIFont.boldSystemFont(ofSize: 16)
            let regularFont = UIFont.systemFont(ofSize: 12)
            let smallFont = UIFont.systemFont(ofSize: 10)

            UIColor.orange.set()
            let companyName = "Blaster Communications Inc."
            companyName.draw(at: CGPoint(x: margin, y: yPosition),
                             withAttributes: [.font: titleFont, .foregroundColor: UIColor.orange])
            yPosition += 28

            let subTitle = "Fire Prevention Invoice Logger (FPIL)\n100+ Years of Excellence in Fire Safety"
            subTitle.draw(in: CGRect(x: margin, y: yPosition, width: 400, height: 40),
                          withAttributes: [.font: smallFont])
            yPosition += 40

            // Divider
            drawLine(y: yPosition, pageWidth: pageWidth, margin: margin)
            yPosition += 20
            
            let timeSpent = jobModel?.totalSpentTime.formattedDuration()

            // Invoice details right side
            let invoiceRight = [
                "Invoice #: \(invoice.id ?? "")",
                "Date: \(Date().convertDateAloneFromFullDateFormat())",
                "Time Spent: \(timeSpent ?? "00:00:00")"
            ]
            var rightY = margin
            for line in invoiceRight {
                line.draw(at: CGPoint(x: pageWidth - 200, y: rightY),
                          withAttributes: [.font: smallFont])
                rightY += 14
            }

            // MARK: - Bill To
            let billToTitle = "Bill To:"
            billToTitle.draw(at: CGPoint(x: margin, y: yPosition),
                             withAttributes: [.font: headerFont])
            yPosition += 25

            let billToInfo = "\(clientModel.fullName)\n\(clientModel.address)\n\(clientModel.email)"
            billToInfo.draw(in: CGRect(x: margin, y: yPosition, width: 300, height: 60),
                            withAttributes: [.font: regularFont])
            yPosition += 60

            // MARK: - Service Table
            let tableY = yPosition + 10
            drawTableHeader(y: tableY, pageWidth: pageWidth, margin: margin)
            yPosition = tableY + 30

            if let items = invoice.servicePerformed {
                for item in items {
                    let serviceRect = CGRect(x: margin + 20, y: yPosition, width: 220, height: 20)
                    let qtyRect = CGRect(x: margin + 270, y: yPosition, width: 100, height: 20)
                    let rateRect = CGRect(x: margin + 370, y: yPosition, width: 80, height: 20)
                    let totalRect = CGRect(x: margin + 470, y: yPosition, width: 80, height: 20)
                    
                    item.serviceName?.draw(in: serviceRect, withAttributes: [.font: regularFont])
                    "$\(String(format: "%.2f", item.price ?? 0.00))".draw(in: totalRect, withAttributes: [.font: regularFont])

                    yPosition += 25
                }
            }

            // Divider below items
            drawLine(y: yPosition, pageWidth: pageWidth, margin: margin)
            yPosition += 10

            // MARK: - Building Info Section
            let infoBoxY = yPosition
            let infoBoxRect = CGRect(x: margin, y: infoBoxY, width: pageWidth - 2 * margin, height: 140)
            UIColor(white: 0.95, alpha: 1).setFill()
            UIBezierPath(roundedRect: infoBoxRect, cornerRadius: 6).fill()

            var boxY = infoBoxY + 10
            
            let infoLines: [(String, String?)] = [
                ("Building Type:", invoice.building?.buildingName),
                ("Compliance Score:", jobModel?.lastVist?.first?.totalScore != nil ? "\(jobModel?.lastVist?.first?.totalScore ?? 0)" : "Nil"),
                ("Violations Found:", jobModel?.lastVist?.first?.totalVoilations != nil ? "\(jobModel?.lastVist?.first?.totalVoilations ?? 0)" : "Nil"),
                ("Notes:", clientModel.notes),
                ("Payment Status:", invoice.isPaid ? "Paid" : "Unpaid"),
                ("Paid On:", invoice.paidDate?.convertDateAloneFromFullDateFormat() ?? "Not Paid")
            ]

            for (label, value) in infoLines {
                let labelAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 12)]
                label.draw(at: CGPoint(x: margin + 10, y: boxY), withAttributes: labelAttrs)
                value?.draw(at: CGPoint(x: margin + 150, y: boxY), withAttributes: [.font: regularFont])
                boxY += 20
            }

            yPosition = infoBoxY + 150

            // MARK: - Totals
            let subtotal = invoice.subtotal
            let tax = invoice.taxAmount
            let total = invoice.totalAmountDue

            let rightAlignX = pageWidth - 150
            "Subtotal: $\(String(format: "%.2f", subtotal ?? 0.0))"
                .draw(at: CGPoint(x: rightAlignX, y: yPosition),
                      withAttributes: [.font: regularFont])
            yPosition += 18
            "Tax (\(Int(invoice.taxRate ?? 0.0))%): $\(String(format: "%.2f", tax ?? 0.0))"
                .draw(at: CGPoint(x: rightAlignX, y: yPosition),
                      withAttributes: [.font: regularFont])
            yPosition += 25

            // Total in bold red
            "Total: $\(String(format: "%.2f", total ?? 0.0))"
                .draw(at: CGPoint(x: rightAlignX - 20, y: yPosition),
                      withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16),
                                       .foregroundColor: UIColor.orange])
        }

        // Save PDF
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(invoice.id ?? fileName).pdf")
        do {
            try data.write(to: outputURL)
            print("✅ Invoice PDF generated: \(outputURL.path)")
            return outputURL
        } catch {
            print("❌ PDF generation failed:", error)
            return nil
        }
    }

    // MARK: - Helpers
    private static func drawLine(y: CGFloat, pageWidth: CGFloat, margin: CGFloat) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.lightGray.cgColor)
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: margin, y: y))
        context?.addLine(to: CGPoint(x: pageWidth - margin, y: y))
        context?.strokePath()
    }

    private static func drawTableHeader(y: CGFloat, pageWidth: CGFloat, margin: CGFloat) {
        let headerFont = UIFont.boldSystemFont(ofSize: 13)
        let titles = ["Service", "", "", "Total"]
        let positions: [CGFloat] = [margin + 20, margin + 270, margin + 370, margin + 470]

        for (i, title) in titles.enumerated() {
            title.draw(at: CGPoint(x: positions[i], y: y),
                       withAttributes: [.font: headerFont])
        }

        drawLine(y: y + 20, pageWidth: pageWidth, margin: margin)
    }
}
