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
    
    func convertDateAloneFromFullDateFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}

extension Date {
    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
}
