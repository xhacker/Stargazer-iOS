//
//  AppDelegate.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-04-30.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit
import Alamofire
import KeychainAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        if let queryItem = urlComponents?.queryItems?.first as? NSURLQueryItem, code = queryItem.value {
            let URL = NSURL(string: "https://github.com/login/oauth/access_token")!
            let URLRequest = NSMutableURLRequest(URL: URL)
            URLRequest.HTTPMethod = "POST"
            
            let parameters = ["client_id": kGitHubOAuthClientID, "client_secret": kGitHubOAuthClientSecret, "code": code]
            var JSONSerializationError: NSError? = nil
            URLRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &JSONSerializationError)
            URLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            URLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            
            Alamofire.request(URLRequest).responseJSON { (_, _, JSON, error) in
                if let JSON = JSON as? [String: String] {
                    println(JSON["access_token"])
                    
                    let keychain = Keychain(service: kKeychainServiceName)
                    keychain[kKeychainGitHubTokenKey] = JSON["access_token"]
                    Router.OAuthToken = JSON["access_token"]
                }
            }
        }
        return true
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

