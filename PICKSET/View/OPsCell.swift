//
//  TweetCell.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit
import ActiveLabel

protocol TweetCellDelegate: class { //tweetcellは親クラスがUICollectionViewCellだからnavigationcontroller使ってプロフ画像タップした後に個人のページに飛ばすとかはできない。その処理を各コントローラーに委任するためにこのdelegateが必要
    func handleProfileImageTapped(_ cell: OPsCell)
    func handleReplyTapped(_ cell: OPsCell)
    func handleLikeTapped(_ cell: OPsCell)
    func handleFetchUser(withUsername username: String)
    func handlePostLabelTapped(_ cell: OPsCell)
    func handleMarked(_ cell: OPsCell)
    func handleReplyLabelTapped(_ cell: OPsCell)
    func handlePostImageTapped(cell: OPsCell, imageView: UIImageView)
}

class OPsCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var ops: OPs? {
        didSet {
            fetchPost()
            configure()
        }
    }
    
    weak var delegate: TweetCellDelegate?
    
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
        iv.setDimensions(width: 210, height: 140)
        iv.layer.cornerRadius = 10
        iv.backgroundColor = .lightGray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePostImageTapped))
        
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    lazy var postLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePostLabelTapped))
        
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        
        return label

    }()
    
    private lazy var replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.mentionColor = .picksetRed
        label.handleMentionTap { replyTo in
            self.handleReplyLabelTapped()
        }
//        let tap = UITapGestureRecognizer(target: TweetCell.self, action: #selector(handleReplyLabelTapped))
//
//        label.addGestureRecognizer(tap)
//        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "comment")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }() //このセルにはいらないと判断。リプライしたいならopinionの詳細のcontrollerでやれればいい
    

    
    lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like")
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
//    private lazy var shareButton: UIButton = {
//        let button = createButton(withImageName: "share")
//        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
//        return button
//    }()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.mentionColor = .picksetRed
        label.hashtagColor = .picksetRed
        label.numberOfLines = 0 //これの意味がよくわからないから、ある程度実装できたらここの数字を変える。
        return label
    }()
    
    private let topicLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let voteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .picksetRed
        label.text = "100 votes"
        return label
    }()
    
//    private let commentCountLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = .lightGray
//        label.text = "5"
//        return label
//    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.text = "5"
        return label
    }()
    
    let likeImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "heart.fill"))
        iv.tintColor = .lightGray
        return iv
    }()
    
    lazy var markButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "dock.arrow.down.rectangle"), for: .normal)
        button.tintColor = .picksetRed
        button.addTarget(self, action: #selector(handleMarked), for: .touchUpInside)
        return button
    }()
    
    let underBlankView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    
    private let infoLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let captionStack = UIStackView(arrangedSubviews: [infoLabel, captionLabel, topicLabel])
        captionStack.axis = .vertical
        captionStack.distribution = .fillProportionally //これもいくつか候補があったから、ある程度実装できたらその候補を変えてやってみる。ドキュメントを見る感じだと、出そうとしてるコンテンツがちゃんと自然な形で出るみたいなことが書いてある
        captionStack.spacing = 4
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileIMageView, captionStack])
        imageCaptionStack.distribution = .fillProportionally
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .leading
        
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack]) //replylabel詰めたからセルが窮屈になった
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingRight: 12) //profileIMageView.topAnchorでprofileIMageViewと一番上の高さを合わせられているんだと思う。だから、paddingの設定が必要ない
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        
        addSubview(postImageView)
        postImageView.centerX(inView: self)
        postImageView.anchor(top: stack.bottomAnchor, paddingTop: 10)
        
//        addSubview(underBlankView)
//        underBlankView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 20)
        
        //        let actionStack = UIStackView(arrangedSubviews: [likeButton, shareButton])
        //        actionStack.axis = .horizontal
        //        actionStack.spacing = 72
        
        //        if captionLabel.isHidden {
        addSubview(voteLabel)
        voteLabel.anchor(bottom: bottomAnchor, right: rightAnchor, paddingBottom: 10, paddingRight: 30)
        //        } else {
        
