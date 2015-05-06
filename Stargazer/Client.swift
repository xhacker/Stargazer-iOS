//
//  Client.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-05.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import Alamofire
import SwiftyJSON
import KeychainAccess


enum Router: URLRequestConvertible {
    static let baseURLString = "https://api.github.com"
    static var OAuthToken: String? = {
        let keychain = Keychain(service: kKeychainServiceName)
        return keychain[kKeychainGitHubTokenKey]
    }()
    
    case Starred()
    
    var method: Alamofire.Method {
        switch self {
        case .Starred:
            return .GET
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .Starred:
                return ("/user/starred", nil)
            }
        }()
        
        let URL = NSURL(string: Router.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = Router.OAuthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
    }
}


class Client: NSObject {
    static let sharedInstance = Client()
    
    func getStarred(success:(stars: [[String: String]]) -> Void) {
        Alamofire.request(Router.Starred()).responseJSON { (_, _, jsonObject, error) in
            if let jsonObject = jsonObject as? NSArray {
                let json = JSON(jsonObject)
                var stars: [[String: String]] = []
                
                for (index: String, starItem: JSON) in json {
                    stars.append(["name": starItem["name"].stringValue])
                }
                
                success(stars: stars)
            }
        }
    }
}
