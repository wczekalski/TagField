//
//  Sizeable.swift
//  WCTagField
//
//  Created by Wojciech Czekalski on 23.01.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import UIKit

protocol Sizeable {
    func sizeForWidth(width: CGFloat) -> CGSize
    func sizeForHeight(height: CGFloat) -> CGSize
}

protocol SelfSizeable {
    func size() -> CGSize
}

extension UITextField : SelfSizeable {
    func size() -> CGSize {
        return systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }
}

extension UIButton : SelfSizeable {
    func size() -> CGSize {
        return systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }
}