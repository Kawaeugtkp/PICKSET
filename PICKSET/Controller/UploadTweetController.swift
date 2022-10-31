//
//  UploadTweetController.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit
import ActiveLabel
import Firebase

//多分このcontrollerでfeedcontrollerみたいにuserを呼び出せなくてちょっと面倒なことしているのは、maintabucontrollerでfetchuserしてそのサブ的な位置にfeedcontrollerがあるから（あの配列作ってる感じからそんな気がする）

class UploadTweetController: UIViewController, UITextViewDelegate {
    
    //MARK: - Properties
    
    private let setID: String
    
    private let post: OPs
    
    private let user: User
    private let config: UploadTweetConfiguration
    private lazy var viewModel = UploadTweetViewModel(config: config)
    
    private lazy var actionButton: UIButton = { //ここがprivate let actionButton: UIButtonの時はうまくいかなかった
        let button = UIButton(type: .system)
        button.backgroundColor = .picksetRed
        button.setTitle("Tweet", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32) //ここで、x,yが0でいいのは、多分だけどrightbarbuttonitemの動ける範囲が決まっていて、その中であれば左上の角がx,yが0でもいい感じに設定できているということだと思う
        button.layer.cornerRadius = 32 / 2
        
        button.addTarget(self, action: #selector(handleUploadTweet), for: .touchUpInside)
        return button
    }()
    
    private let profileIMageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill //ちなみにこれがfeedcotrollerの左下のボタンのとこには設定されていなくて、実際このコードなしでもなんか違和感なさそう（ズームしたらわからんけど）なので、必要性は不明
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48 / 2
        iv.backgroundColor = .picksetRed
        return iv
    }()
    
    private lazy var replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.mentionColor = .picksetRed
        label.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        return label
    }()
    
    private let captionTextView = InputTextView()

    
    //MARK: - Lifecycle
    
    init(post: OPs, user: User, config: UploadTweetConfiguration, setID: String) {
        self.post = post
        self.user = user
        self.config = config
        self.setID = setID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMentionHandler()
    }
    
    //MARK: - Selectors
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleUploadTweet() {
        guard let caption = captionTextView.text else { return }
        if caption == "" || caption.isOnly(structuredBy: " 　\n") {
            alert(title: "投稿内容が入力されていません", message: "", actiontitle: "OK")
            return
        } else {
            OPsService.shared.uploadOpinion(post: post, setID: setID, caption: caption, type: config) { (error, ref) in
                if let error = error {
                    print("DEBUG: Failed to upload tweet with error \(error.localizedDescription)")
                    return
                }
                
                if case .reply(let tweet) = self.config {
                    NotificationService.shared.UploadNotification(type: .reply, toUser: tweet.user, tweetID: tweet.opsID) { notificationID in
                        
                    }
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    //MARK: - API
    
    fileprivate func uploadMentionNotification(forCaption caption: String, tweetID: String?) {
        guard caption.contains("@") else { return }
        
        let words = caption.components(separatedBy: .whitespacesAndNewlines)
        
        words.forEach { word in
            guard word.hasPrefix("@") else { return } //hasPrefixっていうのは"@"から始まっているのかっていうのを判断するBoolを返すものらしい
            
            var username = word.trimmingCharacters(in: .symbols)
            username = username.trimmingCharacters(in: .punctuationCharacters)
            
            UserService.shared.fetchUser(withUsername: username) { mentionedUser in
                NotificationService.shared.UploadNotification(type: .mention, toUser: mentionedUser, tweetID: tweetID) { notificationID in
                    print("DEBUG: mention notification completed and the ID is \(notificationID)")
                }
            }
        }
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        configureNavigationBar()
        
//        view.addSubview(profileIMageView)
//        profileIMageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16)
//        view.addSubview(captionTextView)
//        captionTextView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: profileIMageView.rightAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingRight: 16)
//        profileIMageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        //したのコードだとどうしてもprofileIMageViewかcaptionTextViewの高さの低い方に高さが寄ってしまうから上みたいにstackview設定をやめた
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileIMageView, captionTextView])
        imageCaptionStack.axis = .horizontal
        imageCaptionStack.spacing  = 12
        imageCaptionStack.alignment = .leading //これをすることで画像の方にcaptiontextviewがサイズ的に寄ってしまうのを防ぐらしい。なんでleadingかは意味不明
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
//        stack.alignment = .leading こっちはいらないらしい
        stack.spacing = 12

        view.addSubview(stack)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16)
        profileIMageView.sd_setImage(with: user.profileImageUrl, completed: nil) //なぜこのファイル内でsdwebimageをimportしなくていいのかが謎
        
        actionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        captionTextView.placeholderLabel.text = viewModel.placeholderText
        
        replyLabel.isHidden = !viewModel.shouldShowReplyLabel
        guard let replytext = viewModel.replyText else { return }
        replyLabel.text = replytext
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
    
    func configureMentionHandler() {
        replyLabel.handleMentionTap { mention in
            print("DEBUG: Mentioned user is \(mention)") //おそらくこのcocoapodsは"@"がついていることでmentionであることを判定し、"#"がついていることでhashtagを判定しているんだと思う。だから、このclosureの中でmentionを扱うときに"@"より後の値が持ってこれるんだと思う。
        }
    }
    
    func alert(title:String,message:String,actiontitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actiontitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
