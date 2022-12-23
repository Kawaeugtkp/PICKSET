//
//  TweetController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit
import Firebase

private let reuseIdentifier = "TweetCell" //これをprivateにしていないと、同じ定数を色々なところで定義しているから狂ってしまう。つまり、同じ定数に対して定義のし直しが何回も起きることになるのでエラーが発生する。
private let headerIdentifier = "TweetHeader"

class TweetController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var opinion: OPs
    private var actionSheetLauncher: ActionSheetLauncher!
    private var replies = [OPs]() {
        didSet { collectionView.reloadData() }
    }
    
    // MARK: - Lifecycle
    
    init(opinion: OPs) {
        self.opinion = opinion
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchReplies()
        checkIfUserliked()
//        configureLeftButton()
        navigationController?.navigationBar.tintColor = .black
//        navigationController?.navigationBar.isHidden 
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false

        navigationController?.setNavigationBarHidden(false, animated: true) 
//        navigationController?.navigationBar.barTintColor = .picksetRed
//        navigationController?.navigationBar.isHidden = true
        //navigationController?.setNavigationBarHidden(false, animated: true) //これがなかったらprofilecontrollerに行ってホームボタンとか押して戻ってきたときにnaigationbarが消えていた
        
            //インストラクターversionは黒文字設定は消していて、navigationController?.navigationBar.isHidden = false ちなみにヘッダーの文字は戻ってきた時には白くなっていて、そこは無視していた
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - API
    
    func fetchReplies() {
        print("DEBUG: Tweet caption is \(opinion.opsID)")
        OPsService.shared.fetchReplies(forTweet: opinion) { replies in
            self.replies = replies
        }
    }
    
    func checkIfUserliked() {
        OPsService.shared.checkIfUserLikedTweet(opinion) { didLike in
//                print("DEBUG: before:\(tweet.caption)")
            guard didLike == true else { return }

            self.opinion.didLike = didLike
            print("DEBUG: This tweet didLike is \(self.opinion.didLike)")
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(TweetHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    fileprivate func showActionSheet(forUser user: User) {
        actionSheetLauncher = ActionSheetLauncher(user: user)
        actionSheetLauncher.delegate = self
        actionSheetLauncher.show()
    }
    
    func alert(title:String,message:String,actiontitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actiontitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func configureLeftButton() {
        let backhorn: UIButton = {
            let barButton = UIButton()
            barButton.tintColor = .black
            barButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
//            barButton.addTarget(self, action: #selector(handleSetting), for: .touchUpInside)
            return barButton
        }()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backhorn)
        
        let settingButton: UIButton = {
            let barButton = UIButton()
            barButton.tintColor = .picksetRed
            barButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
//            barButton.addTarget(self, action: #selector(handleSetting), for: .touchUpInside)
            return barButton
        }()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingButton)
    }
}

// MARK: - UICollectionViewDataSource

extension TweetController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = replies[indexPath.row]
        cell.delegate = self
        cell.postLabel.isHidden = true
        cell.likeImageView.isHidden = true
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TweetController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! TweetHeader
        header.tweet = opinion
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let opinion = replies[indexPath.row]
        let controller = TweetController(opinion: opinion)
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowlayout

extension TweetController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let viewModel = TweetViewModel(tweet: opinion) //こっちにはintializeされているツイートがあるからすぐ使える。feedの方はtweetの配列を扱う箇所だからindexpath.rowのツイートとして指定をしていかないといけない
//        let height = viewModel.size(forwidth: view.frame.width).height
//        print("DEBUG: in conconcon \(viewModel.headerHeight(forwidth: view.frame.width))")
        var height = viewModel.labelHeight(forwidth: view.frame.width - 32, labelFont: 20)
        if opinion.isReply {
            height += 30
        }
        return CGSize(width: view.frame.width, height: height + 320) //こっちheaderだわ。referenceSizeFor"Header"InSectionって書いてあるし
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tweet = replies[indexPath.row]
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
        return CGSize(width: view.frame.width, height: height + 60) //view.frame.widthはviewの横幅、まあスマホの画面の横幅って認識で良いっぽい。で、ここのheightを十分にとらないと、cellの中身がぎゅっと凝縮された感じになってしまって意図した配置にならないのでそこは注意しなければならない
    }
}

// MARK: - TweetHeaderDelegate

