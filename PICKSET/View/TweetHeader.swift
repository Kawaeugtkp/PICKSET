//
//  TweetHeader.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit
import ActiveLabel
import Firebase

protocol TweetHeaderDelegate: class {
    func showActionSheet()
    func handleeFetchUser(withUsername username: String)
    func handleDismissal()
    func handleCommentTapped(picked: Bool)
    func handleLikeTapped(picked: Bool, header: TweetHeader)
    func handleSetTapped()
    func handleLikeLabelTapped()
    func handleProfileImageTapped()
    func handleSelectSetTapped()
    func handleReplyLabelTapped()
}

class TweetHeader: UICollectionReusableView { //よくわからないがheaderにはUICollectionReusableViewをつけるらしい
    
    // MARK: - Properties
    
    var tweet: OPs? {
        didSet {
            fetchSet()
            checkIfPicked()
        }
    }
    
    var onSet: Sets? {
        didSet { configure() }
    }
    //fetchsetでtweetが存在するセットを持ってこようとしたけど、まだsetIDをvalueにもつtweetを一個も作成できていなかったので何も情報を取ってこれていなかった。だから、configureを実行するときにtweetをセットできていなくてデフォルトの値が入ってしまっていた
    
    var alreadyPicked = false
    
    weak var delegate: TweetHeaderDelegate?
    
    private lazy var setView: UIView = {
        let view = UIView()
        view.backgroundColor = .picksetRed
        
//        view.addSubview(backButton)
//        backButton.centerY(inView: view)
//        backButton.anchor(left: view.leftAnchor, paddingLeft: 16)
//        backButton.setDimensions(width: 30, height: 30)
        
        view.addSubview(pickButton)
        pickButton.anchor(right: view.rightAnchor, paddingRight: 10)
        pickButton.centerY(inView: view)
        pickButton.setDimensions(width: 30, height: 30)
        
        view.addSubview(setLabel)
        setLabel.centerY(inView: view)
        setLabel.anchor(left: view.leftAnchor, right: pickButton.leftAnchor, paddingLeft: 20, paddingRight: 8)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSelectSetTapped))
        
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    private let setLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var pickButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleSetTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.backward")
        button.setImage(image, for: .normal) //image?.withRenderingMode(.alwaysOriginal)にしていると、tintcolorの変更が効かなかった。今のところこの文を無くしたことによる不具合が発生していないので一旦放置
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var profileIMageView: UIImageView = { //ここもtapを加えるまではletだったけどlazy varにしないといけなくなった。ボタン系のアクションがしたかったらlazy varにしないといけないっぽい
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill //ちなみにこれがfeedcotrollerの左下のボタンのとこには設定されていなくて、実際このコードなしでもなんか違和感なさそう（ズームしたらわからんけど）なので、必要性は不明
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48 / 2
        iv.backgroundColor = .picksetRed
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true //これをfalseにするとボタン的な動作が完全になくなった
        
        return iv
    }()
    
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
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.mentionColor = .picksetRed
        label.hashtagColor = .picksetRed
        label.numberOfLines = 0 //インストラクターが喋っている感じだと、表示されるラベルのテキストが何行になるかを設定するものらしい。0にすることによって制限がなくなるみたい
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var optionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(UIImage(named: "down_arrow_24pt"), for: .normal)
        button.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        return button
    }()
    
    private lazy var replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.mentionColor = .picksetRed
        label.handleMentionTap { replyTo in
            self.handleReplyLabelTapped()
        }
        return label
    }()
    private lazy var likesLabel: UILabel = {
        let label = UILabel()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLikeLabelTapped))
        
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var statsView: UIView = {
        let view = UIView()
        
        let divider1 = UIView()
        divider1.backgroundColor = .systemGroupedBackground
        view.addSubview(divider1)
        divider1.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 8, height: 1.0)

        view.addSubview(likesLabel)
        likesLabel.centerY(inView: view)
        likesLabel.anchor(left: view.leftAnchor, paddingLeft: 16) //ここのview.leftanchorでview.の表記を忘れていた
        
        let divider2 = UIView()
        divider2.backgroundColor = .systemGroupedBackground
        view.addSubview(divider2)
        divider2.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, height: 1.0)
        
        return view
    }()
    
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "comment")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like")
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    private let headerDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        return view
    }()
    
