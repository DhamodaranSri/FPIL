//
//  OrganisationRepositoryProtocol.swift
//  FPIL
//
//  Created by OrganicFarmers on 23/09/25.
//

import Foundation

protocol OrganisationRepositoryProtocol {

    func fetchAllOranisationList(completion: @escaping (Result<[OrganisationModel], Error>) -> Void)
    func userSignOut(completion: @escaping (Result<Void, any Error>) -> Void)
    func createNewFirestation(firestation: OrganisationModel, completion: @escaping (Result<Void, any Error>) -> Void)
    func updateFirestation(firestation: OrganisationModel, completion: @escaping (Result<Void, any Error>) -> Void)

}
