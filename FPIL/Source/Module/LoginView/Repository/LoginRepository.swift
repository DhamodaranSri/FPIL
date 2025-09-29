//
//  LoginRepository.swift
//  FPIL
//
//  Created by OrganicFarmers on 25/09/25.
//

import Foundation

protocol LoginRepository {
    func signIn(email: String, password: String, completion: @escaping (Result<[Profile], any Error>) -> Void)
}
