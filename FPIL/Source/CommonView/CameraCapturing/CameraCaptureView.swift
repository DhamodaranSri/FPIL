//
//  CameraCaptureView.swift
//  FPIL
//
//  Created by OrganicFarmers on 15/10/25.
//

import Foundation
import SwiftUI
import AVFoundation
/*
struct CameraCaptureView: View {
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var showImagePreview = false
    
    var body: some View {
        VStack {
            if let image = capturedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 50, maxHeight: 50)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                    
                    Button(action: {
                        capturedImage = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
//                    .padding(8)
                }
            } else {
                Button(action: {
                    showCamera = true
                }) {
                    Image(systemName: "camera")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePickerView(image: $capturedImage, isPresented: $showCamera)
        }
    }
}
*/

import SwiftUI
import FirebaseStorage

struct CameraCaptureView: View {
    @State private var showCamera = false
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0.0
    @State private var downloadURL: String?
    @State private var placeHolder = true
    
    var existingPhotoURL: String? // 👈 from Firestore (if already saved)
    var onUploadComplete: ((UIImage) -> Void)?
    var removeUploadedPhoto: (() -> Void)?
    
    var body: some View {
        VStack {
            if let imageURL = downloadURL ?? existingPhotoURL {
                // Fetch directly from Firebase Storage
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().tint(.orange)
                                .frame(maxWidth: 50, maxHeight: 50)
                        case .success(let image):
                            image.resizable().scaledToFit()
                                .onAppear {
                                    placeHolder = false
                                }
                        case .failure:
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .onAppear {
                                    placeHolder = false
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: 50, maxHeight: 50)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 2)
                    )
                    
                    if placeHolder {
                        Image(systemName: "photo.fill")
                            .resizable().scaledToFit()
                            .frame(maxWidth: 50, maxHeight: 50)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                    }
                    
                    Button(action: {
                        downloadURL = nil
                        removeUploadedPhoto?()
                       // onUploadComplete?("") // remove from DB
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
//                    .padding(8)
                }
            } else {
                Button(action: { showCamera = true }) {
                    Image(systemName: "camera")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePickerView(onImagePicked: { image in
                onUploadComplete?(image)
//                uploadToFirebase(image: image)
            }, isPresented: $showCamera)
        }
    }
    
    // MARK: - Upload to Firebase
    private func uploadToFirebase(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let storage = Storage.storage()
        let fileName = "inspection_photos/\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child(fileName)
        
        isUploading = true
        uploadProgress = 0
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = storageRef.putData(imageData, metadata: metadata)
        
        uploadTask.observe(.progress) { snapshot in
            uploadProgress = Double(snapshot.progress?.fractionCompleted ?? 0)
        }
        
        uploadTask.observe(.success) { _ in
            storageRef.downloadURL { url, error in
                isUploading = false
                if let url = url {
                    downloadURL = url.absoluteString
                   // onUploadComplete?(url.absoluteString)
                    print("✅ Uploaded image URL: \(url.absoluteString)")
                } else if let error = error {
                    print("❌ URL error: \(error.localizedDescription)")
                }
            }
        }
        
        uploadTask.observe(.failure) { snapshot in
            isUploading = false
            print("❌ Upload failed: \(snapshot.error?.localizedDescription ?? "")")
        }
    }
}


struct ImagePickerView: UIViewControllerRepresentable {
    var onImagePicked: (UIImage) -> Void
    @Binding var isPresented: Bool
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.onImagePicked(uiImage)
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

