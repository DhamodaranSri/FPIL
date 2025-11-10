//
//  InvoiceFormState.swift
//  FPIL
//
//  Created by OrganicFarmers on 26/10/25.
//

import Foundation
import SwiftUI

class InvoiceFormState: ObservableObject {
    @Published var building: Building? = nil

    let buildings: [Building]

    init(
        buildings: [Building]
    ) {
        self.buildings = buildings
    }

    func clearForm() {
    }

    func buildInspector() {
    }
    
    func validateForm() -> [String] {

        var errors: [String] = []

        if building == nil {
            errors.append("Please select a building type")
        }
        return errors
    }
}
