//
//  DocReviewState.swift
//  FPIL
//
//  Created by OrganicFarmers on 18/05/26.
//

import Foundation
@MainActor
class DocReviewState: ObservableObject {
    
    @Published var client: ClientModel? = nil
    
    let clients: [ClientModel]
    
    let buildingTypes: [String]
    
    @Published var buildingType: String? = nil
    
    init(
        clients: [ClientModel] = [],
        selectedClient: ClientModel? = nil,
        buildingTypes: [String] = [],
        buildingType: String? = nil
    ) {
        self.clients = clients
        self.client = selectedClient
        self.buildingTypes = buildingTypes
        self.buildingType = buildingType
    }
}
