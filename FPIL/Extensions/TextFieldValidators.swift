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

struct Validator {
    
    static func isNotEmpty(_ value: String?, fieldName: String) -> String? {
        guard let value = value, !value.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "\(fieldName) is required."
        }
        return nil
    }
    
    static func isValidEmail(_ email: String?) -> String? {
        guard let email = email, !email.isEmpty else {
            return "Email is required."
        }
        
        let emailRegex = #"^\S+@\S+\.\S+$"#
        if NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email) {
            return nil
        } else {
            return "Invalid email address."
        }
    }
    
    static func isValidPhone(_ number: String?, fieldName: String) -> String? {
        guard let number = number, !number.isEmpty else {
            return "\(fieldName) is required."
        }
        
        let regex = #"^[0-9]{10,15}$"#
        if NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: number) {
            return nil
        } else {
            return "\(fieldName) must be 10–15 digits."
        }
    }
    
    static func isValidZip(_ zip: String?) -> String? {
        guard let zip = zip, !zip.isEmpty else {
            return "Zip Code is required."
        }
        
        let regex = #"^[0-9]{5,6}$"#
        if NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: zip) {
            return nil
        } else {
            return "Invalid Zip Code."
        }
    }
}
