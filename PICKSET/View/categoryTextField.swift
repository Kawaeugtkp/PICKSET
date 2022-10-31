//
//  categoryTextField.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/10/14.
//

import UIKit

class categoryTextField: UITextField {
    
    private var topPadding: CGFloat = 10
    private var bottomPadding: CGFloat = 10
    private var leftPadding: CGFloat = 6
    private var rightPadding: CGFloat = 10
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets.init(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding))
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets.init(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding))
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }

    // コピー・ペースト・選択等のメニュー非表示
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
