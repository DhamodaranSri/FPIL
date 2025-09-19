//
//  Configuration.swift
//  FPIL
//
//  Created by OrganicFarmers on 18/09/25.
//
import Foundation
import SwiftUI

enum ApplicationFont {
    case regular(size: CGFloat)
    case bold(size: CGFloat)

    var value: Font {
        switch self {
        case .regular(let size):
            return .custom("SegoeUIThis", size: size)
        case .bold(let size):
            return .custom("SegoeUIThis-Bold", size: size)
        }
    }
}
