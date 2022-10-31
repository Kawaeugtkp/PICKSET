//
//  ProfileController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit
import SwiftUI
import Firebase

private let reuseIdentifier = "TweetCell"
private let headerIdentifier = "ProfileHeader"

class ProfileController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var user: User
    
    private var selectedFilter: ProfileFilteroptions = .posts {
        didSet{ collectionView.reloadData() } //これは、フィルターが新しくなる度に読み直ししないとフィルター切り替えてもあれなにも変わってなくね？ってなってしまう
    }
    
    private var posts = [OPs]()
//    {
//        didSet { collectionView.reloadData() } //この文を追加することで、ちゃんと欲しいツイート一覧がtweetsに格納されてから、後の処理が走るようになる。もしこの文がなかったら、例えばnumberOfItemsInSectionのツイートの数を返す関数なんかは、viewを読み込んだ瞬間のtweetsの数を返したりする。それはもちろん0だから所望の値が得られないよ。細かいことをいうと、viewを読み込んだ瞬間はtweetsの数は0でその後にtweetsの正しい数が得られるよね。その状態でもう一回reloadしたらtweetsには正確な値が入っているからここでちゃんと所望の値が得られる
//    }
    
    private var likedTweets = [OPs]()
    private var opinions = [OPs]()
    
    private var currentDataSource: [OPs] {
        switch selectedFilter {
            
        case .posts:
            return posts
        case .opinions:
            return opinions
        case .likes:
            return likedTweets
        }
    }
    
    // MARK: - Lifecycle
    
    init(user: User) {
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
        checkIfUserIsFollowed()
        configureCollectionView()
        fetchposts()
        fetchLikedTweets()
        fetchopinions()
        fetchUserStats()
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - API
    
    func fetchposts() {
        OPsService.shared.fetchPosts(forUser: user) { posts in
            self.posts = posts
            self.collectionView.reloadData() //これいるかいまいちわからなかった。一旦なくても機能していたっぽい
        }
    }
    
    func fetchLikedTweets() {
        OPsService.shared.fetchLikes(forUse: user) { opinions in
            self.likedTweets = opinions //この後にreloaddataをする必要はない。なぜなら、この配列が表示されるのはlikesがタップされた後であり、その時点から配列を取ってきてっていう処理を開始するから。
        }
    }
    
    func fetchopinions() {
        OPsService.shared.fetchOpinions(forUser: user) { opinions in
            self.opinions = opinions
        }
    }
    
    func checkIfUserIsFollowed() { //これはボタン押し手とかではなくて普通にprofilecontrollerに来たときに表示する用
        UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never //safeareaをどうするかというもので、neverにしているからheaderの時刻とかの部分もしっかり背景色に染められているということだと思う
        navigationController?.navigationBar.isTranslucent = true
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset.bottom = tabHeight
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
}

// MARK: - UICollectionViewDataSource

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = currentDataSource[indexPath.row]
        cell.commentButton.isHidden = true
        cell.likeButton.isHidden = true
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ops = currentDataSource[indexPath.row]
        if ops.type == .post {
            let controller = PostController(post: ops, user: user)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = TweetController(opinion: ops)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout { //UICollectionViewDelegateFlowLayoutはアイテムのサイズやアイテム間の間隔を決める
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
//        let viewModel = ProfileHeaderViewModel(user: user)
//        var height = viewModel.size(forwidth: view.frame.width).height
        
        let height: CGFloat = 350
    
        return CGSize(width: view.frame.width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tweet = currentDataSource[indexPath.row]
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
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0) //機能していない。わかっている範囲ではこことprofile
        return CGSize(width: view.frame.width, height: height + 60) //view.frame.widthはviewの横幅、まあスマホの画面の横幅って認識で良いっぽい。で、ここのheightを十分にとらないと、cellの中身がぎゅっと凝縮された感じになってしまって意図した配置にならないのでそこは注意しなければならない
    }}

// MARK: - ProfileHeaderDelegate

extension ProfileController: ProfileHeaderDelegate {
    func handleFollowersTapped() {
        let controller = LFFUsersController(user: user, userType: "follower")
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleFollowingTapped() {
        let controller = LFFUsersController(user: user, userType: "following")
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didSelect(filter: ProfileFilteroptions) {
        self.selectedFilter = filter
    }
    
    func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
    
    func handleEditProfileFollow(_ header: ProfileHeader) {
        
        print("DEBUG: follow tapped")
        
        if user.isCurrentUser {
            let controller = EditProfileController(user: user)
            controller.delegate = self //ここに置くのは、今のところeditprofileに行くには必ずここを経由するから？つまり、仮にもしprofileを経由しないでeditにいけてしまったら機能しない説ある。その方法を俺が作らなければいい話だけど。
            let nav = UINavigationController(rootViewController: controller)
//            let nav1 = templateNavigationController(viewController: nav)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
            return
        }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                print("DEBUG: Did unfollow user in backend..")
                self.user.isFollowed = false
//                header.editProfileFollowButton.setTitle("Follow", for: .normal) //これで足りないのは多分ボタンを押された時にしか呼び出されないから。だから、結局どっか別のcontrollerに行って戻ってきたらfollowかedit profileになってしまっている
                self.collectionView.reloadData()
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { (ref, err) in
                print("DEBUG: Did complete follow in backend..")
                self.user.isFollowed = true
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - EditProfileControllerDelegate

extension ProfileController: EditProfileControllerDelegate {
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            let nav = UINavigationController(rootViewController: LoginController())
            nav.modalPresentationStyle = .fullScreen //このコードのおかげでログイン画面が下に下げられなくなる。つまりフルスクリーンで表示される
            self.present(nav, animated: true, completion: nil)
        } catch let error {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func controller(_ controller: EditProfileController, wantsToUpdate user: User) {
        controller.dismiss(animated: true, completion: nil)
        self.user = user //ここでまずupdateしたユーザーがeditprofileからprofileに渡されている
        self.collectionView.reloadData() //そしてここで読み直し
    }
}
