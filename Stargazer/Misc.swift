//
//  Misc.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-08.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit

extension CALayer {
    var borderUIColor: UIColor {
        get {
            return UIColor(CGColor: self.borderColor!)
        }
        set {
            self.borderColor = newValue.CGColor
        }
    }
}
