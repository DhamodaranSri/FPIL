//
//  InspectorsListRepositoryProtocol.swift
//  FPIL
//
//  Created by OrganicFarmers on 27/09/25.
//

import Foundation

protocol InspectorsListRepositoryProtocol {

    func fetchAllInspectorsList(stationId: String, completion: @escaping (Result<[FireStationInspectorModel], Error>) -> Void)
    func createNewInspector(inspector: FireStationInspectorModel, completion: @escaping (Result<Void, any Error>) -> Void)
    func updateInspector(inspector: FireStationInspectorModel, completion: @escaping (Result<Void, any Error>) -> Void)

}
