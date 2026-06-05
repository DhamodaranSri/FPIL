//
//  DocumentPicker.swift
//  FPIL
//
//  Created by OrganicFarmers on 19/05/26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    
    var onPick: (Result<URL, Error>) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        
        let supportedTypes: [UTType] = [
            .pdf,
            .image,
            UTType(filenameExtension: "docx")!,
            UTType(filenameExtension: "doc")!
        ]
        
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: supportedTypes
        )
        
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(
        _ uiViewController: UIDocumentPickerViewController,
        context: Context
    ) {
        
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(
            _ controller: UIDocumentPickerViewController,
            didPickDocumentsAt urls: [URL]
        ) {
            
            guard let url = urls.first else {
                return
            }
            
            // IMPORTANT: Required for real devices
            let accessGranted = url.startAccessingSecurityScopedResource()
            
            guard accessGranted else {
                let error = NSError(
                    domain: "DocumentPicker",
                    code: 403,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to access selected file"
                    ]
                )
                
                parent.onPick(.failure(error))
                return
            }
            
            do {
                
                // Optional validation read
                let data = try Data(contentsOf: url)
                print("Selected file size:", data.count)
                print("Selected URL:", url)
                
                parent.onPick(.success(url))
                
            } catch {
                
                parent.onPick(.failure(error))
            }
            
            // Stop access after usage completes
            url.stopAccessingSecurityScopedResource()
        }
        
        func documentPickerWasCancelled(
            _ controller: UIDocumentPickerViewController
        ) {
            
            let error = NSError(
                domain: "DocumentPicker",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: "User cancelled document picker"
                ]
            )
            
            parent.onPick(.failure(error))
        }
    }
}
