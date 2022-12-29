//
//  FeedController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit
import SDWebImage
import GoogleMobileAds

private let reuseIdentifier = "TweetCell"

class FeedController: UICollectionViewController {
    
    //MARK: - Properties
    
    
    private var tweets = [OPs]() {
        didSet { collectionView.reloadData() } //この文を追加することで、ちゃんと欲しいツイート一覧がtweetsに格納されてから、後の処理が走るようになる。もしこの文がなかったら、例えばnumberOfItemsInSectionのツイートの数を返す関数なんかは、viewを読み込んだ瞬間のtweetsの数を返したりする。それはもちろん0だから所望の値が得られないよ。細かいことをいうと、viewを読み込んだ瞬間はtweetsの数は0でその後にtweetsの正しい数が得られるよね。その状態でもう一回reloadしたらtweetsには正確な値が入っているからここでちゃんと所望の値が得られる
    }
    
    var user: User? {
        didSet {
            configureLeftButton() //何でviewdidloadの後に置かないでdidSet内で呼ぶかというと、userをdatabaseから引っ張ってこれないでurl検索して画像取ろうと思っても当然取れないわけで、大前提としてurl含むuserの情報を取得しないといけないから
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
        
//        collectionView.reloadData() あんま変わらん
//        navigationController?.navigationBar.isHidden = true
//        navigationController?.setNavigationBarHidden(false, animated: true) //これがなかったらprofilecontrollerに行ってホームボタンとか押して戻ってきたときにnaigationbarが消えていた
        
            //インストラクターversionは黒文字設定は消していて、navigationController?.navigationBar.isHidden = false ちなみにヘッダーの文字は戻ってきた時には白くなっていて、そこは無視していた
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweets()
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButton
    }
    
    // MARK: - Selectors
    
    @objc func handleRefresh() {
        fetchTweets()
    }
    
    @objc func handleProfileImageTap() {
        guard let user = user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleSetting() {
//        let controller = TopController(collectionViewLayout: UICollectionViewFlowLayout())
//        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - API
    
    func fetchTweets() {
        collectionView.refreshControl?.beginRefreshing()
        OPsService.shared.fetchTweets { tweets in
            self.collectionView.refreshControl?.endRefreshing()

            
            self.tweets = tweets.sorted(by: { tweet1, tweet2 in
                return tweet1.timestamp > tweet2.timestamp
            })
//            self.checkIfUserLikedTweet()  //上のコメントアウトしたコードでやると、ソートしたことによって元々likeされてるツイートがあった場所に並べ替えられて関係ないものが来るっていう現象が起きてライクの意味がなくなっているのでそこを修正しているのが今書かれているコード
        }
    }
    
    func checkIfUserLikedTweet() {
        //        for (index, tweet) in tweets.enumerated() {
        //            TweetService.shared.checkIfUserLikedTweet(tweet) { didLike in
        //                print("DEBUG: \(didLike)")
        //                print("DEBUG: \(index)")
        //                print("DEBUG: before:\(self.tweets[index].caption)")
        //                guard didLike == true else { return }
        //
        //                self.tweets[index].didLike = true
        //                print("DEBUG: \(self.tweets[index].caption)")
        //            }
        self.tweets.forEach { tweet in
//            s += 1
//            print("DEBUG: \(s)")
            OPsService.shared.checkIfUserLikedTweet(tweet) { didLike in
//                print("DEBUG: before:\(tweet.caption)")
                guard didLike == true else { return }

                if let index = self.tweets.firstIndex(where: { $0.opsID == tweet.opsID }) {
                    self.tweets[index].didLike = true
                }
            }
        }
    }
    
    func checkIfOpinions() {
        self.tweets.forEach { tweet in
            OPsService.shared.checkIfOpinions(tweet) { opinionOrNot in
                guard opinionOrNot == true else { return }
                
                if let index = self.tweets.firstIndex(where: { $0.opsID == tweet.opsID }) {
                    self.tweets[index].opinionOrNot = true
                }
            }
        }
    }
    
    //MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        collectionView.backgroundColor = .white //これいらない説ある
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let imageView = UIImageView(image: UIImage(named: "grobal"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44) //なぜかこれで中心になる。これがないと、左にあるプロフの画像のせいで少し右にTwitterマークがずれてしまう
        navigationItem.titleView = imageView
        
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        
        let settingButton: UIButton = {
            let barButton = UIButton()
            barButton.tintColor = .picksetRed
            barButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
            barButton.addTarget(self, action: #selector(handleSetting), for: .touchUpInside)
            return barButton
        }()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingButton)
    }
    
    func alert(title:String,message:String,actiontitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actiontitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate/DataSource

extension FeedController { 
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        cell.likeButton.tintColor = .lightGray
        cell.commentButton.isHidden = true
//        cell.underBlankView.isHidden = true
        cell.delegate = self //ここで無事にfeedcontrollerに引き継がれた
        cell.likeButton.isHidden = true
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tweet = tweets[indexPath.row]
        if tweet.type == .post {
            guard let user = user else { return }
            let controller = PostController(post: tweet, user: user)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = TweetController(opinion: tweet)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout { //UICollectionViewDelegateFlowLayoutはアイテムのサイズやアイテム間の間隔を決める
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tweet = tweets[indexPath.row]
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
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0) //おそらく、cellがいっぱい並んだviewのことをcollectionviewと言っているから、そのエッジにこういう書き方で空白を設定できる
        return CGSize(width: view.frame.width, height: height + 60) //view.frame.widthはviewの横幅、まあスマホの画面の横幅って認識で良いっぽい。で、ここのheightを十分にとらないと、cellの中身がぎゅっと凝縮された感じになってしまって意図した配置にならないのでそこは注意しなければならない
    }
}

// MARK: - TweetCellDelegate

extension FeedController: TweetCellDelegate {
    func handleReplyLabelTapped(_ cell: TweetCell) {
        guard let basedOpinionID = cell.tweet?.basedOpinionID else { return }
        print("DEBUG: gbgrfggbbbb")
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

//extension FeedController: GADNativeAdLoaderDelegate {
//    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
//        <#code#>
//    }
//    
//    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
//        <#code#>
//    }
//}
