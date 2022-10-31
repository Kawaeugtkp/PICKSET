//
//  DetailController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/30.
//

import Foundation
import UIKit

class DetailController: UIViewController {
    
    // MARK: - Properties
    
    private var post: OPs
    
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
    
    // MARK: - Lifecycle
    
    init(post: OPs) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 108)
        
        view.addSubview(topicLabel)
        topicLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: 20)
        
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: topicLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: 20)
    }
    
    func configure() {
        topicLabel.text = post.topic
        descriptionLabel.text = post.description
    }
}