extension TweetController: TweetHeaderDelegate {
    func handleReplyLabelTapped() {
        guard let basedOpinionID = opinion.basedOpinionID else { return }
        OPsService.shared.fetchOP(withOPsID: basedOpinionID) { opinion in
            let controller = TweetController(opinion: opinion)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleSelectSetTapped() {
        guard let postID = opinion.postID else { return }
        OPsService.shared.fetchOP(withOPsID: postID) { post in
            guard let selectedSetID = self.opinion.setID else { return }
            SetService.shared.updateSelect(post: post, newSetID: selectedSetID) { (err, ref) in
                guard let uid = Auth.auth().currentUser?.uid else { return }
                UserService.shared.fetchUser(uid: uid) { user in
                    let controller = PostController(post: post, user: user)
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
    func handleLikeLabelTapped() {
        let controller = LFFUsersController(opinion: opinion, userType: "like")
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleProfileImageTapped() {
        let controller = ProfileController(user: opinion.user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleCommentTapped(picked: Bool) {
        if picked {
            guard let postID = opinion.postID else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let setID = opinion.setID else { return }
            OPsService.shared.fetchOP(withOPsID: postID) { post in
                UserService.shared.fetchUser(uid: uid) { user in
                    let controller = UploadTweetController(post: post, user: user, config: .reply(self.opinion), setID: setID)
                    let nav = UINavigationController(rootViewController: controller)
                    self.present(nav, animated: true, completion: nil)
                }
            }
        } else {
            self.alert(title: "セットが選択されていません", message: "コメントやいいねは選択したセットの中でのみ可能です", actiontitle: "OK")
        }
    }
    
    func handleLikeTapped(picked: Bool, header: TweetHeader) {
        guard let opinion = header.tweet else { return }
        if picked {
            guard let postID = opinion.postID else { return }
            OPsService.shared.likeOpinion(opinion: opinion, postID: postID) { err, ref in
                header.tweet?.didLike.toggle()
                let likes = opinion.didLike ? opinion.likes - 1 : opinion.likes + 1
                header.tweet?.likes = likes
            }
        } else {
            self.alert(title: "セットが選択されていません", message: "コメントやいいねは選択したセットの中でのみ可能です", actiontitle: "OK")
        }
    }
    
    func handleSetTapped() {
        guard let postID = opinion.postID else { return }
        guard let opinionSetID = opinion.setID else { return }
        OPsService.shared.fetchOP(withOPsID: postID) { post in
            SetService.shared.fetchSetID(post: post) { setID in
                if opinionSetID != setID {
                    let alert = UIAlertController(title: "このセットを選択しますか？", message: "すでにほかのセットを選択している場合、そのセットにおけるコメントやいいねは全て削除されます", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        SetService.shared.updateSet(post: post, newSetID: opinionSetID) { (err, ref) in
                            self.collectionView.reloadData() //これは相当怪しい
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
    
    func handleeFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func showActionSheet() {
        if opinion.user.isCurrentUser {
            showActionSheet(forUser: opinion.user)
        } else {
            UserService.shared.checkIfUserIsFollowed(uid: opinion.user.uid) { isFollowed in
                var user = self.opinion.user
                user.isFollowed = isFollowed
                self.showActionSheet(forUser: user)
            }
        }
    }
}

// MARK: - ActionSheetLauncherDelegate

extension TweetController: ActionSheetLauncherDelegate {
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .follow(let user):
            UserService.shared.followUser(uid: user.uid) { (err, ref) in
                print("DEBUG: Did follow user \(user.username)")
            }
        case .unfollow(let user):
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                print("DEBUG: Did unfollow user \(user.username)")
            }
        case .report:
            print("DEBUG")
        case .delete:
            print("DEBUG")
        }
    }
}

// MARK: - TweetCellDelegate

extension TweetController: TweetCellDelegate {
    func handleReplyLabelTapped(_ cell: TweetCell) {
        
    }
    
    func handleMarked(_ cell: TweetCell) {
        guard let opsID = cell.tweet?.opsID else { return }
        OPsService.shared.uploadSaves(opsID: opsID) { (err, ref) in
            self.alert(title: "マークリストに追加しました", message: "", actiontitle: "OK")
        }
    }
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        guard let postID = tweet.postID else { return }
        OPsService.shared.fetchOP(withOPsID: postID) { post in
            SetService.shared.fetchSetID(post: post) { setID in
                SetService.shared.checkIfOpinionUserSelectThisSet(post: post, setID: setID, uid: tweet.user.uid) { match in
                    if match {
                        guard let uid = Auth.auth().currentUser?.uid else { return }
                        UserService.shared.fetchUser(uid: uid) { user in
                            let controller = UploadTweetController(post: post, user: user, config: .reply(tweet), setID: setID)
                            let nav = UINavigationController(rootViewController: controller)
                            self.present(nav, animated: true, completion: nil)
                        }
                    } else {
                        self.alert(title: "セットが選択されていません", message: "コメントやいいねは選択したセットの中でのみ可能です", actiontitle: "OK")
                    }
                }
            }
        }
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        guard let opinion = cell.tweet else { return }
        guard let postID = opinion.postID else { return }
        OPsService.shared.fetchOP(withOPsID: postID) { post in
            SetService.shared.fetchSetID(post: post) { setID in
                SetService.shared.checkIfOpinionUserSelectThisSet(post: post, setID: setID, uid: opinion.user.uid) { match in
                    if match {
                        guard let postID = opinion.postID else { return }
                        OPsService.shared.likeOpinion(opinion: opinion, postID: postID) { err, ref in
                            cell.tweet?.didLike.toggle()
                            let likes = opinion.didLike ? opinion.likes - 1 : opinion.likes + 1
                            cell.tweet?.likes = likes
                            cell.likeImageView.isHidden = true
                            cell.postLabel.isHidden = true
                        }
                    } else {
                        self.alert(title: "セットが選択されていません", message: "コメントやいいねは選択したセットの中でのみ可能です", actiontitle: "OK")
                    }
                }
            }
        }
    }
    
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handlePostLabelTapped(_ cell: TweetCell) {
        
    }
}
