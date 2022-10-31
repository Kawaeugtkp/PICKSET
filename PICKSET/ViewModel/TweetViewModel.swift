//
//  TweetViewModel.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import Foundation
import UIKit

struct TweetViewModel {
    
    // MARK: - Properties
    
    let tweet: OPs
    let user: User
    var type: PostType
    
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
        
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: tweet.timestamp, to: now) ?? "2m" //ここはオプショナルだけどこの2mになることはないから何入れてもいい
    }
    
    var usernameText: String {
        return "@\(user.username)"
    }
    
    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a・MM/dd/yyyy"
        return formatter.string(from: tweet.timestamp)
    }
    
    var likesAttributedString: NSAttributedString? {
        return attributedText(withValue: tweet.likes, text: "Likes")
    }
    
    var userInfoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullname, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @\(user.username)", attributes:  [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        title.append(NSAttributedString(string: "・\(timestamp)", attributes:  [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        return title
    }
    
    var likeButtonTintColor: UIColor {
        return tweet.didLike ? .red : .lightGray
    }
    
    var likeButtonImage: UIImage {
        let imageName = tweet.didLike ? "like_filled" : "like"
        return UIImage(named: imageName)!
    }
    
    var shouldHideReplyLabel: Bool {
        return !tweet.isReply
    }
    
    var replyText: String? {
        guard let replyingToUsername = tweet.replyingTo else { return nil }
        return "→ replying to @\(replyingToUsername)"
    }
    
    var shouldHideLikeButton: Bool {
        return type != .opinion
    }
    
    var shouldHideTopic: Bool {
        return type != .post
    }
    
    // MARK: - Lifecycle
    
    init(tweet: OPs) {
        self.tweet = tweet
        self.user = tweet.user
        self.type = tweet.type
    }
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        return attributedTitle
    }
    
    // MARK: - Helpers
    
    func size(forwidth width: CGFloat) -> CGSize { //ここで最初は引数にtext: Stringってしてcaptiontextを持ってきていたが、このviewmodelを呼び出している時点でtweetがinitializeされているためいちいち引数で呼び出す必要がない
        let measurementLabel = UILabel()
        if type == .opinion {
            measurementLabel.text = tweet.caption
        } else {
            measurementLabel.text = tweet.topic
        }
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping //多分これはいい感じに改行をするっていうことだと思う
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false //多分これは自分でその幅とか高さとかアンカーとかを決めるので勝手にしないでねっていうことだと思う
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    func labelHeight(forwidth width: CGFloat, labelFont font: CGFloat) -> CGFloat {
        
        if type == .opinion {
            return tweet.caption?.labelHeight(width: width, font: .systemFont(ofSize: font)).height ?? 0
        } else {
            return tweet.topic?.labelHeight(width: width, font: .boldSystemFont(ofSize: font)).height ?? 0
        }
    }
}
