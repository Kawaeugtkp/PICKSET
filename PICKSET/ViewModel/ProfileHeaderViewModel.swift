//
//  ProfileHeaderViewModel.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit

enum ProfileFilteroptions: Int, CaseIterable {
    case posts
    case opinions
    case likes
    
    var descriptions: String {
        switch self {
        case .posts: return "Posts"
        case .opinions: return "Opinions"
        case .likes: return "Likes"
        }
    }
}


struct ProfileHeaderViewModel {
    
    private let user: User
    
    let usernameText: String
    
    var followersString: NSAttributedString? {
        return attributedText(withValue: user.stats?.followers ?? 0, text: "フォロワー")
    }
    
    var followingString: NSAttributedString? {
        return attributedText(withValue: user.stats?.following ?? 0, text: "フォロー")
    }
    
    var actionButtontitle: String { //なんかこれでviewmodelの役割が少しわかった。このfollowかfollowingかを変えるっていう操作をviewの方（つまりprofileheader)の中で設定するのはなんか違う
        
        if user.isCurrentUser {
            return "Edit Profile"
        }else if user.isFollowed {
            return "Following"
        } else {
            return "Follow" //なぜかfollowingの時だけデフォがfollowみたいな表示になっているのが悲しい
        }
    }
    
    init(user: User) {
        self.user = user
        self.usernameText = "@" + user.username
    }
    
    // MARK: - Helpers
    
    func size(forwidth width: CGFloat) -> CGSize { //ここで最初は引数にtext: Stringってしてcaptiontextを持ってきていたが、このviewmodelを呼び出している時点でtweetがinitializeされているためいちいち引数で呼び出す必要がない
        let measurementLabel = UILabel()
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping //多分これはいい感じに改行をするっていうことだと思う
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false //多分これは自分でその幅とか高さとかアンカーとかを決めるので勝手にしないでねっていうことだと思う
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        return attributedTitle
    }
}
