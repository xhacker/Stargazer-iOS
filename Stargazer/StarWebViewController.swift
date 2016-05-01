//
//  StarWebViewController.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-07.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit
import WebKit
import CLTokenInputView

class StarWebViewController: UIViewController, CLTokenInputViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var tokenInputView: CLTokenInputView!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var repo: Repo?
    var shouldActiveTokenInputView = false
    var addingTokenProgrammatically = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = repo?.name
        if let URLString = repo?.html_url, URL = NSURL(string: URLString) {
            webView.loadRequest(NSURLRequest(URL: URL))
        }
        
        print("Loading tags for \(repo!.name): \(repo!.tags)")
        addingTokenProgrammatically = true
        for tag in repo!.tags {
            tokenInputView.addToken(CLToken(displayText: tag.name, context: nil))
        }
        addingTokenProgrammatically = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldActiveTokenInputView {
            tokenInputView.beginEditing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CLTokenInputViewDelegate
    
    func tokenInputView(view: CLTokenInputView, tokenForText text: String) -> CLToken? {
        let token = CLToken(displayText: text, context: nil)
        return token
    }
    
    func tokenInputView(view: CLTokenInputView, didAddToken token: CLToken) {
        if !addingTokenProgrammatically {
            saveTokens()
        }
    }
    
    func tokenInputView(view: CLTokenInputView, didRemoveToken token: CLToken) {
        saveTokens()
    }
    
    func saveTokens() {
        let tags = tokenInputView.allTokens.map({ token in
            Tag.returnOrCreate(token.displayText, inContext: self.managedObjectContext)
        })
        print("Saving tags: \(tags)")
        repo?.tags = NSSet(array: tags)
    }
    
    func tokenInputViewDidBeginEditing(view: CLTokenInputView) {
        view.accessoryView = addButton()
    }
    
    func addButton() -> UIButton {
        let addButton = UIButton(type: .ContactAdd) as UIButton
        // TODO: add target action
        return addButton
    }
    
    func tokenInputViewDidEndEditing(view: CLTokenInputView) {
        view.accessoryView = nil
    }

}
