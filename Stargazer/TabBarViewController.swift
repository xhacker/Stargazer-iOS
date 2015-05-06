//
//  TabBarViewController.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-04.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit
import KeychainAccess

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let keychain = Keychain(service: kKeychainServiceName)
        if keychain[kKeychainGitHubTokenKey] == nil {
            performSegueWithIdentifier("signIn", sender: self)
        }
    }

}
