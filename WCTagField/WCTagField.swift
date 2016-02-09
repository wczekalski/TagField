//
//  WCTagField.swift
//  WCTagField
//
//  Created by Wojciech Czekalski on 16.01.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import UIKit
import SwiftBox

struct ButtonStyle {
    let font: UIFont
    let textColor: UIColor
    let selectedTextColor: UIColor
    let borderWidth: CGFloat
    let contentInsets: UIEdgeInsets
    let margin: Edges
    let roundedCorners: Bool
    
    init(font: UIFont = .systemFontOfSize(14), textColor: UIColor = .blueColor(), selectedTextColor: UIColor = .whiteColor(), borderWidth: CGFloat = 1, contentInsets: UIEdgeInsets = UIEdgeInsetsZero, margin: Edges = Edges(), roundedCorners: Bool = true) {
        self.font = font
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
        self.borderWidth = borderWidth
        self.contentInsets = contentInsets
        self.roundedCorners = roundedCorners
        self.margin = margin
    }
}

struct TextFieldStyle {
    let font: UIFont
    let textColor: UIColor
    let textOffset: UIOffset
}

struct TagFieldStyle {
    let buttonStyle: ButtonStyle
    let textFieldStyle: TextFieldStyle
    let contentInsets: UIEdgeInsets
}

extension UIButton {
    func applyStyle(style: ButtonStyle) {
        setTitleColor(style.textColor, forState: .Normal)
        setTitleColor(style.selectedTextColor, forState: .Selected)
        titleLabel?.font = style.font
        layer.borderWidth = style.borderWidth
        layer.borderColor = self.tintColor.CGColor
        self.contentEdgeInsets = style.contentInsets
    }
}

extension UITextField {
    func applyStyle(style: TextFieldStyle) {
        font = style.font
        textColor = style.textColor
    }
}

extension Edges {
    init(edgeInsets: UIEdgeInsets) {
        left = edgeInsets.left
        right = edgeInsets.right
        bottom = edgeInsets.bottom
        top = edgeInsets.top
    }
}

class WCTagField : UIView, UITextFieldDelegate {
    
    let style: TagFieldStyle
    
    private let textField = TagTextField(frame: CGRectZero)
    
    private var tagButtons: Array<UIButton> = []
    var tags: Array<String> = [] {
        didSet {
            tagButtons.forEach { self.removeTagButton($0) }
            tags.forEach { addTagButton(tagButton(style: style.buttonStyle, text: $0)) }
        }
    }
    
    private weak var selectedButton: UIButton? {
        didSet {
            oldValue?.selected = false
            oldValue?.backgroundColor = .clearColor()
            selectedButton?.selected = true
            selectedButton?.backgroundColor = selectedButton?.tintColor
        }
    }
    
    private let gestureRecognizer = UITapGestureRecognizer()
    
    init(frame: CGRect, style: TagFieldStyle) {
        self.style = style
        super.init(frame: frame)
        
        textField.applyStyle(style.textFieldStyle)
        textField.contentVerticalAlignment = .Center
        
        
        textField.onBackspace = { [weak self] in
            self?.removeSelectedButton()
        }
        
        textField.frame = self.bounds
        textField.delegate = self
        addSubview(textField)
        addGestureRecognizer(gestureRecognizer)
        
        textField.addTarget(self, action: "textDidChange", forControlEvents: .AllEditingEvents)
        gestureRecognizer.addTarget(textField, action: "becomeFirstResponder")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layout(buttons: [UIView], textField: UITextField, parentSize: CGSize) -> (buttonsLayout: [Layout], textFieldLayout: Layout) {
        
        let size = { (view: UIView) in view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) }
        
        let systemSize = size(textField)
        let offset = style.textFieldStyle.textOffset
        let margin = self.style.buttonStyle.margin
        
        let textNode = Node(size: CGSize(width: systemSize.width+offset.horizontal, height: systemSize.height+offset.vertical), margin: margin)
        
        let children = buttons.map { Node(size: size($0), margin: margin) } + [textNode]
        let parentNode = Node(children: children, direction: .Row , wrap: true, childAlignment: .Center, margin: Edges(edgeInsets: style.contentInsets))
        let layout = Node(size: parentSize, children: [parentNode]).layout(maxWidth: parentSize.width).children.first!
        
        return (Array(layout.children.dropLast()), layout.children.last!)
        }
    
    override func layoutSubviews() {
        super.layoutSubviews()
		
        let evaluatedLayout = layout(tagButtons, textField: textField, parentSize: bounds.size)
        
        for (view, layout) in Zip2Sequence(tagButtons, evaluatedLayout.buttonsLayout) {
            view.frame = layout.frame
            if self.style.buttonStyle.roundedCorners {
                view.layer.cornerRadius = CGRectGetHeight(layout.frame)/2
            }
        }
        textField.frame = evaluatedLayout.textFieldLayout.frame
    }
    
    func tagButton(style style: ButtonStyle, text: String) -> UIButton {
        let button = UIButton(type: .System)
        button.setTitle(text, forState: .Normal)
        button.addTarget(self, action: "tappedButton:", forControlEvents: .TouchDown)
        button.clipsToBounds = true
        button.applyStyle(style)
        return button
    }
    
    func addTagButton(button: UIButton) {
        self.tagButtons.append(button)
        addSubview(button)
    }
    
    func removeSelectedButton() {
        if let selected = selectedButton where textField.text == "" {
            removeTagButton(selected)
            self.selectedButton = nil
        }
    }
    
    func removeTagButton(button: UIButton) {
        tagButtons.removeAtIndex(tagButtons.indexOf(button)!)
        button.removeFromSuperview()
    }
    
    @objc func tappedButton(sender: UIButton) {
        if selectedButton == sender {
            selectedButton = nil
        } else {
            selectedButton = sender
        }
    }
    
    //MARK: Text field
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
        if string == "\n" {
            tags.append(textField.text!)
            textField.text = nil
            return false
        }
        
        return stringIsValid(string)
    }
    
    func stringIsValid(string: String) -> Bool {
        for char in string.utf16 {
            if NSCharacterSet.alphanumericCharacterSet().characterIsMember(char) == false {
                return false
            }
        }
        return true
    }
    
    @objc func textDidChange() {
        setNeedsLayout()
        layoutIfNeeded()
    }
}
