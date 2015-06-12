//
//  CardView.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-06-02.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit

// Courtesy of Zhixuan Lai’s ZLSwipeableViewSwiftDemo
class CardView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor.whiteColor()
        
        // Shadow
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.33
        layer.shadowOffset = CGSizeMake(0, 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        // Corner Radius
        layer.cornerRadius = 10.0;
    }

}
