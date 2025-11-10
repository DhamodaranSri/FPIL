//
//  PDFViewer.swift
//  FPIL
//
//  Created by OrganicFarmers on 24/10/25.
//

import SwiftUI
import PDFKit

//struct PDFViewer: View {
//    @Binding var url: URL?
//    var onClick: (() -> ())? = nil
//    
//    var body: some View {
//        
//        ZStack(alignment: .top) {
//            VStack(spacing: 40) {
//                CustomNavBar(
//                    title: "Plan Review Report",
//                    showBackButton: true,
//                    actions: [],
//                    backgroundColor: .applicationBGcolor,
//                    titleColor: .appPrimary,
//                    backAction: {
//                        onClick?()
//                    }
//                )
//                if let url {
//                    PDFKitView(url: url)
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .navigationBarBackButtonHidden()
//            .background(.applicationBGcolor)
//        }.frame(maxWidth: .infinity, maxHeight: .infinity)
//        
////        PDFKitView(url: url)
////            .navigationTitle("Fire Safety Report")
////            .navigationBarTitleDisplayMode(.inline)
//    }
//}

//struct PDFKitView: UIViewRepresentable {
//    let url: URL
//    
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        pdfView.autoScales = true
//        pdfView.document = PDFDocument(url: url)
//        return pdfView
//    }
//    
//    func updateUIView(_ uiView: PDFView, context: Context) {}
//}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true

        DispatchQueue.global(qos: .userInitiated).async {
            if let document = PDFDocument(url: url) {
                DispatchQueue.main.async {
                    pdfView.document = document
                    isLoading = false // ✅ Hide loader once loaded
                }
            } else {
                DispatchQueue.main.async {
                    isLoading = false // failed case too
                }
            }
        }
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

struct PDFViewer: View {
    @Binding var url: URL?
    @State private var isLoading = true
    var onClick: (() -> ())? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                CustomNavBar(
                    title: "Plan Review Report",
                    showBackButton: true,
                    actions: [],
                    backgroundColor: .applicationBGcolor,
                    titleColor: .appPrimary,
                    backAction: { onClick?() }
                )

                if let url {
                    PDFKitView(url: url, isLoading: $isLoading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.applicationBGcolor)
            .navigationBarBackButtonHidden()

            if isLoading {
                // ✅ Loader Overlay
                ZStack {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView("Loading PDF...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
        }
    }
}
