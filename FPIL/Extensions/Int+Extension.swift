//
//  Int+Extension.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/09/25.
//

import Foundation

extension TimeInterval {
    func formattedDuration() -> String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
