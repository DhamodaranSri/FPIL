//
//  ClientListRepositoryProtocol.swift
//  FPIL
//
//  Created by OrganicFarmers on 24/10/25.
//

import Foundation

protocol ClientListRepositoryProtocol {

    func fetchAllClientList(stationId: String, completion: @escaping (Result<[ClientModel], Error>) -> Void)
    func createNewClient(client: ClientModel, completion: @escaping (Result<Void, any Error>) -> Void)
    func updateClient(client: ClientModel, completion: @escaping (Result<Void, any Error>) -> Void)

}
