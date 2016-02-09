//
//  ViewController.swift
//  WCTagField
//
//  Created by Wojciech Czekalski on 16.01.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import UIKit
import SwiftBox

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let font = UIFont.systemFontOfSize(14)
        
        let style = TagFieldStyle(contentInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), itemMargin: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), textOffset: UIOffset(horizontal: 0, vertical: 5))
        let tagButtonFactory: String -> UIButton = { text in
            let button = TagButton(type: .System)
            button.titleLabel?.font = font
            button.layer.borderColor = button.tintColor.CGColor 
            button.layer.borderWidth = 1
            button.setTitle(text, forState: .Normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            return button
        }
        let textFieldFactory: () -> TagTextField = {
            let textField = TagTextField()
            textField.font = font
            return textField
        }
        let field = WCTagField(frame: view.bounds, style: style, tagButtonFactory: tagButtonFactory, textFieldFactory: textFieldFactory)
        
        field.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(field)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

