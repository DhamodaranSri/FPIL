//
//  InvoiceRepositoryProtocol.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/11/25.
//

import Foundation

protocol InvoiceRepositoryProtocol {

    //func fetchAllInvoiceList(InspectionId: String, completion: @escaping (Result<JobModel, Error>) -> Void)
    func createInvoice(clientModel: ClientModel, updatedItems: [String: Any], completion: @escaping (Result<Void, any Error>) -> Void)

}
