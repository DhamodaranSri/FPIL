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

class UserDefaultsStore {

    private static var profileInfo = "profileInfo"
    private static var fireStationInfo = "fireStationInfo"
    private static var allBuildings = "allBuildings"
    private static var allFrequency = "allFrequency"
    private static var allInspectors = "allInspectors"
    
    
    static var profileDetail :Profile? {
        get {
            let decoder = JSONDecoder()
            if let user = UserDefaults.standard.data(forKey: profileInfo)
            {
                let userDetail = try? decoder.decode(Profile.self, from: user)
                return userDetail
            }else{
                return nil
            }
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: profileInfo)
            }
        }
    }

    static var fireStationDetail :OrganisationModel? {
        get {
            let decoder = JSONDecoder()
            if let user = UserDefaults.standard.data(forKey: fireStationInfo)
            {
                let userDetail = try? decoder.decode(OrganisationModel.self, from: user)
                return userDetail
            }else{
                return nil
            }
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: fireStationInfo)
            }
        }
    }
    
    static var buildings :[Building]? {
        get {
            let decoder = JSONDecoder()
            if let user = UserDefaults.standard.data(forKey: allBuildings)
            {
                let userDetail = try? decoder.decode([Building].self, from: user)
                return userDetail
            }else{
                return nil
            }
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: allBuildings)
            }
        }
    }

    static var inspectorsList :[FireStationInspectorModel]? {
        get {
            let decoder = JSONDecoder()
            if let user = UserDefaults.standard.data(forKey: allInspectors)
            {
                let userDetail = try? decoder.decode([FireStationInspectorModel].self, from: user)
                return userDetail
            }else{
                return nil
            }
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: allInspectors)
            }
        }
    }

    static var frequency :[InspectionFrequency]? {
        get {
            let decoder = JSONDecoder()
            if let user = UserDefaults.standard.data(forKey: allFrequency)
            {
                let userDetail = try? decoder.decode([InspectionFrequency].self, from: user)
                return userDetail
            }else{
                return nil
            }
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: allFrequency)
            }
        }
    }
   
    static func clearData(){
        UserDefaults.standard.removeObject(forKey: profileInfo)
        UserDefaults.standard.removeObject(forKey: fireStationInfo)
        UserDefaults.standard.removeObject(forKey: allBuildings)
        UserDefaults.standard.removeObject(forKey: allFrequency)
        UserDefaults.standard.removeObject(forKey: allInspectors)
    }
    
    
}
