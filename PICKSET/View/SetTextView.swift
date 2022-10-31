//
//  SetTextView.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/19.
//

import Foundation
import UIKit

class SetTextView: UITextView {
    
    //MARK: - Properties
    
    let placeholderLabel: UILabel = { //placeholderはあの入力前のちょっと薄い導入文みたいなやつ
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .darkGray
        label.text = "What's happening?"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = .white
        font = UIFont.boldSystemFont(ofSize: 20) //これが入力時のフォントっぽい
        isScrollEnabled = true
//        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        addSubview(placeholderLabel) //このクラス自体がUIText"View"のサブクラスだからview.addsubViewとかにしなくていい
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleTextInputChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
}
