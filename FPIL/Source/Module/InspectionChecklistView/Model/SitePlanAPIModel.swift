//
//  SitePlanAPIModel.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/05/26.
//

import Foundation

struct SitePlanAPIResponseModel: Codable {
    let error: String?
    let request_id: String?
    let status: String?
    let status_url: String?
}

struct SitePlanAPIRequestModel: Codable, dictify {
    let request_id: String?
    let userId: String?
    let pdf_url: String?
}
