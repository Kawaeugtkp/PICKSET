//
//  SaveController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/10/22.
//

import UIKit

private let reuseIdentifier = "TweetCell"

class SaveController: UICollectionViewController {
    // MARK: - Properties
    
    private var ops = [OPs]() {
        didSet { collectionView.reloadData() }
    }
    
    var user: User? {
        didSet {
            configureLeftButton()
            collectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchSaves()
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButton
    }
    
    // MARK: - Selectors
    
    @objc func handleRefresh() {
        fetchSaves()
    }
    
    @objc func handleProfileImageTap() {
        guard let user = user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - API
    
    func fetchSaves() {
        collectionView.refreshControl?.beginRefreshing()
        OPsService.shared.fetchSaves { (ops, timestamp) in
            self.collectionView.refreshControl?.endRefreshing()
            self.ops = [OPs]()
//            self.ops = ops
            var count = ops.count
            var dictionary = [Int: OPs]()
            for i in 0 ..< count {
                let newOp = ops[i]
                let newTimestamp = timestamp[i]
                dictionary.updateValue(newOp, forKey: newTimestamp)
            }
            
            for item in dictionary.sorted(by: { $0.key > $1.key }) {
                self.ops.append(item.value)
            }
//            self.ops = ops.sorted(by: { tweet1, tweet2 in
//                return tweet1.timestamp > tweet2.timestamp
//            })
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "マークリスト"
        
        collectionView.backgroundColor = .white //これいらない説ある
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    func configureLeftButton() {
        guard let user = user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.backgroundColor = .picksetRed
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        profileImageView.addGestureRecognizer(tap)
        profileImageView.isUserInteractionEnabled = true //これがdefaultでfalseでその時はタップとかも機能しないのでtrueにしないといけない
        
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        profileImageView.sizeToFit()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    
    func alert(title:String,message:String,actiontitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actiontitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate/DataSource

extension SaveController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ops.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = ops[indexPath.row]
        cell.likeButton.tintColor = .lightGray
        cell.commentButton.isHidden = true
        cell.delegate = self //ここで無事にfeedcontrollerに引き継がれた
        cell.likeButton.isHidden = true
        cell.markButton.isHidden = true
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let op = ops[indexPath.row]
        if op.type == .post {
            guard let user = user else { return }
            let controller = PostController(post: op, user: user)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = TweetController(opinion: op)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SaveController: UICollectionViewDelegateFlowLayout { //UICollectionViewDelegateFlowLayoutはアイテムのサイズやアイテム間の間隔を決める
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tweet = ops[indexPath.row]
        let viewModel = TweetViewModel(tweet: tweet)
        var height: CGFloat
        if tweet.opinionOrNot {
            height = max(30, viewModel.labelHeight(forwidth: view.frame.width - 84, labelFont: 14))
        } else {
            height = max(30, viewModel.labelHeight(forwidth: view.frame.width - 84, labelFont: 16))
        }
        if tweet.isReply {
            height += 20
        }
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        return CGSize(width: view.frame.width, height: height + 60) //view.frame.widthはviewの横幅、まあスマホの画面の横幅って認識で良いっぽい。で、ここのheightを十分にとらないと、cellの中身がぎゅっと凝縮された感じになってしまって意図した配置にならないのでそこは注意しなければならない
    }
}

// MARK: - TweetCellDelegate

extension SaveController: TweetCellDelegate {
    func handleReplyLabelTapped(_ cell: TweetCell) {
        guard let basedOpinionID = cell.tweet?.basedOpinionID else { return }
        OPsService.shared.fetchOP(withOPsID: basedOpinionID) { opinion in
            let controller = TweetController(opinion: opinion)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleMarked(_ cell: TweetCell) {
        guard let opsID = cell.tweet?.opsID else { return }
        OPsService.shared.uploadSaves(opsID: opsID) { (err, ref) in
            self.alert(title: "マークリストに追加しました", message: "", actiontitle: "OK")
        }
    }
    
    func handlePostLabelTapped(_ cell: TweetCell) {
        guard let postID = cell.tweet?.postID else { return }
        guard let user = cell.tweet?.user else { return }
        OPsService.shared.fetchOP(withOPsID: postID) { post in
            let controller = PostController(post: post, user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleLikeTapped(_ cell: TweetCell) {

    }
    
    func handleReplyTapped(_ cell: TweetCell) {

    }
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user) //ここをUICollectionViewLayout()にしていたら全然cellがprofilecontrollerで出てこなかった。ほんとに注意。UICollectionViewFlowLayoutにしないと具体的なビューの設定が反映されないからセルの表示のしようがない。
        navigationController?.pushViewController(controller, animated: true)
    }
}
