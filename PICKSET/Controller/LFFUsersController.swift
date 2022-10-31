//
//  LFFUsersController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/10/25.
//

import UIKit

private let reuseIdentifier = "UserCell"

class LFFUsersController: UITableViewController {
    // MARK: - Properties
    
    private let opinion: OPs?
    
    private let user: User?
    
    private let userType: String
    
    private var users = [User]() {
        didSet { tableView.reloadData() }
    }
    
    // MARK: - Lifecycle
    
    init(opinion: OPs? = nil, user: User? = nil, userType: String) {
        self.opinion = opinion
        self.user = user
        self.userType = userType
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
        let image = UIImage(systemName: "arrow.backward")
        self.navigationController?.navigationBar.backIndicatorImage = image?.withRenderingMode(.alwaysOriginal)
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = image?.withRenderingMode(.alwaysOriginal)
//        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        navigationItem.backBarButtonItem = backBarButton この2行をここではなくて変異前のコントローラー（つまりTweetController）のviewdidloadに置いたらいけた。ただ、今はTweetControllerからこのコントローラーに来るときに瞬間的にbackが見えてしまう
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
        configureUI()
    }
    
    // MARK: - API
    
    func fetchUsers() {
        refreshControl?.beginRefreshing()
        if userType == "like" {
            guard let opinion = opinion else { return }
            UserService.shared.fetchLikes(opinion: opinion) { (likeUsers, timestamp) in
                self.refreshControl?.endRefreshing()
                self.users = [User]()
                var count = likeUsers.count
                var dictionary = [Int: User]()
                for i in 0 ..< count {
                    let newUser = likeUsers[i]
                    let newTimestamp = timestamp[i]
                    dictionary.updateValue(newUser, forKey: newTimestamp)
                }
                
                for item in dictionary.sorted(by: { $0.key > $1.key }) {
                    self.users.append(item.value)
                }
            }
        } else if userType == "follower" {
            guard let user = user else { return }
            UserService.shared.fetchFollowers(user: user) { (users, timestamp) in
                self.refreshControl?.endRefreshing()
                self.users = [User]()
                var count = users.count
                var dictionary = [Int: User]()
                for i in 0 ..< count {
                    let newUser = users[i]
                    let newTimestamp = timestamp[i]
                    dictionary.updateValue(newUser, forKey: newTimestamp)
                }
                
                for item in dictionary.sorted(by: { $0.key > $1.key }) {
                    self.users.append(item.value)
                }
            }
        } else {
            guard let user = user else { return }
            UserService.shared.fetchFollowing(user: user) { (users, timestamp) in
                self.refreshControl?.endRefreshing()
                self.users = [User]()
                var count = users.count
                var dictionary = [Int: User]()
                for i in 0 ..< count {
                    let newUser = users[i]
                    let newTimestamp = timestamp[i]
                    dictionary.updateValue(newUser, forKey: newTimestamp)
                }
                
                for item in dictionary.sorted(by: { $0.key > $1.key }) {
                    self.users.append(item.value)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        switch userType {
        case "like":
            navigationItem.title = "Likes"
        case "follower":
            navigationItem.title = "Followers"
        case "following":
            navigationItem.title = "Following"
        default:
            navigationItem.title = "Loading"
        }
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .black
        self.navigationItem.backButtonDisplayMode = .minimal
        
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier) //ここのforCellReuseIdentifierの部分が別のidentifierを当てはめるやつになっててクラッシュした
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
    }
}

// MARK: - UITableViewDelegate/DataSource

extension LFFUsersController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.user = user
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
