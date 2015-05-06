//
//  SignInViewController.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-05.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signInPressed(sender: AnyObject) {
        let URLString = "https://github.com/login/oauth/authorize?client_id=\(kGitHubOAuthClientID)"
        UIApplication.sharedApplication().openURL(NSURL(string: URLString)!)
    }

}
