//
//  FirebaseService.swift
//  FPIL
//
//  Created by OrganicFarmers on 11/08/25.
//

import Foundation
import FirebaseFirestore

class FirebaseService<T: Codable & Identifiable> where T.ID == String? {
    private let collectionRef: CollectionReference
    
    init(collectionName: String) {
        self.collectionRef = Firestore.firestore().collection(collectionName)
    }
    
    // Create or Update
    
    func siteUpdate(_ item: T, items: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        collectionRef.document(item.id ?? "").updateData(items) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func save(_ item: T, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try collectionRef.document(item.id ?? "").setData(from: item)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Fetch all
    func fetchAll(completion: @escaping (Result<[T], Error>) -> Void) {
        collectionRef.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            do {
                let items = try documents.compactMap { try $0.data(as: T.self) }
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchAllData(completion: @escaping (Result<[T], Error>) -> Void) {
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([])) // no data
                return
            }
            
            do {
                let users = try documents.compactMap { doc -> T? in
                    return try doc.data(as: T.self)
                }
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Fetch by ID
    func fetch(byId id: String, completion: @escaping (Result<T, Error>) -> Void) {
        collectionRef.document(id).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                if let document = document, document.exists {
                    let item = try document.data(as: T.self)
                    completion(.success(item))
                } else {
                    completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Not found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Fetch by any field (single or multiple matches)
    func fetchBy(field: String, value: Any, completion: @escaping (Result<[T], Error>) -> Void) {
        collectionRef
            .whereField(field, isEqualTo: value)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                do {
                    let items = try documents.compactMap { try $0.data(as: T.self) }
                    completion(.success(items))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    // Fetch by any field with Multiple Where (single or multiple matches)
    func fetchByMultipleWhere(conditions: [(field: String, value: Any)], orderBy: String, completion: @escaping (Result<[T], Error>) -> Void) {
        
        var query: Query = collectionRef
        
        for condition in conditions {
            query = query.whereField(condition.field, isEqualTo: condition.value)
        }
        
        if orderBy.isEmpty == false {
            query = query.order(by: orderBy)
        }

        query
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                do {
                    let items = try documents.compactMap { try $0.data(as: T.self) }
                    completion(.success(items))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    // Fetch by any field (single or multiple matches)
    func fetchByContains(field: String, value: Any, orderBy: String, completion: @escaping (Result<[T], Error>) -> Void) {
        collectionRef
            .whereField(field, arrayContains: value)
            .order(by: orderBy)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                do {
                    let items = try documents.compactMap { try $0.data(as: T.self) }
                    completion(.success(items))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    // Search (exact match)
    func search(field: String, isEqualTo value: Any, completion: @escaping (Result<[T], Error>) -> Void) {
        collectionRef
            .whereField(field, isEqualTo: value)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let items = try documents.compactMap { try $0.data(as: T.self) }
                    completion(.success(items))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    // Search (prefix / partial match)
    func searchPrefix(field: String, prefix: String, completion: @escaping (Result<[T], Error>) -> Void) {
        let endString = prefix + "\u{f8ff}" // Firestore prefix trick
        collectionRef
            .order(by: field)
            .start(at: [prefix])
            .end(at: [endString])
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let items = try documents.compactMap { try $0.data(as: T.self) }
                    completion(.success(items))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    // Delete
    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        collectionRef.document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

