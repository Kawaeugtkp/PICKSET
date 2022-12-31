//
//  DetailCell.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/12/30.
//

import UIKit

class DetailScrollView: UIScrollView {
    
    // MARK: - Properties
    
    var post: OPs? { //TweetCellの時と同じ感じで作る
        didSet { configure() }
    }
    
    private let topicLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "おはようApr 3, 2014 — しかし、複数のアプリ間で特定のユーザーを追跡可能で、ユーザーが自由にIDを変更する ... で、AndroidOSの拡張機能をアプリ形式で提供するものです。"
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "おはようApr 3, 2014 — しかし、複数のアプリ間で特定のユーザーを追跡可能で、ユーザーが自由にIDを変更する ... で、AndroidOSの拡張機能をアプリ形式で提供するものです。"
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(topicLabel)
        addSubview(topicLabel)
        topicLabel.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20)
        
        addSubview(descriptionLabel)
        descriptionLabel.anchor(top: topicLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: 20)
        
        let blankView = UIView()
        blankView.backgroundColor = .white
        
        addSubview(blankView)
        anchor(top: descriptionLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let post = post else { return }
        topicLabel.text = post.topic
        descriptionLabel.text = post.description
    }
}
