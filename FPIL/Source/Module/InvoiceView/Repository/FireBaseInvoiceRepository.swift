//
//  FireBaseInvoiceRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/11/25.
//

import Foundation

final class FireBaseInvoiceRepository: InvoiceRepositoryProtocol {
    
    private let fireService: FirebaseService<ClientModel>
    
    init() {
        fireService = FirebaseService<ClientModel>(collectionName: "ClientList")
    }
    
    func createInvoice(clientModel: ClientModel, updatedItems: [String: Any], completion: @escaping (Result<Void, any Error>) -> Void) {
        if NetworkMonitor.shared.isConnected {
            fireService.siteUpdate(clientModel, items: updatedItems) { result in
                completion(result)
            }
        } else {
            completion(.failure(NSError(domain: "Internet Connection Error", code: 92001)))
        }
    }
}
