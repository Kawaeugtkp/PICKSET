//
//  CustomTextField.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/12/07.
//

import UIKit

class CustomTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        
        let spacer = UIView()
        spacer.setDimensions(width: 12, height: 50)
        leftView = spacer
        leftViewMode = .always
        
        borderStyle = .none
        keyboardAppearance = .dark
        keyboardType = .emailAddress
        backgroundColor = .lightGray.withAlphaComponent(0.5)
        setHeight(50)
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.black])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
