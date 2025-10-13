//
//  QRGenerator.swift
//  FPIL
//
//  Created by OrganicFarmers on 06/10/25.
//

import Foundation
import CoreImage.CIFilterBuiltins
import UIKit

public class QRGenerator {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    public init() {}
    
    func generateQRCodeTiny(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func generateQRCode(from string: String, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage {
        let filter = CIFilter.qrCodeGenerator()
        let context = CIContext()
        filter.setValue(Data(string.utf8), forKey: "inputMessage")

        guard let outputImage = filter.outputImage else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }

        // Calculate scale factors
        let scaleX = size.width / outputImage.extent.size.width
        let scaleY = size.height / outputImage.extent.size.height
        
        // Apply scaling transform
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
            return UIImage(cgImage: cgImage)
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }

}
