//
//  FirebaseFileManager.swift
//  FPIL
//
//  Created by OrganicFarmers on 06/10/25.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit

final class FirebaseFileManager {
    
    static let shared = FirebaseFileManager()
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Upload Image
    func uploadImage(_ image: UIImage,
                     folder: String = "images",
                     fileName: String? = nil,
                     saveToFirestore: Bool = false,
                     completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Invalid image data", code: -1)))
            return
        }
        
        let fileName = (fileName ?? UUID().uuidString) + ".jpg"
        let ref = storage.reference().child("\(folder)/\(fileName)")
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url?.absoluteString else {
                    completion(.failure(NSError(domain: "Missing URL", code: -2)))
                    return
                }
                
                if saveToFirestore {
                    self.saveFileMetadata(fileName: fileName,
                                          fileURL: downloadURL,
                                          fileType: "image/jpeg",
                                          folder: folder)
                }
                completion(.success(downloadURL))
            }
        }
    }
    
    // MARK: - Upload Generic File (PDF, DOCX, etc.)
    func uploadFile(at fileURL: URL,
                    folder: String = "files",
                    saveToFirestore: Bool = true,
                    completion: @escaping (Result<String, Error>) -> Void) {
        
        let fileName = fileURL.lastPathComponent
        let ref = storage.reference().child("\(folder)/\(fileName)")
        
        do {
            let fileData = try Data(contentsOf: fileURL)
            ref.putData(fileData, metadata: nil) { _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                ref.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let downloadURL = url?.absoluteString else {
                        completion(.failure(NSError(domain: "Missing URL", code: -2)))
                        return
                    }
                    
                    if saveToFirestore {
                        self.saveFileMetadata(fileName: fileName,
                                              fileURL: downloadURL,
                                              fileType: fileURL.pathExtension,
                                              folder: folder)
                    }
                    completion(.success(downloadURL))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Save File Metadata to Firestore
    private func saveFileMetadata(fileName: String,
                                  fileURL: String,
                                  fileType: String,
                                  folder: String) {
        
        let document: [String: Any] = [
            "fileName": fileName,
            "fileURL": fileURL,
            "fileType": fileType,
            "folder": folder,
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection("uploads").addDocument(data: document) { error in
            if let error = error {
                print("Firestore save failed: \(error.localizedDescription)")
            } else {
                print("✅ File metadata saved successfully.")
            }
        }
    }
    
    // MARK: - Fetch Image from URL
    func fetchImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    // MARK: - Download File (Generic)
    func downloadFile(from urlString: String,
                      to localURL: URL,
                      completion: @escaping (Result<URL, Error>) -> Void) {
        
        let storageRef = Storage.storage().reference(forURL: urlString)
        
        let task = storageRef.write(toFile: localURL) { url, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let url = url else {
                completion(.failure(NSError(domain: "No local URL", code: -3)))
                return
            }
            completion(.success(url))
        }
        
        task.observe(.progress) { snapshot in
            let percent = 100.0 * Double(snapshot.progress?.completedUnitCount ?? 0) /
                          Double(snapshot.progress?.totalUnitCount ?? 1)
            print("Download progress: \(percent)%")
        }
    }
}
