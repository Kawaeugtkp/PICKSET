//
//  ProfileHeader.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit

protocol ProfileHeaderDelegate: class {
    func handleDismissal()
    func handleEditProfileFollow(_ header: ProfileHeader)
    func didSelect(filter: ProfileFilteroptions)
    func handleFollowersTapped()
    func handleFollowingTapped()
}

class ProfileHeader: UICollectionReusableView {
    
    // MARK: - Properties
    
    var user: User? {
        didSet { configure() }
    }
    
    weak var delegate: ProfileHeaderDelegate?
    
    private let filterBar = ProfileFilterView()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 42, paddingLeft: 16)
        backButton.setDimensions(width: 30, height: 30)
        
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.backward")
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill //scaleaspectfitにインストラクターさんはしているけどscaleAspectFillじゃないとちゃんとなってない
        iv.clipsToBounds = true
        iv.backgroundColor = .picksetRed
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 4
        return iv
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.borderColor = UIColor.picksetRed.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.picksetRed, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        
        
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        label.addGestureRecognizer(followTap)
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        
        
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        label.addGestureRecognizer(followTap)
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    private lazy var introductionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ユーザー紹介 →", for: .normal)
        button.layer.borderColor = UIColor.picksetRed.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.picksetRed, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleShowIntrofuction), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        filterBar.delegate = self

//        addSubview(containerView)
//        containerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 108)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, paddingTop: -10)
        profileImageView.centerX(inView: self)
        profileImageView.setDimensions(width: 100, height: 100)
        profileImageView.layer.cornerRadius  = 100 / 2
        
        editProfileFollowButton.setDimensions(width: 100, height: 36)
        editProfileFollowButton.layer.cornerRadius = 36 / 2
        
        let userDetailsStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        userDetailsStack.axis = .vertical
        userDetailsStack.distribution = .fillProportionally //stackのそれぞれが正しいサイズの配分になるらしい。これは他にも2つ候補あったから変えて確認。fillは今のところよくわからなかったが、fillEquallyはstackのspacingを無視して今回なら3つのstackの要素に対して均等に縦幅を与えていたから、それぞれの感覚がすごく広くなっていた
        userDetailsStack.spacing = 4
        
        addSubview(userDetailsStack)
        userDetailsStack.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 12, paddingRight: 12)
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.centerY(inView: fullnameLabel)
        editProfileFollowButton.anchor(right: rightAnchor, paddingRight: 12) //このpaddingtopを70にしたあたりでなぜかボタンが機能しなくなった。原因不明
        
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
        followStack.axis = .horizontal
        followStack.spacing = 8
        followStack.distribution = .fillEqually
        
        addSubview(followStack)
        followStack.anchor(top: userDetailsStack.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 12)
        
        addSubview(introductionButton)
        introductionButton.setDimensions(width: frame.width - 20, height: 30)
        introductionButton.layer.cornerRadius = 5
        introductionButton.anchor(top: followStack.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20)
        
        addSubview(filterBar)
        filterBar.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors

    @objc func handleDismissal() {
        delegate?.handleDismissal()
    }
    
    @objc func handleEditProfileFollow() {
        delegate?.handleEditProfileFollow(self)
    }
    
    @objc func handleFollowersTapped() {
        delegate?.handleFollowingTapped()
    }
    
    @objc func handleFollowingTapped() {
        delegate?.handleFollowersTapped()
    }
    
    @objc func handleShowIntrofuction() {
        
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let user = user else { return }
        
        let viewModel = ProfileHeaderViewModel(user: user)
        
        editProfileFollowButton.setTitle(viewModel.actionButtontitle, for: .normal)
        profileImageView.sd_setImage(with: user.profileImageUrl)
        
        followingLabel.attributedText = viewModel.followingString
        followersLabel.attributedText = viewModel.followersString
        
        fullnameLabel.text = user.fullname
        usernameLabel.text = viewModel.usernameText
    }
}

// MARK: - ProfileFilterViewDelegate

extension ProfileHeader: ProfileFilterViewDelegate {
    func filterView(_ view: ProfileFilterView, didSelect index: Int) { //ここの引数の中身がprofilefilterviewの中で定義したときはなかったけど、delegateの中で当てはめたやつになってる
        guard let filter = ProfileFilteroptions(rawValue: index) else { return }
                
        delegate?.didSelect(filter: filter)
    }
}
