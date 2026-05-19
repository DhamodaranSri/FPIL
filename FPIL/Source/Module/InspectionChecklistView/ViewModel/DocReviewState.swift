//
//  DocReviewState.swift
//  FPIL
//
//  Created by OrganicFarmers on 18/05/26.
//

import Foundation

class DocReviewState: ObservableObject {
    
    @Published var client: ClientModel? = nil
    
    let clients: [ClientModel]
    
    init(
        clients: [ClientModel] = [],
        selectedClient: ClientModel? = nil
    ) {
        self.clients = clients
        self.client = selectedClient
    }
}
