//
//  Tweet.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/07.
//

import Foundation

enum PostType: Int {
    case post
    case opinion
}

struct OPs {
    var caption: String?
    var topic: String?
    var description: String?
    let opsID: String
    var postID: String?
    var likes: Int
    var vote: Int
    var replyCount: Int?
    var timestamp: Date!
    var user: User
    var didLike = false
    var replyingTo: String? //ここでオプショナルにしなかったら例えvarでも常に何かしら値が入っていないといけない。もちろん全ツイートが何かに対するリプライな訳がないのでこれは?をつけないといけない
    var type: PostType!
    var opinionOrNot = false
    var setID: String?
    var category: String?
    var basedOpinionID: String?
    var postImageUrl: URL?
    
    var isReply: Bool { return replyingTo != nil }
    
    init(user: User, tweetID: String, dictionary: [String: Any]) { //これは、今回の初期化したい値の中でtweetID以外はdatabaseの同じ階層になるから辞書式で取ってこれるということ。それと、ここでこの配列のvalueがAnyになっているのは、色々なタイプがvalueにありすぎるから。（DateとかIntとか）
        
        self.user = user
        self.opsID = tweetID
        
        self.likes = dictionary["likes"] as? Int ?? 0
        self.vote = dictionary["vote"] as? Int ?? 0
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
        if let basedOpinionID = dictionary["basedOpinionID"] as? String {
            self.basedOpinionID = basedOpinionID
        }
        if let topic = dictionary["topic"] as? String {
            self.topic = topic
        }
        if let caption = dictionary["caption"] as? String {
            self.caption = caption
        }
        if let type = dictionary["type"] as? Int {
            self.type = PostType(rawValue: type)
            if type == 1 {
                self.opinionOrNot = true
            }
        }
        if let postID = dictionary["postID"] as? String {
            self.postID = postID
        }
        if let description = dictionary["description"] as? String {
            self.description = description
        }
        if let setID = dictionary["setID"] as? String {
            self.setID = setID
        }
        
        if let category = dictionary["category"] as? String {
            self.category = category
        }
        
        if let postImageUrlString = dictionary["postImageUrl"] as? String {
            guard let url = URL(string: postImageUrlString) else { return }
            self.postImageUrl = url
        }
    }
}
