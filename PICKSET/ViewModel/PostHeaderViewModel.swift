//
//  PostHeaderViewModel.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/17.
//

import UIKit

struct PostHeaderViewModel {
    
    // MARK: - Properties
    
    private let post: OPs
        
    let username: String
    
    // MARK: - Lifecycle
    
    init(post: OPs) {
        self.post = post
        self.username = "@" + post.user.username
    }
    
    // MARK:  - Helpers
    
    func size(forwidth width: CGFloat) -> CGSize { //ここで最初は引数にtext: Stringってしてcaptiontextを持ってきていたが、このviewmodelを呼び出している時点でtweetがinitializeされているためいちいち引数で呼び出す必要がない
        let measurementLabel = UILabel()
        measurementLabel.text = post.topic
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping //多分これはいい感じに改行をするっていうことだと思う
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false //多分これは自分でその幅とか高さとかアンカーとかを決めるので勝手にしないでねっていうことだと思う
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
