//
//  DiscouverViewController.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-04-30.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift

class DiscouverViewController: UIViewController {

    @IBOutlet weak var swipeableView: ZLSwipeableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var views = 5
        
        swipeableView.nextView = {
            if views <= 0 {
                return nil
            }
            views -= 1
            
            let view = CardView(frame: self.swipeableView.bounds)
            return view
        }
//        swipeableView.numPrefetchedViews = 3
        swipeableView.loadViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

