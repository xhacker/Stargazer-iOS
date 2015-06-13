//
//  Client.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-05.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import Alamofire
import CoreData
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
        let (path, parameters): (String, [String: AnyObject]?) = {
            switch self {
            case .Starred:
                return ("/user/starred", nil)
            case .URL:
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
    var fetching = false
    var stars: [[String: AnyObject]] = []
    var currentPage = 0
    var numPages: Int?
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    func fetchStars(progressCallback: (progress: Float?) -> Void) {
        if fetching {
            return
        }
        fetching = true
        stars = []
        currentPage = 0
        
        Alamofire.request(Router.Starred()).responseJSON { (request, response, jsonObject, error) in
            if let response = response,
                lastURLString = linkURLStringFromResponse(response, rel: "last"),
                urlComponents = NSURLComponents(URL: NSURL(string: lastURLString)!, resolvingAgainstBaseURL: false),
                queryItem = urlComponents.queryItems?.first,
                lastPage = queryItem.value {
                self.numPages = Int(lastPage)
            }
            
            self.starPageResponseCallback(request: request, response: response, jsonObject: jsonObject, error: error, progressCallback: progressCallback)
        }
    }
    
    func starPageResponseCallback(request request: NSURLRequest?, response: NSHTTPURLResponse?, jsonObject: AnyObject?, error: NSError?, progressCallback: (progress: Float?) -> Void) -> Void {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            if let jsonObject = jsonObject as? NSArray {
                let json = JSON(jsonObject)
                
                for (_, starItem): (String, JSON) in json {
                    self.stars.append([
                        "id": starItem["id"].intValue,
                        "name": starItem["name"].stringValue,
                        "full_name": starItem["full_name"].stringValue,
                        "description": starItem["description"].stringValue,
                        "html_url": starItem["html_url"].stringValue,
                        "language": starItem["language"].stringValue,
                        "forks_count": starItem["forks_count"].intValue,
                        "stargazers_count": starItem["stargazers_count"].intValue,
                    ])
                }
                
                self.currentPage += 1
                if let numPages = self.numPages {
                    progressCallback(progress: Float(self.currentPage) / Float(numPages))
                }
                else {
                    progressCallback(progress: nil)
                }
            }
            
            if let response = response, nextURLString = linkURLStringFromResponse(response, rel: "next") {
                print("Requesting next page (\(self.currentPage + 1))")
                Alamofire.request(Router.URL(nextURLString)).responseJSON { (request, response, jsonObject, error) in
                    self.starPageResponseCallback(request: request, response: response, jsonObject: jsonObject, error: error, progressCallback: progressCallback)
                }
            }
            else {
                // last page
                print("Last page")
                
                self.saveStars()
                
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kUserDefaultsFetchedKey)
                progressCallback(progress: 1.0)
                self.fetching = false
            }
        }
    }
    
    private func saveStars() {
        var downloadedSet = Set<Int>()
        for star in stars {
            downloadedSet.insert(star["id"] as! Int)
        }
        
        var currentSet = Set<Int>()
        let fetchRequest = NSFetchRequest(entityName: "Repo")
        if let fetchResults = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [Repo] {
            for repo in fetchResults {
                currentSet.insert(repo.id.integerValue)
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            // delete removed stars
            let removedSet = currentSet.subtract(downloadedSet)
            print("Deleting removed stars: \(removedSet)")
            for id in removedSet {
                let request = NSFetchRequest(entityName: "Repo")
                request.predicate = NSPredicate(format: "id == %i", id)
                if let results = try! self.managedObjectContext.executeFetchRequest(request) as? [Repo] {
                    self.managedObjectContext.deleteObject(results[0])
                }
            }
            
            // save new stars
            for star in self.stars {
                if !currentSet.contains(star["id"] as! Int) {
                    let name = star["name"] as! String
                    print("Saving new star: \(name)")
                    Repo.createFromDictionary(star, inContext: self.managedObjectContext)
                }
            }
        }
    }
}


// Courtesy of OctoKit, translated to Swift
func linkURLStringFromResponse(response: NSHTTPURLResponse, rel: String) -> String? {
    let header = response.allHeaderFields
    if let linksString = header["Link"] as? String {
        if linksString.characters.count < 1 {
            return nil
        }
        
        let relPattern = try! NSRegularExpression(pattern: "rel=\\\"?([^\\\"]+)\\\"?", options: .CaseInsensitive)
        
        let whitespaceAndBracketCharacterSet = NSCharacterSet.whitespaceCharacterSet().mutableCopy() as! NSMutableCharacterSet
        whitespaceAndBracketCharacterSet.addCharactersInString("<>")

        let links = linksString.componentsSeparatedByString(",")
        for link in links {
            let semicolonRange = link.rangeOfString(";")
            if semicolonRange == nil {
                continue
            }
            
            let URLString = link.substringToIndex(semicolonRange!.startIndex).stringByTrimmingCharactersInSet(whitespaceAndBracketCharacterSet)
            if URLString.characters.count == 0 {
                continue
            }

            let result = relPattern.firstMatchInString(link, options: [], range: NSMakeRange(0, link.characters.count))
            if result == nil {
                continue
            }

            let type = (link as NSString).substringWithRange(result!.rangeAtIndex(1))
            if type != rel {
                continue
            }
            
            return URLString
        }
    }
    
    return nil
}
