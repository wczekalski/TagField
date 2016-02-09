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
        
        let buttonStyle = ButtonStyle(contentInsets: UIEdgeInsets(top: 5, left: 6, bottom: 5, right: 6), margin: Edges(left: 5, right: 5, bottom: 5, top: 5))
        
        let textFieldStyle = TextFieldStyle(font: buttonStyle.font, textColor: UIColor.blackColor(), textOffset: UIOffsetMake(0, 5))
        let style = TagFieldStyle(buttonStyle: buttonStyle, textFieldStyle: textFieldStyle, contentInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        
        let field = WCTagField(frame: view.bounds, style: style)
        field.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(field)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

