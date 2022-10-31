//
//  SetViewModel.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/24.
//

import UIKit

struct SetViewModel {
    
    let set: Sets
    
    var setButtonTintColor: UIColor {
        return set.didPick ? .black : .white
    }
    
    var cellTintColor: UIColor {
        return set.didSelect ? .picksetRed : .picksetRed.withAlphaComponent(0.2)
    }
    
    var percentageString: NSAttributedString? {
        return attributedText(withValue: set.percentage, text: "%")
    }
    
    init(set: Sets) {
        self.set = set
    }
    
    fileprivate func attributedText(withValue value: Double, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: String(format: "%.1f", value), attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        return attributedTitle
    }
}
