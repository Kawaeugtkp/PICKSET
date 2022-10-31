//
//  UserCell.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit

class UserCell: UITableViewCell {
    
    // MARK: - Properties
    
    var user: User? { //TweetCellの時と同じ感じで作る
        didSet { configure() }
    }
    
    private lazy var profileIMageView: UIImageView = { //ここもtapを加えるまではletだったけどlazy varにしないといけなくなった。ボタン系のアクションがしたかったらlazy varにしないといけないっぽい
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill //ちなみにこれがfeedcotrollerの左下のボタンのとこには設定されていなくて、実際このコードなしでもなんか違和感なさそう（ズームしたらわからんけど）なので、必要性は不明
        iv.clipsToBounds = true
        iv.setDimensions(width: 40, height: 40)
        iv.layer.cornerRadius = 40 / 2
        iv.backgroundColor = .picksetRed
        
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Fullname"
        return label
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Username"
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(profileIMageView)
        profileIMageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        let stack = UIStackView(arrangedSubviews: [usernameLabel, fullnameLabel])
        stack.axis = .vertical
        stack.spacing = 2
        
        addSubview(stack)
        stack.centerY(inView: profileIMageView, leftAnchor: profileIMageView.rightAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let user = user else { return }
        
        profileIMageView.sd_setImage(with: user.profileImageUrl)
        usernameLabel.text = "@\(user.username)"
        fullnameLabel.text = user.fullname
    }
}
