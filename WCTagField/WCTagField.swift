//
//  WCTagField.swift
//  WCTagField
//
//  Created by Wojciech Czekalski on 16.01.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import UIKit
import SwiftBox

struct TagFieldStyle {
    let contentInsets: UIEdgeInsets
    let itemMargin: UIEdgeInsets
    let textOffset: UIOffset
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
    
    typealias TagButtonFactory = String -> UIButton
    typealias TextFieldFactory = () -> TagTextField
    
    var layout: (WCTagField) -> (buttonLayout: [Layout], textFieldLayout: Layout) = WCTagField.tagFieldLayout
    let tagButtonFactory: TagButtonFactory
    let textFieldFactory: TextFieldFactory
    let style: TagFieldStyle
    
    private lazy var textField: TagTextField = {
        return self.textFieldFactory()
    }()
    
    private var tagButtons: Array<UIButton> = []
    var tags: Array<String> = [] {
        didSet {
            tagButtons.forEach { self.removeTagButton($0) }
            tags.forEach { addTagButton(tagButton(text: $0)) }
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
    
    init(frame: CGRect, style: TagFieldStyle, tagButtonFactory: TagButtonFactory, textFieldFactory: TextFieldFactory) {
        self.style = style
        self.tagButtonFactory = tagButtonFactory
        self.textFieldFactory = textFieldFactory
        super.init(frame: frame)
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
		
        let evaluatedLayout = layout(self)
        
        for (view, layout) in Zip2Sequence(tagButtons, evaluatedLayout.buttonLayout) {
            view.frame = layout.frame
        }
        textField.frame = evaluatedLayout.textFieldLayout.frame
    }
    
    static func tagFieldLayout(tagField: WCTagField) -> (buttonLayout: [Layout], textFieldLayout: Layout) {
        let textFieldSize = tagField.textField.size()
        let offset = tagField.style.textOffset
        let margin = Edges(edgeInsets: tagField.style.itemMargin)
        let parentSize = tagField.frame.size
        
        let textNode = Node(size: CGSize(width: textFieldSize.width+offset.horizontal, height: textFieldSize.height+offset.vertical), margin: margin)
        
        let children = tagField.tagButtons.map { Node(size: $0.size(), margin: margin) } + [textNode]
        let parentNode = Node(children: children, direction: .Row , wrap: true, childAlignment: .Center, margin: Edges(edgeInsets: tagField.style.contentInsets))
        let layout = Node(size: parentSize, children: [parentNode]).layout(maxWidth: parentSize.width).children.first!
        
        return (Array(layout.children.dropLast()), layout.children.last!)
    }

    // MARK: Tag buttons management
    
    func tagButton(text text: String) -> UIButton {
        let button = tagButtonFactory(text)
        button.addTarget(self, action: "tappedButton:", forControlEvents: .TouchDown)
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

// This extension provides some defaults
extension WCTagField {
    convenience init() {
        let textFieldFactory = { TagTextField(frame: CGRectZero) }
        let tagButtonFactory: String -> UIButton = {
            let button = UIButton(type: .System)
            button.setTitle($0, forState: .Normal)
            return button
        }
        let style = TagFieldStyle(contentInsets: UIEdgeInsetsZero, itemMargin: UIEdgeInsetsZero, textOffset: UIOffsetZero)
        self.init(frame: CGRectZero, style: style, tagButtonFactory: tagButtonFactory, textFieldFactory: textFieldFactory)
    }
}
