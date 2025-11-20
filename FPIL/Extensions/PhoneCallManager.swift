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
        let cleaned = number
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")

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
            let cleaned = phone.replacingOccurrences(of: " ", with: "")
                               .replacingOccurrences(of: "-", with: "")
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
