//
//  PhoneCallManager.swift
//  FPIL
//
//  Created by OrganicFarmers on 17/11/25.
//

import Foundation
import SwiftUI

class PhoneCallManager: ObservableObject {
    static let shared = PhoneCallManager()   // Global Singleton

    private init() {}

    func call(_ number: String, openURL: OpenURLAction) {
        let cleaned = number.filter { "+0123456789".contains($0) }

        if let url = URL(string: "tel://\(cleaned)") {
            openURL(url)
        }
    }
    
    func sendEmail(to email: String, subject: String = "", body: String = "", openURL: OpenURLAction) {
        let escapedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let escapedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlString = "mailto:\(email)?subject=\(escapedSubject)&body=\(escapedBody)"

        if let mailURL = URL(string: urlString) {
            openURL(mailURL)
        }
    }
}

struct PhoneCallModifier: ViewModifier {
    @Environment(\.openURL) private var openURL
    let phone: String

    func body(content: Content) -> some View {
        content.onTapGesture {
            let cleaned = phone.filter { "+0123456789".contains($0) }
            if let url = URL(string: "tel://\(cleaned)") {
                openURL(url)
            }
        }
    }
}

extension View {
    func phoneCall(_ number: String) -> some View {
        self.modifier(PhoneCallModifier(phone: number))
    }
}

// MARK: - Phone Number Formatting Extensions
extension String {
    /// Formats a phone number for display as `(XXX) XXX-XXXX`.
    func formatPhoneNumber() -> String {
        let digits = self.filter { $0.isNumber }
        if digits.count == 10 {
            let area = digits.prefix(3)
            let mid = digits.dropFirst(3).prefix(3)
            let last = digits.suffix(4)
            return "(\(area)) \(mid)-\(last)"
        } else if digits.count == 11, digits.first == "1" {
            let rest = digits.dropFirst()
            let area = rest.prefix(3)
            let mid = rest.dropFirst(3).prefix(3)
            let last = rest.suffix(4)
            return "+1 (\(area)) \(mid)-\(last)"
        }
        return self
    }

    /// Strips non-digit characters to return normal numbers for editing/storage.
    func rawPhoneNumber() -> String {
        return self.filter { $0.isNumber }
    }
}

extension Optional where Wrapped == String {
    /// Formats an optional phone number for display as `(XXX) XXX-XXXX`.
    func formatPhoneNumber() -> String {
        guard let self = self, !self.isEmpty else { return "" }
        return self.formatPhoneNumber()
    }

    /// Strips non-digit characters from an optional string.
    func rawPhoneNumber() -> String {
        guard let self = self else { return "" }
        return self.rawPhoneNumber()
    }
}
