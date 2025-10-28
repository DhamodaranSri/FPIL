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

    var uiValue: UIFont {
        switch self {
        case .regular(let size):
            return UIFont(name: "SegoeUIThis", size: size) ?? .systemFont(ofSize: size)
        case .bold(let size):
            return UIFont(name: "SegoeUIThis-Bold", size: size) ?? .boldSystemFont(ofSize: size)
        }
    }
}

class UserDefaultsStore {

    private static var profileInfo = "profileInfo"
    private static var fireStationInfo = "fireStationInfo"
    private static var allBuildings = "allBuildings"
    private static var allFrequency = "allFrequency"
    private static var allInspectors = "allInspectors"
    private static var jobStartedDateTime = "jobStartedDateTime"
    private static var startedJob = "startedJob"
    private static var allClientType = "clientType"
    private static var allClientList = "clientList"
    
    static var jobStartedDate :Date? {
        get {
            let decoder = JSONDecoder()
            if let user = UserDefaults.standard.data(forKey: jobStartedDateTime)
            {
                let userDetail = try? decoder.decode(Date.self, from: user)
                return userDetail
            }else{
                return nil
            }
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: jobStartedDateTime)
            }
        }
    }
    
    static var startedJobDetail :JobModel? {
        get {
            let decoder = JSONDecoder()
            if let user = UserDefaults.standard.data(forKey: startedJob)
            {
                let userDetail = try? decoder.decode(JobModel.self, from: user)
                return userDetail
            }else{
                return nil
            }
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: startedJob)
            }
        }
    }

    static var allClientDetail :[ClientModel]? {
        get {
            let decoder = JSONDecoder()
            if let user = UserDefaults.standard.data(forKey: allClientList)
            {
                let userDetail = try? decoder.decode([ClientModel].self, from: user)
                return userDetail
            }else{
                return nil
            }
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: allClientList)
            }
        }
    }

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

    static var clientType :[ClientType]? {
        get {
            let decoder = JSONDecoder()
            if let user = UserDefaults.standard.data(forKey: allClientType)
            {
                let userDetail = try? decoder.decode([ClientType].self, from: user)
                return userDetail
            }else{
                return nil
            }
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: allClientType)
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
        UserDefaults.standard.removeObject(forKey: jobStartedDateTime)
        UserDefaults.standard.removeObject(forKey: startedJob)
        UserDefaults.standard.removeObject(forKey: allClientType)
        UserDefaults.standard.removeObject(forKey: allClientList)
    }
    
    
}
