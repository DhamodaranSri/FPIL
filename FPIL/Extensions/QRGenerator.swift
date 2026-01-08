//
//  QRGenerator.swift
//  FPIL
//
//  Created by OrganicFarmers on 06/10/25.
//

import Foundation
import CoreImage.CIFilterBuiltins
import UIKit

//public class QRGenerator {
//    let context = CIContext()
//    let filter = CIFilter.qrCodeGenerator()
//    
//    public init() {}
//    
//    func generateQRCodeTiny(from string: String) -> UIImage {
//        filter.message = Data(string.utf8)
//
//        if let outputImage = filter.outputImage {
//            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
//                return UIImage(cgImage: cgImage)
//            }
//        }
//
//        return UIImage(systemName: "xmark.circle") ?? UIImage()
//    }
//    
//    func generateQRCode(from string: String, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage {
//        let filter = CIFilter.qrCodeGenerator()
//        let context = CIContext()
//        filter.setValue(Data(string.utf8), forKey: "inputMessage")
//
//        guard let outputImage = filter.outputImage else {
//            return UIImage(systemName: "xmark.circle") ?? UIImage()
//        }
//
//        // Calculate scale factors
//        let scaleX = size.width / outputImage.extent.size.width
//        let scaleY = size.height / outputImage.extent.size.height
//        
//        // Apply scaling transform
//        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
//
//        if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
//            return UIImage(cgImage: cgImage)
//        }
//
//        return UIImage(systemName: "xmark.circle") ?? UIImage()
//    }
//
//}

public final class QRGenerator {

    private let context = CIContext()

    public init() {}

    // MARK: - Basic QR (Tiny)
    public func generateQRCodeTiny(from string: String) -> UIImage {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        guard
            let outputImage = filter.outputImage,
            let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }

        return UIImage(cgImage: cgImage)
    }

    // MARK: - Scaled QR
    public func generateQRCode(
        from string: String,
        size: CGSize = CGSize(width: 300, height: 300)
    ) -> UIImage {

        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        guard let outputImage = filter.outputImage else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }

        let scaleX = size.width / outputImage.extent.size.width
        let scaleY = size.height / outputImage.extent.size.height

        let transformedImage = outputImage.transformed(
            by: CGAffineTransform(scaleX: scaleX, y: scaleY)
        )

        guard let cgImage = context.createCGImage(
            transformedImage,
            from: transformedImage.extent
        ) else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }

        return UIImage(cgImage: cgImage)
    }

    // MARK: - 🖨 Printable QR with Site ID
    public func generatePrintableQR(
        from string: String,
        qrSize: CGFloat = 300
    ) -> UIImage {

        let qrImage = generateQRCode(
            from: string,
            size: CGSize(width: qrSize, height: qrSize)
        )

        let padding: CGFloat = 24
        let textHeight: CGFloat = 40

        let canvasSize = CGSize(
            width: qrSize + padding * 2,
            height: qrSize + textHeight + padding * 2
        )

        let renderer = UIGraphicsImageRenderer(size: canvasSize)

        return renderer.image { _ in
            // Background
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: canvasSize))

            // QR
            let qrRect = CGRect(
                x: padding,
                y: padding,
                width: qrSize,
                height: qrSize
            )
            qrImage.draw(in: qrRect)

            // Site ID
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraph
            ]

            let textRect = CGRect(
                x: padding,
                y: qrRect.maxY + 8,
                width: qrSize,
                height: textHeight
            )

            ("Site ID: \(string)").draw(
                in: textRect,
                withAttributes: attributes
            )
        }
    }
}
