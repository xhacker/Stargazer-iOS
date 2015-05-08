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
    case URL(String)
    
    var method: Alamofire.Method {
        switch self {
        case .Starred:
            return .GET
        case .URL:
            return .GET
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .Starred:
                return ("/user/starred", nil)
            case .URL(let URL):
                return ("", nil)
            }
        }()
        
        let URL = NSURL(string: Router.baseURLString)!
        let mutableURLRequest: NSMutableURLRequest = {
            switch self {
            case .Starred:
                return NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
            case .URL(let URLString):
                return NSMutableURLRequest(URL: NSURL(string: URLString)!)
            }
        }()
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = Router.OAuthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
    }
}


class Client: NSObject {
    static let sharedInstance = Client()
    
    func getStarred(success: (stars: [[String: AnyObject]]) -> Void) {
        Alamofire.request(Router.Starred()).responseJSON { (request, response, jsonObject, error) in
            self.starPageResponseCallback(request: request, response: response, jsonObject: jsonObject, error: error, success: success)
        }
    }
    
    func starPageResponseCallback(#request: NSURLRequest, response: NSHTTPURLResponse?, jsonObject: AnyObject?, error: NSError?, success: (stars: [[String: AnyObject]]) -> Void) -> Void {
        if let jsonObject = jsonObject as? NSArray {
            let json = JSON(jsonObject)
            var stars: [[String: AnyObject]] = []
            
            for (index: String, starItem: JSON) in json {
                stars.append([
                    "name": starItem["name"].stringValue,
                    "full_name": starItem["full_name"].stringValue,
                    "description": starItem["description"].stringValue,
                    "html_url": starItem["html_url"].stringValue,
                    "language": starItem["language"].stringValue,
                    "forks_count": starItem["language"].intValue,
                    "stargazers_count": starItem["language"].intValue,
                ])
            }
            
            success(stars: stars)
        }
        
        if let response = response, nextURLString = nextURLStringFromResponse(response) {
            Alamofire.request(Router.URL(nextURLString)).responseJSON { (request, response, jsonObject, error) in
                self.starPageResponseCallback(request: request, response: response, jsonObject: jsonObject, error: error, success: success)
            }
        }
    }
}


// Courtesy of OctoKit, translated to Swift
func nextURLStringFromResponse(response: NSHTTPURLResponse) -> String? {
    let header = response.allHeaderFields
    let linksString = header["Link"] as? String
    if let linksString = header["Link"] as? String {
        if count(linksString) < 1 {
            return nil
        }
        
        let relPattern = NSRegularExpression(pattern: "rel=\\\"?([^\\\"]+)\\\"?", options: .CaseInsensitive, error: nil)
        
        let whitespaceAndBracketCharacterSet = NSCharacterSet.whitespaceCharacterSet().mutableCopy() as! NSMutableCharacterSet
        whitespaceAndBracketCharacterSet.addCharactersInString("<>")

        let links = linksString.componentsSeparatedByString(",")
        for link in links {
            let semicolonRange = link.rangeOfString(";")
            if semicolonRange == nil {
                continue
            }
            
            let URLString = link.substringToIndex(semicolonRange!.startIndex).stringByTrimmingCharactersInSet(whitespaceAndBracketCharacterSet)
            if count(URLString) == 0 {
                continue
            }

            let result = relPattern!.firstMatchInString(link, options: nil, range: NSMakeRange(0, count(link)))
            if result == nil {
                continue
            }

            let type = (link as NSString).substringWithRange(result!.rangeAtIndex(1))
            if type != "next" {
                continue
            }
            
            return URLString
        }
    }
    
    return nil
}
