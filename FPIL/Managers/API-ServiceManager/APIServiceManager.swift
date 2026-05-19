//
//  APIServiceManager.swift
//  FPIL
//
//  Created by OrganicFarmers on 01/05/26.
//

import Foundation
import UIKit

class APIServiceManager
{
    private let session = URLSession.shared
    let boundary = "Boundary-\(UUID().uuidString)"
    static let shared = APIServiceManager()
    
    func request(servicename : APIEndpoints,completion:@escaping(Data?,String?,AnyObject?,NSError?,HTTPStatusCode?)->Void)
    {
        DispatchQueue.main.async {
            if NetworkMonitor.shared.isConnected == true {
                let task = self.session.dataTask(with: servicename.urlRequest, completionHandler: {data, response, error -> Void in
                    if error == nil
                    {
                        let result : AnyObject?
                        do
                        {
                            result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                            let jsonString = String(data: data!, encoding: String.Encoding.utf8)
                            
                            
                            completion(data,jsonString!,result,nil,(response as! HTTPURLResponse).status)
                        }
                        catch let catchError as NSError
                        {
                            let jsonString = String(data: data!, encoding: String.Encoding.utf8)
                            completion(nil,jsonString,nil,catchError,(response as! HTTPURLResponse).status)
                        }
                    }
                    else
                    {
                        completion(nil,nil,nil,error as NSError?,(response as? HTTPURLResponse)?.status)
                    }
                })
                task.resume()
            } else {
                completion(nil,nil,nil,NSError(domain: "Internet Connection Error", code: 92001),HTTPStatusCode(rawValue: 92001))
            }
        }
    }
    
    func newparser<ModelClass:Codable>(modelToParse:ModelClass.Type,result:Data)->ModelClass?{
        do {
            let jsonDecoder = JSONDecoder()
            let authResponse = try jsonDecoder.decode(modelToParse, from: result)
            return authResponse
        } catch let error {
            
            print(error.localizedDescription)
            return nil
        }
    }
    
}
//MARK:- APIManager Protocol
enum APIEndpoints
{
    case uploadSiteApproval(model: SitePlanAPIRequestModel)
    case getStatus(reportId: String)
}
extension APIEndpoints:APIEndpoint
{
    
    var body: Data {
        switch self {
        case .uploadSiteApproval(model: let sitePdfModel):
            return self.createBodyforJson(parameters: sitePdfModel.todict()! as NSDictionary)!
        case .getStatus(reportId: _):
            return Data()
        }
    }
    
    
    var contentType: String {
        return ContentType.json.rawValue
    }
    
    var urlRequest: URLRequest {
        let urlRequest = NSMutableURLRequest(url: URL(string: fullURL)!)
        switch self {
        case .uploadSiteApproval(model: _):
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = body
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        case .getStatus(reportId: _):
            urlRequest.httpMethod = "GET"
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        
        return urlRequest as URLRequest
    }
    
    var baseURL: String {
        "https://fpil-app-61636061492.us-central1.run.app/"
    }
    
    var path: String {
        switch self {
        case .uploadSiteApproval(model: _):
            return "analyze"
        case .getStatus(reportId: let statusId):
            return"status/\(statusId)"
        }
    }
    
    var fullURL: String {
        return baseURL+path
    }
    
}
public protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var fullURL: String { get }
    var urlRequest : URLRequest{get}
    var contentType : String{get}
    var body:Data{get}
    
}
//MARK:- Enums for APIManager
enum ContentType:String
{
    case formxurlEncode = "application/x-www-form-urlencoded"
    case multipartFormadata = "multipart/form-data; boundary="
    case json = "application/json"
    case jsonPatch = "application/json-patch+json"
}



//MARK:-Extensions For APIManager
public extension UIViewController
{
    func newparser<ModelClass:Codable>(modelToParse:ModelClass.Type,result:Data)->ModelClass?{
        do {
            let jsonDecoder = JSONDecoder()
            let authResponse = try jsonDecoder.decode(modelToParse, from: result)
            return authResponse
        } catch let error {
            
            print(error.localizedDescription)
            return nil
        }
    }
}

extension APIEndpoints
{
    private func createBodyforJson(parameters:NSDictionary)->Data?
    {
        do
        {
            return   try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.fragmentsAllowed)
        }
        catch _ as NSError
        {
            return nil
        }
    }
}

protocol dictify {
    
    func todict()->[String: Any]?
}

extension dictify where Self: Codable {
    
    func todict()->[String: Any]?{
        
        do {
            return try JSONSerialization.jsonObject(with: try JSONEncoder().encode(self), options: []) as? [String: Any]
        } catch {
            return nil
        }
    }
    
}

public extension Array {
    subscript (safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }
}

/*
 {
     "request_id": "TEST-REQ-006",
     "status": "request_received",
     "status_url": "/status/TEST-REQ-006"
 }
 
 
 {
     "error": "request_id 'TEST-REQ-006' already exists",
     "request_id": "TEST-REQ-006",
     "status": "error"
 }
 */
