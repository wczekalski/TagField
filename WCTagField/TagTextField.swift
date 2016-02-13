//
//  TagTextField.swift
//  WCTagField
//
//  Created by Wojciech Czekalski on 13.02.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import UIKit

class TagTextField : UITextField {
    
    var onBackspace: () -> () = {}
    
    override func deleteBackward() {
        super.deleteBackward()
        onBackspace()
    }
    
}