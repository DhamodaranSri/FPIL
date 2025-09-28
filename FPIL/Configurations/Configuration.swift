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
    private static var userInfoDetails = "userInfoDetail"
    private static var lastLoginTimeStamp = "lastLoginTimeStamp"
    private static var isDarkMode = "isDarkMode"
    private static var deviceTokenStored = "isStored"
    
    
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
    
    static var lastLoginDate : String? {
        get {
            return (UserDefaults.standard.string(forKey: lastLoginTimeStamp) ?? "")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: lastLoginTimeStamp)
        }
    }
    
    static var isDarkModeBool : Bool? {
        get {
            return UserDefaults.standard.bool(forKey: isDarkMode)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isDarkMode)
        }
    }
    
    static var isDeviceTokenStoredBool : Bool? {
        get {
            return UserDefaults.standard.bool(forKey: deviceTokenStored)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: deviceTokenStored)
        }
    }
   
    static func clearData(){
        UserDefaults.standard.removeObject(forKey: profileInfo)
        UserDefaults.standard.removeObject(forKey: fireStationInfo)
        UserDefaults.standard.removeObject(forKey: userInfoDetails)
        UserDefaults.standard.removeObject(forKey: lastLoginTimeStamp)
        UserDefaults.standard.removeObject(forKey: isDarkMode)
        UserDefaults.standard.removeObject(forKey: deviceTokenStored)
    }
    
    
}
