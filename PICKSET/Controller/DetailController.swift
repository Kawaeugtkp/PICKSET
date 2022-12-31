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
    
    lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.setDimensions(width: 240, height: 160)
        iv.layer.cornerRadius = 10
        iv.backgroundColor = .lightGray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePostImageTapped))
        
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()

        let topicLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.text = "おはようApr 3, 2014 — しかし、複数のアプリ間で特定のユーザーを追跡可能で、ユーザーが自由にIDを変更する ... で、AndroidOSの拡張機能をアプリ形式で提供するものです。"
            label.numberOfLines = 0
            return label
        }()

        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 18)
            label.text = "おはようApr 3, 2014 — しかし、複数のアプリ間で特定のユーザーを追跡可能で、ユーザーが自由にIDを変更する ... で、AndroidOSの拡張機能をアプリ形式で提供するものです。"
            label.numberOfLines = 0
            return label
        }()

        sv.addSubview(topicLabel)
        topicLabel.anchor(top: sv.topAnchor, left: sv.leftAnchor, right: sv.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20)

        sv.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: topicLabel.bottomAnchor, left: sv.leftAnchor, right: sv.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: 20)

        return sv
    }()

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Selectors

    @objc func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handlePostImageTapped() {
        
    }

    // MARK: - Helpers

    func configureUI() {
        view.backgroundColor = .white

//        scrollView.frame = view.frame
//        //スクロール領域の設定
//        scrollView.contentSize = CGSize(width: view.bounds.width, height: 550)
//        view.addSubview(scrollView)

        view.addSubview(topicLabel)
        topicLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 25, paddingLeft: 20, paddingRight: 20)
        
        if post.postImageUrl != nil {
            postImageView.sd_setImage(with: post.postImageUrl)
            view.addSubview(postImageView)
            postImageView.centerX(inView: view)
            postImageView.anchor(top: topicLabel.bottomAnchor, paddingTop: 25)
            
            view.addSubview(descriptionLabel)
            descriptionLabel.anchor(top: postImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 25, paddingLeft: 20, paddingRight: 20)
        } else {
            view.addSubview(descriptionLabel)
            descriptionLabel.anchor(top: topicLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: 20)
        }
    }

    func configure() {
        topicLabel.text = post.topic
        descriptionLabel.text = post.description
    }
}

//private let reuseIdentifier = "DetailCell"


//class DetailController: UIViewController {
//
//    // MARK: - Properties
//
//    private var post: OPs
//
//    private var scrollView = DetailScrollView()
////
////    private let scrollView: UIScrollView = {
////        let sv = UIScrollView()
////
////        let topicLabel: UILabel = {
////            let label = UILabel()
////            label.font = UIFont.boldSystemFont(ofSize: 20)
////            label.text = "おはようApr 3, 2014 — しかし、複数のアプリ間で特定のユーザーを追跡可能で、ユーザーが自由にIDを変更する ... で、AndroidOSの拡張機能をアプリ形式で提供するものです。"
////            label.numberOfLines = 0
////            return label
////        }()
////
////        let descriptionLabel: UILabel = {
////            let label = UILabel()
////            label.font = UIFont.systemFont(ofSize: 18)
////            label.text = "おはようApr 3, 2014 — しかし、複数のアプリ間で特定のユーザーを追跡可能で、ユーザーが自由にIDを変更する ... で、AndroidOSの拡張機能をアプリ形式で提供するものです。"
////            label.numberOfLines = 0
////            return label
////        }()
////
////        sv.addSubview(topicLabel)
////        topicLabel.anchor(top: sv.topAnchor, left: sv.leftAnchor, right: sv.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20)
////
////        sv.addSubview(descriptionLabel)
////        descriptionLabel.anchor(top: topicLabel.bottomAnchor, left: sv.leftAnchor, right: sv.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: 20)
////
////        return sv
////    }()
////
////    private let topicLabel: UILabel = {
////        let label = UILabel()
////        label.font = UIFont.boldSystemFont(ofSize: 20)
////        label.text = "おはようApr 3, 2014 — しかし、複数のアプリ間で特定のユーザーを追跡可能で、ユーザーが自由にIDを変更する ... で、AndroidOSの拡張機能をアプリ形式で提供するものです。"
////        label.numberOfLines = 0
////        return label
////    }()
////
////    private let descriptionLabel: UILabel = {
////        let label = UILabel()
////        label.font = UIFont.systemFont(ofSize: 18)
////        label.text = "おはようApr 3, 2014 — しかし、複数のアプリ間で特定のユーザーを追跡可能で、ユーザーが自由にIDを変更する ... で、AndroidOSの拡張機能をアプリ形式で提供するものです。"
////        label.numberOfLines = 0
////        return label
////    }()
////
//    // MARK: - Lifecycle
//
//    init(post: OPs) {
//        self.post = post
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        configure()
//        configureUI()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tabBarController?.tabBar.isHidden = true
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        tabBarController?.tabBar.isHidden = false
//    }
//
//    // MARK: - Helpers
//
//    func configureUI() {
//        view.backgroundColor = .white
//
//        scrollView.post = post
//
//        scrollView.frame = view.frame
//        //スクロール領域の設定
//        scrollView.contentSize = CGSize(width: view.bounds.width, height: 550)
//        view.addSubview(scrollView)
//
////        scrollView.frame = view.frame
////        //スクロール領域の設定
////        scrollView.contentSize = CGSize(width: view.bounds.width, height: 550)
////        view.addSubview(scrollView)
//
////        view.addSubview(topicLabel)
////        topicLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20)
////
////        view.addSubview(descriptionLabel)
////        descriptionLabel.anchor(top: topicLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: 20)
//    }
//
////    func configure() {
////        topicLabel.text = post.topic
////        descriptionLabel.text = post.description
////    }
//}
