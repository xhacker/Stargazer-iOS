//
//  LanguageLabel.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-08.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit

class LanguageLabel: UILabel {
    
    override var textColor: UIColor! {
        didSet {
            layer.borderUIColor = textColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 2
        layer.borderWidth = 1
        layer.borderUIColor = UIColor.blackColor()
    }
    
    override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        
        size.width += 10
        if size.width < 24 {
            size.width = 24
        }
        
        return size
    }

}
