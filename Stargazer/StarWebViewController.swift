//
//  StarWebViewController.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-07.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit
import WebKit

class StarWebViewController: UIViewController {

    let webView = WKWebView()
    var URLString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = self.webView

        if let URLString = URLString, URL = NSURL(string: URLString) {
            webView.loadRequest(NSURLRequest(URL: URL))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
