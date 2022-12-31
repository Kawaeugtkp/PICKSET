//
//  NotificationCell.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import Foundation
import UIKit

protocol NotificationCellDelegate: class {
    func handleProfileImageTapped(_ cell: NotificationCell)
    func didTapFollow(_ cell: NotificationCell)
}

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    var notification: Notification? {
        didSet { configure() }
    }
    
    weak var delegate: NotificationCellDelegate?
    
    private lazy var profileIMageView: UIImageView = { //ここもtapを加えるまではletだったけどlazy varにしないといけなくなった。ボタン系のアクションがしたかったらlazy varにしないといけないっぽい
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill //ちなみにこれがfeedcotrollerの左下のボタンのとこには設定されていなくて、実際このコードなしでもなんか違和感なさそう（ズームしたらわからんけど）なので、必要性は不明
        iv.clipsToBounds = true
        iv.setDimensions(width: 40, height: 40)
        iv.layer.cornerRadius = 40 / 2
        iv.backgroundColor = .picksetRed
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true //これをfalseにするとボタン的な動作が完全になくなった
        
        return iv
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.picksetRed, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.picksetRed.cgColor
        button.layer.borderWidth = 2
        button.addTarget(self, action: #selector(handleFollowersTapped), for: .touchUpInside)
        return button
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Some test notification message"
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = UIStackView(arrangedSubviews: [profileIMageView, notificationLabel])
        stack.spacing = 8
        stack.alignment = .center
        
        contentView.addSubview(stack) //怖い。これはアップデートによってcontentviewを前につけないといけなくなったパターンらしい。おそらくだが、これをusercellの方にしなくてもよかったのは、あっちでは画像を個別にタップして挙動が起こることがなかったから。
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        stack.anchor(right: rightAnchor, paddingRight: 12)
        
//        addSubview(followButton) //こっちはbuttonだったからなのか、contentviewをつけなくてもしっかりdelegteが機能している
//        followButton.centerY(inView: self)
//        followButton.setDimensions(width: 92, height: 32)
//        followButton.layer.cornerRadius = 32 / 2
//        followButton.anchor(right: rightAnchor, paddingRight: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    
    @objc func handleFollowersTapped() {
        delegate?.didTapFollow(self)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let notification = notification else { return }
        let viewModel = NotificationViewModel(notification: notification)
        profileIMageView.sd_setImage(with: viewModel.profileImageUrl)
        notificationLabel.attributedText = viewModel.notificationText
        
        followButton.isHidden = viewModel.shouldHideFollowButton
        followButton.setTitle(viewModel.followButtonText, for: .normal)
    }
}
