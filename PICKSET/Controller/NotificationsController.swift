//
//  NotificationsController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit

//セルをタップした後にそのページにいけるリンクがいる

private let reuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {
    
    //MARK: - Properties
    
    private var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Selectors
    
    @objc func handleRefresh() {
        fetchNotifications()
    }
    
    // MARK: - API
    
    func fetchNotifications() {
        refreshControl?.beginRefreshing()
        NotificationService.shared.fetchNotifications { notifications in
            self.refreshControl?.endRefreshing()
            self.notifications = notifications.sorted(by: { notification1, notification2 in
                return notification1.timestamp > notification2.timestamp
            })
            self.checkIfUserIsFollowed(notifications: notifications)
        }
    }
    
    func checkIfUserIsFollowed(notifications: [Notification]) {
        guard !notifications.isEmpty else { return }
        
        notifications.forEach { notification in
            guard case .follow = notification.type else { return }
            let user = notification.user
            
            UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
                if let index = self.notifications.firstIndex(where: { $0.user.uid == notification.user.uid }) {
                    self.notifications[index].user.isFollowed = isFollowed
                }
            }
        }
    }
    
    //MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "通知"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
}

// MARK: - UITableViewDataSource

extension NotificationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotificationsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notification = notifications[indexPath.row]
//        guard let tweetID = notification.tweetID else { return }
        
//        OPsService.shared.fetchOP(withOPsID: tweetID) { tweet in
//            let controller = TweetController(opinion: tweet)
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
        
        if let opsID = notification.tweetID {
            OPsService.shared.fetchOP(withOPsID: opsID) { tweet in
                let controller = TweetController(opinion: tweet)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            UserService.shared.fetchUser(uid: notification.user.uid) { user in
                let controller = ProfileController(user: user)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

// MARK: - NotificationCellDelegate

extension NotificationsController: NotificationCellDelegate {
    func didTapFollow(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
                
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                cell.notification?.user.isFollowed = false
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { (err, ref) in
                cell.notification?.user.isFollowed = true
            }
        }
    }
    
    func handleProfileImageTapped(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }

        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
