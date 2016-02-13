//
//  TagButton.swift
//  WCTagField
//
//  Created by Wojciech Czekalski on 13.02.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import UIKit

class TagButton : UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
        layer.cornerRadius = frame.size.height/2
    }
}