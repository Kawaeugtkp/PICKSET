//
//  Utilities.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import Foundation
import UIKit

class Utilities {
    func inputContainerView(withImage image: UIImage? = nil, textField: UITextField) -> UIView {
        let view = UIView()
        let iv = UIImageView()
        iv.tintColor = .picksetRed
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        iv.image = image
        view.addSubview(iv)
        iv.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, paddingLeft: 8, paddingBottom: 8) //ちなみにここで左にpadding入れているせいで左右の空間の広さが違う
        iv.setDimensions(width: 24, height: 24)
        view.addSubview(textField)
        textField.anchor(left: iv.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
        let dividerView = UIView()
        dividerView.backgroundColor = .white
        view.addSubview(dividerView)
        dividerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, height: 0.7)//ちなみにここで左にpadding入れているせいで左右の空間の広さが違う
        return view
    }
    
    func textField(withPlaceHolder placeHolder: String) -> UITextField {
//        let tf = UITextField()
//        tf.placeholder = placeHolder
//        tf.textColor = .white
//        tf.font = UIFont.systemFont(ofSize: 16)
//        return tf                               これだとplaceholderがいけてないから以下のようにして自然な白のplaceholderを完成させる
        let tf = UITextField()
        tf.textColor = .white
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        return tf
    }
    
    func attributedButton(_ firstPart: String, _ secondPart: String) -> UIButton {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: firstPart, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSMutableAttributedString(string: secondPart, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white]))
        
        button.setAttributedTitle(attributedTitle, for: .normal) //多分だけど、いくつかの要素をタイトル内に組み込みたい（今回なら部分的に太字にしたい）みたいなときにattributedTitleを使うんだと思う。Log inボタンとかはそういうのないから普通のsetTitleでいけてるんだと思う
        return button
    }
}