//        let commentStack = UIStackView(arrangedSubviews: [commentButton, commentCountLabel])
//        commentStack.axis = .horizontal
//        commentStack.spacing = 3
        
        let likeStack = UIStackView(arrangedSubviews: [likeButton, likeCountLabel])
        likeStack.axis = .horizontal
        likeStack.spacing = 3
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton, likeStack])
        actionStack.axis = .horizontal
        actionStack.spacing = 20
        addSubview(actionStack)
        actionStack.anchor(bottom: bottomAnchor, right: rightAnchor, paddingBottom: 8, paddingRight: 28)
        //        }
        
        likeImageView.setDimensions(width: 18, height: 18)
        
        addSubview(likeImageView)
        likeImageView.anchor(bottom: bottomAnchor, right: likeCountLabel.leftAnchor, paddingBottom: 10, paddingRight: 5)
        
        let underLineView = UIView()
        underLineView.backgroundColor = .systemGroupedBackground
        addSubview(underLineView)
        underLineView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 1) //anchor系は端っこに寄せるってことがデフォであるから、今回だとpaddingを設定しなくてもいい。なぜなら色でviewが全部埋め尽くされているから
        
        addSubview(markButton)
        markButton.centerX(inView: profileIMageView)
        markButton.anchor(bottom: underLineView.topAnchor, paddingBottom: 2)
        
        addSubview(postLabel)
        postLabel.anchor(left: markButton.rightAnchor, bottom: bottomAnchor, paddingLeft: 5, paddingBottom: 5, width: 150)
        
        configureMentionHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API
    
    func fetchPost() {
        guard let postID = ops?.postID else { return }
        OPsService.shared.fetchOP(withOPsID: postID) { post in
            self.postLabel.text = post.topic
        }
    }
    
    // MARK: - Selectors
    
    @objc func handleCommentTapped() {
        delegate?.handleReplyTapped(self)
    }
    
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(self)
    }
    
//    @objc func handleShareTapped() {
//
//    }
    
    @objc func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    
    @objc func handlePostLabelTapped() {
        delegate?.handlePostLabelTapped(self)
    }
    
    @objc func handleMarked() {
        delegate?.handleMarked(self)
    }
    
    @objc func handleReplyLabelTapped() {
        print("DEBUG: clicked")
        delegate?.handleReplyLabelTapped(self)
    }
    
    @objc func handlePostImageTapped() {
        delegate?.handlePostImageTapped(cell: self, imageView: postImageView)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let ops = ops else { return }
        let viewModel = TweetViewModel(tweet: ops)
        captionLabel.text = ops.caption
        topicLabel.text = ops.topic
//        fetchPost()
        voteLabel.isHidden = viewModel.shouldHideTopic
        captionLabel.isHidden = !viewModel.shouldHideTopic //ちょっと怖い。別にいらないかも
        topicLabel.isHidden = viewModel.shouldHideTopic //これももし変な挙動をしたら消してもいいかも
        likeCountLabel.isHidden = !viewModel.shouldHideTopic
        likeImageView.isHidden = !ops.opinionOrNot
        voteLabel.text = "\(ops.vote)"
        
        postLabel.isHidden = !ops.opinionOrNot
        
        if ops.postImageUrl == nil {
            postImageView.isHidden = true
        } else {
            postImageView.isHidden = false
        }
        
//        captionLabel.isHidden = viewModel.shouldHideLikeButton
        
        profileIMageView.sd_setImage(with: viewModel.profileImageUrl)
        postImageView.sd_setImage(with: viewModel.postImageUrl)
        infoLabel.attributedText = viewModel.userInfoText
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
//        likeButton.isHidden = viewModel.shouldHideLikeButton
//        shareButton.isHidden = viewModel.shouldHideLikeButton
        
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
        
        likeCountLabel.text = String(ops.likes)
    }
    
    func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        return button
    }
    
    func configureMentionHandler() {
        captionLabel.handleMentionTap { username in
            self.delegate?.handleFetchUser(withUsername: username)
        }
    }
}
