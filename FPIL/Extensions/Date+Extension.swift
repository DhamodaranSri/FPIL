//
//  Date+Extension.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/09/25.
//

import Foundation

extension Date {
    func formatedDateAloneAsString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M/yyyy"
        let formatted = formatter.string(from: self)
        
        return formatted
    }
}
