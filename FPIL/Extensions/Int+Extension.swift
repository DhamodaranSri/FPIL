//
//  Int+Extension.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/09/25.
//

import Foundation

extension Int {
    func formattedDuration() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let remainingSeconds = self % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }
}
