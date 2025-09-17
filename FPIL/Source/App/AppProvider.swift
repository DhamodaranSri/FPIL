//
//  AppProvider.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

import Foundation

final class AppProvider: NSObject {
    static let shared = AppProvider()
    
    var isSignnedIn: Bool = false
    
    private override init() { }
}