//    private lazy var shareButton: UIButton = {
//        let button = createButton(withImageName: "share")
//        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
//        return button
//    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(setView)
        setView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 80)
        
        let labelStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        labelStack.axis = .vertical
        labelStack.spacing = -6 //これが非負の値の時はusernameが下側に固定されていてそこからfullnameをどんだけ離すかみたいな値の扱いだったけど、マイナスにするとfullnameが上側に固定されていてそこからusernameをどれだけ離すかみたいな扱いになっていた
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileIMageView, labelStack])
        imageCaptionStack.spacing = 12 //axisはdefaultがhorizontalらしいから明記しなくてもいいらしい
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.anchor(top: setView.bottomAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        addSubview(optionButton)
        optionButton.centerY(inView: stack) //これで、Y軸の中心をstackと同じにしている
        optionButton.anchor(right: rightAnchor, paddingRight: 8)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: stack.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 16, paddingRight: 16)
        
        addSubview(postImageView)
        postImageView.centerX(inView: self)
        postImageView.anchor(top: captionLabel.bottomAnchor, paddingTop: 10)
        
        postImageView.isHidden = true
        
        addSubview(headerDivider)
        headerDivider.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingBottom: 5, height: 2.0)
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton, likeButton])
        actionStack.spacing = 72
        
        addSubview(actionStack)
        actionStack.centerX(inView: self)
        actionStack.anchor(bottom: headerDivider.topAnchor, paddingBottom: 10)
        
        addSubview(statsView)
        statsView.anchor(left: leftAnchor,bottom: actionStack.topAnchor, right: rightAnchor, paddingBottom: 16, height: 40)
        
        addSubview(dateLabel)
        dateLabel.anchor(left: leftAnchor, bottom: statsView.topAnchor, paddingLeft: 16, paddingBottom: 12)
        
//        addSubview(dateLabel)
//        dateLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, paddingTop: 20, paddingLeft: 16)

//        addSubview(statsView)
//        statsView.anchor(top: dateLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, height: 40) //ここでしっかりviewの高さを設定しないといけない
//
//        let actionStack = UIStackView(arrangedSubviews: [commentButton, likeButton])
//        actionStack.spacing = 72
//
//        addSubview(actionStack)
//        actionStack.centerX(inView: self)
//        actionStack.anchor(top: statsView.bottomAnchor, paddingTop: 16)
//
//        addSubview(headerDivider)
//        headerDivider.anchor(top: actionStack.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 10, height: 2.0)
        
        //あくまで個人的な意見だけど、anchorを設定する時は変動するものを基準にして上下に設定すべきだと思う。今回ならcaptionlabelが変動するものだからそれを基準に上と下に分けてanchor設定すべき
        
        configureMentionHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API
    
    func fetchSet() {
        guard let postID = tweet?.postID else { return }
        guard let setID = tweet?.setID else { return }
        OPsService.shared.fetchOP(withOPsID: postID) { post in
            SetService.shared.fetchSet(post: post, setID: setID) { onSet in
                self.onSet = onSet
            }
        }
    }
    
    func checkIfPicked() {
        guard let postID = tweet?.postID else { return }
        guard let setID = tweet?.setID else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        OPsService.shared.fetchOP(withOPsID: postID) { post in
            SetService.shared.checkIfOpinionUserSelectThisSet(post: post, setID: setID, uid: uid) { picked in
                if picked {
                    self.alreadyPicked = picked
                    self.pickButton.tintColor = .black
                }
            }
        }
    }
    
//    func checkIfUserliked() {
//        guard let tweet = tweet else { return }
//        OPsService.shared.checkIfUserLikedTweet(tweet) { didLike in
////                print("DEBUG: before:\(tweet.caption)")
//            guard didLike == true else { return }
//
//            self.tweet.didLike = didLike
//            print("DEBUG: This tweet didLike is \(self.tweet.didLike)")
//        }
//    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        delegate?.handleDismissal()
    }
    
    @objc func handleLikeLabelTapped() {
        delegate?.handleLikeLabelTapped()
    }
    
    @objc func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped()
    }
    
    @objc func showActionSheet() {
        delegate?.showActionSheet()
    }
    
    @objc func handleCommentTapped() {
        print("DEBUG: reply tapped")
        delegate?.handleCommentTapped(picked: alreadyPicked)
    }
    
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(picked: alreadyPicked, header: self)
    }
    
    @objc func handleSetTapped() {
        if !alreadyPicked {
            delegate?.handleSetTapped()
        }
    }
    
    @objc func handleSelectSetTapped() {
        delegate?.handleSelectSetTapped()
    }
    
    @objc func handleReplyLabelTapped() {
        delegate?.handleReplyLabelTapped()
    }
    
    @objc func handlePostImageTapped() {
        
    }
    
    // MARK: - Helpers
    
    func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        return button
    }
    
    func configure() {
        guard let tweet = tweet else { return }
        
        let viewModel = TweetViewModel(tweet: tweet)
        
        captionLabel.text = tweet.caption
        fullnameLabel.text = tweet.user.fullname
        usernameLabel.text = viewModel.usernameText
        profileIMageView.sd_setImage(with: viewModel.profileImageUrl)
        dateLabel.text = viewModel.headerTimestamp
        likesLabel.attributedText = viewModel.likesAttributedString
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        likeButton.tintColor = viewModel.likeButtonTintColor
        
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
        
        setLabel.text = onSet?.setText
        
        postImageView.sd_setImage(with: viewModel.postImageUrl)
        if tweet.postImageUrl != nil {
            postImageView.isHidden = false
        }
    }
    
    func configureMentionHandler() {
        captionLabel.handleMentionTap { username in
            self.delegate?.handleeFetchUser(withUsername: username)
        }
    }
    
    func returnHeaderHeight() -> Double {
        return captionLabel.intrinsicContentSize.height
    }
}
