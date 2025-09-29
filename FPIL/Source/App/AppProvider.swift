//
//  AppProvider.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import Foundation

final class AppProvider: ObservableObject {
    static let shared = AppProvider()
    
    var profile: Profile? = nil
    
    private init() { }
}
