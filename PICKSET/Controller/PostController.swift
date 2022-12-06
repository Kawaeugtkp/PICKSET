//
//  PostController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/11.
//

import Firebase
import UIKit

private let headerIdentifier = "PostHeader"
private let setCellReuseIdentifier = "SetCell"
private let tweetCellReuseIdentifier = "TweetCell"
private let reuseIdentifier = "OpinionCell"

class PostController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var opinions = [OPs]() {
        didSet {
            print("DEBUG: Good morning")
            collectionView.reloadData()
            if !opinions.isEmpty {
                recommendLabel.isHidden = true
            }
        }
    }
    
    private let user: User
    
    private var post: OPs
    
//    private var match = false
//    private var selectSetID: String?
    
    private let recommendLabel: UILabel = {
        let label = UILabel()
        label.text = "意見を追加してみましょう"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    // MARK: - Lifecycle
    
    init(post: OPs, user: User) {
        self.post = post
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
 //インストラクターの人のcomplete版でも通常時から白くなっていてこの設定が効いているように見えたから何が正しいかよくわからない
        navigationController?.navigationBar.isHidden = true
        //navigationController?.setNavigationBarHidden(true, animated: true) //これがviewwillappearでなければいけない理由がいまいちわからない。viewdidloadでもしっかり消えていた。
        
        //インストラクターversionはnavigationController?.navigationbar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchOpinions()
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .black
//        navigationController?.navigationBar.isHidden
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - API
    
    func fetchVotes() {
        SetService.shared.fetchVotes(post: post) { votes in
            self.post.vote = votes
            self.checkIfUserLikedTweet()
            self.collectionView.reloadData()
        }
    }
    
    func fetchOpinions() {
        SetService.shared.fetchSelectedSetID(post: post) { setID in
            OPsService.shared.fetchOpinions(setID: setID) { opinions in
                self.opinions = opinions.sorted(by: {opinion1, opinion2 in
                    return opinion1.likes > opinion2.likes
                })
                self.checkIfUserLikedTweet()
            }
        }
    }
    
    func checkIfUserLikedTweet() {
        self.opinions.forEach { opinion in
            OPsService.shared.checkIfUserLikedTweet(opinion) { didLike in
                guard didLike == true else { return }

                if let index = self.opinions.firstIndex(where: { $0.opsID == opinion.opsID }) {
                    self.opinions[index].didLike = true
//                    if self.match {
//                        self.opinions[index].didLike = true
//                    } else {
//                        self.opinions[index].didLike = false
//                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        collectionView.backgroundColor = .white
//        view.addSubview(recommendLabel)
//        recommendLabel.centerX(inView: view)
//        recommendLabel.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 100)
        collectionView.contentInsetAdjustmentBehavior = .never
        navigationController?.navigationBar.isTranslucent = true
        collectionView.register(PostHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        let selectedIndexPath = IndexPath(row: 0, section: 0)
//        FilterBar.selectItem(at: selectedIndexPath, animated: true, scrollPosition: .left)
    }
    

    
    func templateNavigationController(viewController:UIViewController) -> UINavigationController {

    let nav = UINavigationController(rootViewController: viewController)


    let appearance = UINavigationBarAppearance()

    appearance.configureWithOpaqueBackground()

    appearance.backgroundColor = .white

    nav.navigationBar.standardAppearance = appearance;

    nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance



    return nav

    }
    
    func alert(title:String,message:String,actiontitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actiontitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension PostController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return opinions.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = opinions[indexPath.row]
        cell.delegate = self
        cell.postLabel.isHidden = true
        cell.likeImageView.isHidden = true
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension PostController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! PostHeader
        header.delegate = self
        header.post = post
        header.filterBar.post = post
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let opinion = opinions[indexPath.row]
        let controller = TweetController(opinion: opinion)
        navigationController?.pushViewController(controller, animated: true)
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PostController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let viewModel = PostHeaderViewModel(post: post)
        let height: CGFloat = viewModel.size(forwidth: view.frame.width).height + 350
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tweet = opinions[indexPath.row]
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

// MARK: - PostHeaderDelegate

extension PostController: PostHeaderDelegate {
    func handleShowDescription(_ header: PostHeader) {
        guard let post = header.post else { return }
        let controller = DetailController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleUsernameTapped(_ header: PostHeader) {
        guard let user = header.post?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func selectSet(_ cell: SetCell) {
        guard let setID = cell.set?.setID else { return }
        guard let set = cell.set else { return }
//        match = false
//        selectSetID = setID
//        if selectSetID == pickSetID {
//            match = true
//        }
        SetService.shared.updateSelect(post: post, newSetID: setID) { (err, ref) in
            print("DEBUG: REF_POST_SELECTED update")
//            cell.set?.didSelect = true
//            self.collectionView.reloadData()
            OPsService.shared.fetchOpinions(setID: setID) { opinions in
                self.opinions = opinions.sorted(by: {opinion1, opinion2 in
                    return opinion1.likes > opinion2.likes
                })
                self.checkIfUserLikedTweet()
            }
        }
    }
    
    func handleMessageTapped(_ cell: SetCell) {
        guard let set = cell.set else { return }
        SetService.shared.fetchSetID(post: post) { setID in
            if set.setID == setID {
                let controller = UploadTweetController(post: self.post, user: self.user, config: .tweet, setID: setID)
                let nav = UINavigationController(rootViewController: controller)
                self.present(nav, animated: true, completion: nil)
            } else {
                self.alert(title: "セットが選択されていません", message: "コメントやいいねは選択したセットの中でのみ可能です", actiontitle: "OK")
            }
        }
    }
    
    func picksetTapped(_ cell: SetCell) {
        guard let set = cell.set else { return }
        SetService.shared.fetchSetID(post: post) { setID in
            if set.setID != setID {
                let alert = UIAlertController(title: "このセットを選択しますか？", message: "すでにほかのセットを選択している場合、そのセットにおけるコメントやいいねは全て削除されます", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    guard let set = cell.set else { return }
                    print("DEBUG: This is called")
                    self.selectSet(cell)
                    SetService.shared.updateSet(post: self.post, newSetID: set.setID) { (err, ref) in
//                        cell.set?.didPick = true
        //                self.fetchVotes()
//                        self.collectionView.reloadData() //これは相当怪しい //一応セットのチカチカを抑えるためにここは全部コメントアウトしているが、もしかしたら後で不都合が生じるかも
//                        self.fetchOpinions()
                    }
                }))
                alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func handleAddSet() {
        let controller = SetController(post: post)
        
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
    
    func handleDismissal() {
        navigationController?.popViewController(animated: true) //これ今のところ機能していないけど、おそらくどういうふうにviewcontrollerを重ねているのかの違いだから一旦待ち。多分だけど、これがpushuviewcontrollerを使った経由でこのviewcontroller出すやつだったらこれでいいはず。多分こっからそれにするつもりだから待ちでいいはず。
    }
}

// MARK: - TweetCellDelegate

extension PostController: TweetCellDelegate {
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
        SetService.shared.fetchSetID(post: post) { setID in
            SetService.shared.checkIfOpinionUserSelectThisSet(post: self.post, setID: setID, uid: tweet.user.uid) { match in
                if match {
                    let controller = UploadTweetController(post: self.post, user: self.user, config: .reply(tweet), setID: setID)
                    let nav = UINavigationController(rootViewController: controller)
                    self.present(nav, animated: true, completion: nil)
                } else {
                    self.alert(title: "セットが選択されていません", message: "コメントやいいねは選択したセットの中でのみ可能です", actiontitle: "OK")
                }
            }
        }
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        SetService.shared.fetchSetID(post: post) { setID in
            SetService.shared.checkIfOpinionUserSelectThisSet(post: self.post, setID: setID, uid: tweet.user.uid) { match in
                if match {
                    guard let uid = Auth.auth().currentUser?.uid else { return }

                    OPsService.shared.fetchOpinion(withOpinionID: tweet.opsID) { opinion in
//                        print("DEBUG: didlike is \(cell.tweet?.didLike)")
                        cell.tweet?.didLike.toggle()
                        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
                        cell.tweet?.likes = likes
                        
                        REF_OPS.child(opinion.opsID).child("likes").setValue(likes)
                        
                        guard let postID = opinion.postID else { return }
                        
                        if uid == tweet.user.uid {
                            if tweet.didLike {
                                REF_USER_LIKES.child(uid).child(opinion.opsID).removeValue { (err, ref) in
                                    REF_USER_POSTLIKES.child(uid).child(postID).child(opinion.opsID).removeValue()
                                }
                            } else {
                                REF_USER_LIKES.child(uid).updateChildValues([opinion.opsID: 1]) { (err, ref) in
                                    REF_USER_POSTLIKES.child(uid).child(postID).updateChildValues([opinion.opsID: 1])
                                }
                            }
                        } else {
                            if tweet.didLike {
                                // unlike opinion
                                REF_USER_LIKES.child(uid).child(opinion.opsID).observeSingleEvent(of: .value) { snapshot in
                                    guard let notificationID = snapshot.value as? String else { return }
                                    NotificationService.shared.removeNotification(toUser: tweet.user, notificationID: notificationID) { (err, ref) in
                                        REF_USER_LIKES.child(uid).child(opinion.opsID).removeValue { (err, ref) in
                                            REF_USER_POSTLIKES.child(uid).child(postID).child(opinion.opsID).removeValue { (err, ref) in
                                                REF_OPINION_LIKES.child(opinion.opsID).child(uid).removeValue()
                                            }
                                        }
                                    }
                                }
                            } else {
                                // like opinion
                                NotificationService.shared.UploadNotification(type: .like, toUser: tweet.user, tweetID: tweet.opsID) { notificationID in
                                    REF_USER_LIKES.child(uid).updateChildValues([opinion.opsID: notificationID]) { (err, ref) in
                                        REF_USER_POSTLIKES.child(uid).child(postID).updateChildValues([opinion.opsID: 1]) { (err, ref) in
                                            REF_OPINION_LIKES.child(opinion.opsID).updateChildValues([uid: Int(NSDate().timeIntervalSince1970)])
                                        }
                                    }
                                }
                            }
                        }
                        
                        cell.likeImageView.isHidden = true
                        cell.postLabel.isHidden = true
                                            
//                        // only upload notification if tweetis being liked
//                        guard !tweet.didLike else { return }
//                        NotificationService.shared.UploadNotification(type: .like, toUser: tweet.user, tweetID: tweet.opsID) { notificationID in
//                            REF_USER_LIKES.child(uid).child(opinion.opsID).setValue(notificationID)
//                        }
                    }
                } else {
                    self.alert(title: "セットが選択されていません", message: "コメントやいいねは選択したセットの中でのみ可能です", actiontitle: "OK")
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
