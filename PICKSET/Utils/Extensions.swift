//
//  Extensions.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func center(inView view: UIView, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }
    
    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
        }
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat? = nil, constant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant!).isActive = true
        
        if let leftAnchor = leftAnchor, let padding = paddingLeft {
            self.leftAnchor.constraint(equalTo: leftAnchor, constant: padding).isActive = true
        }
    }
    
    func setDimensions(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func addConstraintsToFillView(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        anchor(top: view.topAnchor, left: view.leftAnchor,
               bottom: view.bottomAnchor, right: view.rightAnchor)
    }
}

// MARK: - UIColor

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let picksetRed = UIColor.rgb(red: 241, green: 2, blue: 105)
    static let twitterBlue = UIColor.rgb(red: 29, green: 161, blue: 242)
}

// MARK: - String

extension String {

    public func isOnly(structuredBy chars: String) -> Bool {
        let characterSet = NSMutableCharacterSet()
        characterSet.addCharacters(in: chars)
        return self.trimmingCharacters(in: characterSet as CharacterSet).count <= 0
    }
    
    public func labelHeight(width: CGFloat,
                            font: UIFont,
                            lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGSize {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude) //この-32はtweetgheader用の実装
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = lineBreakMode
        return (self as NSString).boundingRect(with: size,
                                               options: [.usesLineFragmentOrigin,
                                                         .usesFontLeading],
                                               attributes: [.font: font,
                                                            .paragraphStyle: style],
                                               context: nil).size
    }
}

extension UILabel {

  /// 行数を返す
  func lineNumber() -> Int {
    let oneLineRect  =  "a".boundingRect(
      with: self.bounds.size,
      options: .usesLineFragmentOrigin,
      attributes: [NSAttributedString.Key.font: self.font ?? UIFont()],
      context: nil
    )
    let boundingRect = (self.text ?? "").boundingRect(
      with: self.bounds.size,
      options: .usesLineFragmentOrigin,
      attributes: [NSAttributedString.Key.font: self.font ?? UIFont()],
      context: nil
    )

    return Int(boundingRect.height / oneLineRect.height)
  }

}
