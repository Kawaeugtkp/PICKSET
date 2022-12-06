//
//  MainTabController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit
import Firebase

enum ActionButtonConfiguration {
    case tweet
    case message
}

class MainTabController: UITabBarController {
    
    //MARK: - Properties
    
    private var buttonConfig: ActionButtonConfiguration = .tweet
    
    var user: User? {
        didSet {
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers.first as? FeedController else { return } //まずnavを呼び出すやつは下のconfigureViewControllersmの中のviewcontrollersの配列の1個目を取ってきている。次の行はnav(UINavigationController)の中の配列の一個めを取ってきている。今回はこのnavは一個しかないんだけど、UINavigationControllerがごちゃごちゃ伸びているのとかよく見るよね。あのケースの時のためにあえて明示的にfirstを呼びますって書く必要がある
            
            guard let navSave = viewControllers?[4] as? UINavigationController else { return }
            guard let save = navSave.viewControllers.first as? SaveController else { return }
                        
            feed.user = user
            save.user = user
        }
    }
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .picksetRed
        button.setImage(UIImage(systemName: "plus.bubble"), for: .normal)
//        button.imageView?.contentMode = .scaleAspectFit これだけでは画像のデフォが最大拡大サイズで、下の2行があることによって満たすことができる。ただし今回は大きくなりすぎたので一旦放置
//        button.contentHorizontalAlignment = .fill
//        button.contentVerticalAlignment = .fill
//        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .picksetRed
        authenticateUserAndConfigureUI()
    }
    
    //MARK: - API
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { user in
            self.user = user
        }
    }
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen //このコードのおかげでログイン画面が下に下げられなくなる。つまりフルスクリーンで表示される
                self.present(nav, animated: true, completion: nil)
            } //ユーザーがログインしていないときにログイン画面を表示させるコード
        } else {
            configureUI()
            fetchUser()
            configureViewControllers()
        }
    }
    
    //MARK: - Selectors
    
    @objc func actionButtonTapped() {
        let controller: UIViewController
        controller = UploadController()
//        controller = PostController(collectionViewLayout: UICollectionViewFlowLayout())
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    func configureUI() {
//        self.delegate = self
        view.addSubview(actionButton)
        actionButton.centerX(inView: view)
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 10, width: 80, height: 80)
        actionButton.layer.cornerRadius = 80 / 2
//        actionButton.translatesAutoresizingMaskIntoConstraints = false //多分自動的に配置されないようにするっていうことだと思う。つまり、どこに配置するかはこれから自分で書くから勝手にしないでねって意味でfalseにしている
//        actionButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
//        actionButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
//        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64).isActive = true
//        actionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
//        actionButton.layer.cornerRadius = 56 / 2
    }
    
    func configureViewControllers() {
        
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout()) //feedcontrollerがUICollectionViewControllerのサブクラスになったからこの引数を設定しないといけなくなった。意味はよくわからない
        let nav1 = templateNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        let explore = SearchController(config: .userSearch)
        let nav2 = templateNavigationController(image: UIImage(systemName: "magnifyingglass"), rootViewController: explore)
//        let post = UploadController()
//        let nav3 = templateNavigationController(image: UIImage(named: "new_tweet"), rootViewController: post)
        let nav3 = UINavigationController()
        let notifications = NotificationsController()
//        notifications.tabBarItem.image = UIImage(named: "like_unselected")
        let nav4 = templateNavigationController(image: UIImage(systemName: "bell"), rootViewController: notifications)
        let save = SaveController(collectionViewLayout: UICollectionViewFlowLayout())
        let nav5 = templateNavigationController(image: UIImage(systemName: "dock.arrow.down.rectangle"), rootViewController: save)
        
        viewControllers = [nav1, nav2, nav3, nav4, nav5] //一発目に表示されるviewcontrollerがfeedなのは特にどっかで指定したわけではなく、ここで一番左にnav1があるからというだけの理由だった
        viewControllers![2].tabBarItem.isEnabled = false
        
        tabBar.tintColor = .picksetRed
    }
    
    func templateNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        nav.navigationBar.barTintColor = .white
        
        return nav
    }
}

//extension MainTabController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        let index = viewControllers?.firstIndex(of: viewController)
//        let imageName = index == 3 ? "mail" : "new_tweet"
//        actionButton.setImage(UIImage(named: imageName), for: .normal)
//        buttonConfig = index == 3 ? .message : .tweet
//    }
//}
