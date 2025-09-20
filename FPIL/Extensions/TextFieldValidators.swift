//
//  TextFieldValidators.swift
//  FPIL
//
//  Created by OrganicFarmers on 20/09/25.
//

import Foundation

class TextFieldValidators: ObservableObject {
    
    @Published var textFieldString: String = ""
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    func validate(inputText: String, for type: ValidationType, maxLength: Int? = nil) -> String {
        guard let maxLength, maxLength >= inputText.count else {
            return String(inputText.prefix(maxLength ?? 0))
        }
        switch type {
        case .onlyNumbers:
            return inputText.filter { $0.isNumber }
        case .alphaNumeric:
            return inputText.filter { $0.isLetter || $0.isNumber }
        case .alphaWithSpaces:
            return inputText.filter { $0.isLetter || $0.isWhitespace }
        case .email:
            // allow letters, numbers, and email-specific symbols
            let allowedChars = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@._-")
            return inputText.filter { char in
                String(char).rangeOfCharacter(from: allowedChars) != nil
            }
        case .all:
            return inputText
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
}


// Enum to represent different validation types
enum ValidationType: String, CaseIterable {
    case onlyNumbers = "numbers"
    case alphaNumeric = "alpha-numeric"
    case alphaWithSpaces = "alpha with spaces"
    case email = "email"
    case all = "all"
}
