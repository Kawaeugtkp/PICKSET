//
//  PostHeader.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/11.
//

import Foundation
import UIKit

protocol PostHeaderDelegate: class {
    func handleDismissal()
    func handleAddSet()
    func picksetTapped(_ cell: SetCell)
    func handleMessageTapped(_ cell: SetCell)
    func selectSet(_ cell: SetCell)
    func handleUsernameTapped(_ header: PostHeader)
    func handleShowDescription(_ header: PostHeader)
}

class PostHeader: UICollectionReusableView {
    
    // MARK: - Properties
    
    var post: OPs? {
        didSet {
            configure()
        }
    }
    
    weak var delegate: PostHeaderDelegate?
    
    let filterBar = SetFilterView()
        
    private lazy var userLabel: UILabel = {
        let label = UILabel()
        label.text = "@venom"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTapped))
        
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    private let topicLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.text = "おはようApr 3, 2014 — しかし、複数のアプリ間で特定のユーザーを追跡可能で、ユーザーが自由にIDを変更する ... で、AndroidOSの拡張機能をアプリ形式で提供するものです。"
        label.layer.borderColor = UIColor.white.cgColor
        label.numberOfLines = 0
        return label
    }()
    
    private let voteLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 42, paddingLeft: 16)
        backButton.setDimensions(width: 30, height: 30)
        
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "baseline_arrow_back_white_24dp")
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var descriptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("トピックの説明を見る", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleShowDescription), for: .touchUpInside)
        return button
    }()
    
    lazy var addSetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ セットを追加", for: .normal)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(handleAddSet), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        filterBar.delegate = self
        
//        backgroundColor = .lightGray.withAlphaComponent(0.5)
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.picksetRed.cgColor, UIColor.white.cgColor]
        gradient.locations = [0, 1] //to 0.1 とかだとグラデーションが上の方で完結してしまう
        layer.addSublayer(gradient)
        gradient.frame = frame
        
        addSubview(containerView)
        containerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 108)
        
        addSubview(userLabel)
        userLabel.anchor(top: topAnchor, paddingTop: 60)
        userLabel.centerX(inView: self)
        
        addSubview(topicLabel)
        topicLabel.anchor(top: userLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 30, paddingRight: 30)
        topicLabel.centerX(inView: self) //ここを間違ってcenterYにしていた。そうするともうanchorなんかは全然効かなかったから注意
        
        addSubview(descriptionButton)
        descriptionButton.setDimensions(width: frame.width - 20, height: 30)
        descriptionButton.layer.cornerRadius = 5
        descriptionButton.anchor(top: topicLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20)
        
        addSubview(voteLabel)
        voteLabel.anchor(top: descriptionButton.bottomAnchor, left: leftAnchor, paddingTop: 10, paddingLeft: 40)
        
        addSubview(addSetButton)
        addSetButton.setDimensions(width: 100, height: 30)
        addSetButton.layer.cornerRadius = 30 / 2
        addSetButton.anchor(top: descriptionButton.bottomAnchor, right: rightAnchor, paddingTop: 15, paddingRight: 25)
        
        addSubview(filterBar)
        filterBar.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 130)
//        filterBar.post = post
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        delegate?.handleDismissal()
    }
    
    @objc func handleShowDescription() {
        delegate?.handleShowDescription(self)
    }
    
    @objc func handleAddSet() {
        delegate?.handleAddSet()
    }
    
    @objc func handleUsernameTapped() {
        print("DEBUG: username tapped")
        delegate?.handleUsernameTapped(self)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let post = post else { return }
        let viewModel = PostHeaderViewModel(post: post)
        topicLabel.text = post.topic
        userLabel.text = viewModel.username
        voteLabel.text = "\(post.vote)"
    }
}

// MARK: - SetFilterViewDelegate

extension PostHeader: SetFilterViewDelegate {
    func selectSet(_ cell: SetCell) {
        delegate?.selectSet(cell)
    }
    
    func handleMessageTapped(_ cell: SetCell) {
        delegate?.handleMessageTapped(cell)
    }
    
    func picksetTapped(_ cell: SetCell) {
        delegate?.picksetTapped(cell)
    }
}
