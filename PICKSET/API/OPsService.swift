//
//  TweetService.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import Firebase

struct OPsService {
    static let shared = OPsService()
    
    func uploadPost(topic: String, description: String, category: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["uid": uid, "timestamp": Int(NSDate().timeIntervalSince1970), "topic": topic, "description": description, "category": category, "vote": 0, "type": 0] as [String : Any]
        
        REF_POST.childByAutoId().updateChildValues(values) { err, ref in
            
            //update user-tweet structure after tweet upload completes
            guard let postID = ref.key else { return }
            REF_USER_POSTS.child(uid).updateChildValues([postID: 1]) { (err, ref) in
                REF_OPS.child(postID).updateChildValues(values) { (err, ref) in
                    REF_USER_OPS.child(uid).updateChildValues([postID: 1]) { (err, ref) in
                        decideCategory(postID: postID, category: category, completion: completion)
                    }
                }
            }
        }
    }
    
    func decideCategory(postID: String, category: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        if category == "ニュース" {
            REF_CATEGORIES.child("news").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else if category == "スポーツ" {
            REF_CATEGORIES.child("sports").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else if category == "エンタメ" {
            REF_CATEGORIES.child("entertainment").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else if category == "コロナ" {
            REF_CATEGORIES.child("covid").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else if category == "経済" {
            REF_CATEGORIES.child("economy").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else if category == "ネット・IT" {
            REF_CATEGORIES.child("information").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else if category == "ファッション" {
            REF_CATEGORIES.child("fashion").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else if category == "暮らし" {
            REF_CATEGORIES.child("lifestyle").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else if category == "グルメ" {
            REF_CATEGORIES.child("food").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else if category == "おでかけ" {
            REF_CATEGORIES.child("shopping").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else if category == "カルチャー" {
            REF_CATEGORIES.child("culture").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else if category == "アニメ・ゲーム" {
            REF_CATEGORIES.child("game").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else if category == "おもしろ" {
            REF_CATEGORIES.child("fun").updateChildValues([postID: 1], withCompletionBlock: completion)
        } else {
            REF_CATEGORIES.child("love").updateChildValues([postID: 1], withCompletionBlock: completion)
        }
    }
    
    func fetchTweets(completion: @escaping([OPs]) -> Void) {
        var tweets = [OPs]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(tweets)
            } else {
                REF_USER_FOLLOWING.child(currentUid).observe(.childAdded) { snapshot in
                    let followingUid = snapshot.key
                    
                    REF_USER_OPS.child(followingUid).observe(.childAdded) { snapshot in
                        let tweetID = snapshot.key
                        
                        self.fetchOP(withOPsID: tweetID) { tweet in
                            tweets.append(tweet)
                            completion(tweets)
                        }
                    }
                }
            }
        }
        
        REF_USER_OPS.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(tweets)
            } else {
                REF_USER_OPS.child(currentUid).observe(.childAdded) { snapshot in
                    let tweetID = snapshot.key
                    
                    self.fetchOP(withOPsID: tweetID) { tweet in
                        tweets.append(tweet)
                        completion(tweets)
                    }
                }
            }
        }
    }
    
    func fetchPosts(forUser user: User, completion: @escaping([OPs]) -> Void) {
        var posts = [OPs]()
        REF_USER_POSTS.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            self.fetchOP(withOPsID: tweetID) { tweet in
                posts.append(tweet)
                completion(posts)
            }
        }
    }
    
    func fetchOP(withOPsID opsID: String, completion: @escaping(OPs) -> Void) {
        REF_OPS.child(opsID).observeSingleEvent(of: .value) { snapshot in //多分だけど、今回observeSingleEventでいいのはREF_USER_TWEETSの方でchildAddedにしていて新しいのは更新されるようになっているから
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = OPs(user: user, tweetID: opsID, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    
    func fetchOpinions(forUser user: User, completion: @escaping([OPs]) -> Void) {
        var opinions = [OPs]()
        REF_USER_OPINIONS.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            self.fetchOP(withOPsID: tweetID) { tweet in
                opinions.append(tweet)
                completion(opinions)
            }
        }
    }
    
    func fetchReplies(forTweet tweet: OPs, completion: @escaping([OPs]) -> Void) {
        var tweets = [OPs]()
        
        REF_OPINION_REPLIES.child(tweet.opsID).observe(.childAdded) { snapshot in
            guard let  dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = OPs(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchLikes(forUse user: User, completion: @escaping([OPs]) -> Void) {
        var tweets = [OPs]()
        
        REF_USER_LIKES.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            self.fetchOP(withOPsID: tweetID) { likedTweet in
                let tweet = likedTweet
//                tweet.didLike = true //これはlikesのところでちゃんとライクボタンが押されていることを示しているが、これだと、他のひとがライクしたものにも全部ライクボタン押したことになってしまうから注意。
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func likeOpinion(opinion: OPs, postID: String, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = opinion.didLike ? opinion.likes - 1 : opinion.likes + 1
        REF_OPS.child(opinion.opsID).child("likes").setValue(likes)
        
        if uid == opinion.user.uid {
            if opinion.didLike {
                REF_USER_LIKES.child(uid).child(opinion.opsID).removeValue { (err, ref) in
                    REF_USER_POSTLIKES.child(uid).child(postID).child(opinion.opsID).removeValue(completionBlock: completion)
                }
            } else {
                REF_USER_LIKES.child(uid).updateChildValues([opinion.opsID: 1]) { (err, ref) in
                    REF_USER_POSTLIKES.child(uid).child(postID).updateChildValues([opinion.opsID: 1], withCompletionBlock: completion)
                }
            }
        } else {
            if opinion.didLike {
                // unlike opinion
                REF_USER_LIKES.child(uid).child(opinion.opsID).observeSingleEvent(of: .value) { snapshot in
                    guard let notificationID = snapshot.value as? String else { return }
                    NotificationService.shared.removeNotification(toUser: opinion.user, notificationID: notificationID) { (err, ref) in
                        REF_USER_LIKES.child(uid).child(opinion.opsID).removeValue { (err, ref) in
                            REF_USER_POSTLIKES.child(uid).child(postID).child(opinion.opsID).removeValue { (err, ref) in
                                REF_OPINION_LIKES.child(opinion.opsID).child(uid).removeValue(completionBlock: completion)
                            }
                        }
                    }
                }
            } else {
                // like opinion
                NotificationService.shared.UploadNotification(type: .like, toUser: opinion.user, tweetID: opinion.opsID) { notificationID in
                    REF_USER_LIKES.child(uid).updateChildValues([opinion.opsID: notificationID]) { (err, ref) in
                        REF_USER_POSTLIKES.child(uid).child(postID).updateChildValues([opinion.opsID: 1]) { (err, ref) in
                            REF_OPINION_LIKES.child(opinion.opsID).updateChildValues([uid: Int(NSDate().timeIntervalSince1970)], withCompletionBlock: completion)
                        }
                    }
                }
            }
        }
    }
    
    func checkIfUserLikedTweet(_ tweet: OPs, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_LIKES.child(uid).child(tweet.opsID).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists()) //デフォルトがtweet.didlikeはfalseだけれどもちゃんと以前LIKeされていればデータベースにはライクした情報が残っており、それがあるかどうかで確認をしている。つまり、didlikeがtrueなのかfalseなのかで確認はしていない
        }
    }
    
    func checkIfOpinions(_ tweet: OPs, completion: @escaping(Bool) -> Void) {
        REF_OPS.child(tweet.opsID).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let type = dictionary["type"] as? Int else { return }
            completion(type == 1) //デフォルトがtweet.didlikeはfalseだけれどもちゃんと以前LIKeされていればデータベースにはライクした情報が残っており、それがあるかどうかで確認をしている。つまり、didlikeがtrueなのかfalseなのかで確認はしていない
        }
    }
    
    func uploadOpinion(post: OPs, setID: String, caption: String, type: UploadTweetConfiguration, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var values = ["uid": uid, "timestamp": Int(NSDate().timeIntervalSince1970), "likes": 0, "replyCount": 0, "caption": caption, "type": 1, "postID": post.opsID, "setID": setID] as [String : Any]
        
        switch type {
        case .tweet:
            print("DEBUG: hello")
            //let ref = REF_TWEETS.childByAutoId() //これIDの自動生成ってことか。あの訳のわからない
            
            REF_POST_OPINIONS.child(post.opsID).child(setID).child(uid).childByAutoId().updateChildValues(values) { err, ref in
                
                //update user-tweet structure after tweet upload completes
                guard let opinionID = ref.key else { return }
                REF_OPS.child(opinionID).updateChildValues(values) { (err, ref) in
                    REF_USER_OPS.child(uid).updateChildValues([opinionID: 1]) { (err, ref) in
                        REF_USER_OPINIONS.child(uid).updateChildValues([opinionID: 1]) { (err, ref) in
                            REF_SETUSERS_OPINIONS.child(setID).child(uid).updateChildValues([opinionID: 1], withCompletionBlock: completion)
                        }
                    }
                }
            }
        case .reply(let tweet):
            values["replyingTo"] = tweet.user.username
            values["basedOpinionID"] = tweet.opsID
            REF_OPS.childByAutoId().updateChildValues(values) { (err, ref) in //refはREF_TWEET_REPLIES.child(tweet.tweetID)の一個下の階層にあるやつ
                guard let replyKey = ref.key else { return }
                REF_USER_REPLIES.child(uid).child(tweet.opsID).updateChildValues([replyKey: 1]) { (err, ref) in
                    REF_OPINION_REPLIES.child(tweet.opsID).child(replyKey).updateChildValues(values) { (err, ref) in
                        REF_USER_OPS.child(uid).updateChildValues([replyKey: 1]) { (err, ref) in
                            REF_USER_OPINIONS.child(uid).updateChildValues([replyKey: 1], withCompletionBlock: completion)
                        }
                    }
                }
            }
        }
    }
    
//    func removeOpinions(postID: String, setID: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
//        print("DEBUG: start removeopinion")
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        REF_POST_OPINIONS.child(postID).child(uid).observe(.childAdded) { snapshot in
//            print("DEBUG: hyahhou")
//            let opinionID = snapshot.key
//            REF_OPINION_REPLIES.child(opinionID).observeSingleEvent(of: .value) { snapshot in
//                if snapshot.exists() {
//                    REF_OPINION_REPLIES.child(opinionID).observe(.childAdded) { snapshot in
//                        print("DEBUG: snapshot key is \(snapshot.key)")
//                        let replyKey = snapshot.key
//                        removeReplies(opinionID: opinionID, replyKey: replyKey)
//                    }
//                }
//                print("DEBUG: fuck")
//                REF_POST_OPINIONS.child(postID).child(uid).child(opinionID).removeValue { (err, ref) in
//                    print("DEBUG: what")
//                    REF_OPS.child(opinionID).removeValue { (err, ref) in
//                        REF_USER_OPS.child(uid).child(opinionID).removeValue { (err, ref) in
//                            print("DEBUG: Why")
//                            REF_USER_OPINIONS.child(uid).child(opinionID).removeValue { (err, ref) in
//                                print("DEBUG: gtfgfgfsgfhgfgfhgf")
//                                REF_SETUSERS_OPINIONS.child(setID).child(uid).child(opinionID).removeValue(completionBlock: completion)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func removeOpinions(postID: String, setID: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        print("DEBUG: this is called")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("DEBUG: what is")
        REF_POST_OPINIONS.child(postID).child(setID).child(uid).observe(.childAdded) { snapshot in
            print("DEBUG: snapshot \(snapshot)")
            print("DEBUG: boss")
            let opinionID = snapshot.key
            REF_OPINION_REPLIES.child(opinionID).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    REF_OPINION_REPLIES.child(opinionID).observe(.childAdded) { snapshot in
                        let replyKey = snapshot.key
                        removeReplies(opinionID: opinionID, replyKey: replyKey)
                    }
                }
                REF_POST_OPINIONS.child(postID).child(setID).child(uid).child(opinionID).removeValue { (err, ref) in
                    REF_OPS.child(opinionID).removeValue { (err, ref) in
                        REF_USER_OPS.child(uid).child(opinionID).removeValue { (err, ref) in
                            REF_OPINION_LIKES.child(opinionID).observeSingleEvent(of: .value) { snapshot in
                                if snapshot.exists() {
                                    removeLikes(postID: postID, opinionID: opinionID) { (err, ref) in
                                        REF_SAVEOPS.child(opinionID).observeSingleEvent(of: .value) { snapshot in
                                            if snapshot.exists() {
                                                removeSaves(opsID: opinionID) { (err, ref) in
                                                    REF_SETUSERS_OPINIONS.child(setID).child(uid).child(opinionID).removeValue(completionBlock: completion)
                                                }
                                            } else {
                                                REF_SETUSERS_OPINIONS.child(setID).child(uid).child(opinionID).removeValue(completionBlock: completion)
                                            }
                                        }
                                    }
                                } else {
                                    REF_SAVEOPS.child(opinionID).observeSingleEvent(of: .value) { snapshot in
                                        if snapshot.exists() {
                                            removeSaves(opsID: opinionID) { (err, ref) in
                                                REF_SETUSERS_OPINIONS.child(setID).child(uid).child(opinionID).removeValue(completionBlock: completion)
                                            }
                                        } else {
                                            REF_SETUSERS_OPINIONS.child(setID).child(uid).child(opinionID).removeValue(completionBlock: completion)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removeLikes(postID: String, opinionID: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_OPINION_LIKES.child(opinionID).observe(.childAdded) { snapshot in
                    let uid = snapshot.key
                    REF_USER_LIKES.child(uid).child(opinionID).removeValue { (err, ref) in
                        REF_USER_POSTLIKES.child(uid).child(postID).child(opinionID).removeValue { (err, ref) in
                            REF_OPINION_LIKES.child(opinionID).child(uid).removeValue(completionBlock: completion)
                }
            }
        }
    }
    
    func removeSaves(opsID: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_SAVEOPS.child(opsID).observe(.childAdded) { snapshot in
            let uid = snapshot.key
            REF_USERSAVES.child(uid).child(opsID).removeValue { (err, ref) in
                REF_SAVEOPS.child(opsID).child(uid).removeValue(completionBlock: completion)
            }
        }
    }
    
    func removeReplies(opinionID: String, replyKey: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_OPINION_REPLIES.child(replyKey).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                REF_OPINION_REPLIES.child(replyKey).observe(.childAdded) { snapshot in
                    removeReplies(opinionID: replyKey, replyKey: snapshot.key)
                }
            } else {
                REF_OPS.child(replyKey).removeValue { (err, ref) in
                    REF_USER_REPLIES.child(uid).child(opinionID).child(replyKey).removeValue { (err, ref) in
                        REF_OPINION_REPLIES.child(opinionID).child(replyKey).removeValue { (err, ref) in
                            REF_USER_OPS.child(uid).child(replyKey).removeValue { (err, ref) in
                                REF_OPINION_LIKES.child(replyKey).observeSingleEvent(of: .value) { snapshot in
                                    if snapshot.exists() {
                                        self.fetchOP(withOPsID: replyKey) { reply in
                                            guard let postID = reply.postID else { return }
                                            removeLikes(postID: postID, opinionID: replyKey) { (err, ref) in
                                                REF_SAVEOPS.child(replyKey).observeSingleEvent(of: .value) { snapshot in
                                                    if snapshot.exists() {
                                                        removeSaves(opsID: replyKey) { (err, ref) in
                                                            REF_USER_OPINIONS.child(uid).child(replyKey).removeValue()
                                                        }
                                                    } else {
                                                        REF_USER_OPINIONS.child(uid).child(replyKey).removeValue()
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        REF_SAVEOPS.child(replyKey).observeSingleEvent(of: .value) { snapshot in
                                            if snapshot.exists() {
                                                removeSaves(opsID: replyKey) { (err, ref) in
                                                    REF_USER_OPINIONS.child(uid).child(replyKey).removeValue()
                                                }
                                            } else {
                                                REF_USER_OPINIONS.child(uid).child(replyKey).removeValue()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchOpinions(setID: String, completion: @escaping([OPs]) -> Void) { //if文が足りない気がする
        var opinions = [OPs]()
        REF_SETUSERS_OPINIONS.child(setID).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(opinions)
            } else {
                REF_SETUSERS_OPINIONS.child(setID).observe(.childAdded) { snapshot in
                    let uid = snapshot.key
                    REF_SETUSERS_OPINIONS.child(setID).child(uid).observe(.childAdded) { snapshot in
                        let opinionID = snapshot.key
                        self.fetchOpinion(withOpinionID: opinionID) { opinion in
                            opinions.append(opinion)
                            completion(opinions)
                        }
                    }
                }
            }
        }
    }
    
    func fetchOpinion(withOpinionID opinionID: String, completion: @escaping(OPs) -> Void) {
        REF_OPS.child(opinionID).observeSingleEvent(of: .value) { snapshot in //多分だけど、今回observeSingleEventでいいのはREF_USER_TWEETSの方でchildAddedにしていて新しいのは更新されるようになっているから
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            UserService.shared.fetchUser(uid: uid) { user in
                let opinion = OPs(user: user, tweetID: opinionID, dictionary: dictionary)
                completion(opinion)
            }
        }
    }
    
    func decreaseLikeCount(postID: String,completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_USER_POSTLIKES.child(uid).child(postID).observe(.childAdded) { snapshot in
            let opinionID = snapshot.key
            REF_OPS.child(opinionID).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let likes = dictionary["likes"] as? Int else { return }
                let newLikes = likes - 1
                REF_OPS.child(opinionID).child("likes").setValue(newLikes)
            }
            REF_USER_LIKES.child(uid).child(opinionID).removeValue { (err, ref) in
                REF_USER_POSTLIKES.child(uid).child(postID).child(opinionID).removeValue(completionBlock: completion)
            }
        }
    }
    
    func uploadSaves(opsID: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_SAVEOPS.child(opsID).updateChildValues([uid: 1]) { (err, ref) in
            REF_USERSAVES.child(uid).updateChildValues([opsID: Int(NSDate().timeIntervalSince1970)], withCompletionBlock: completion)
        }
    }
    
    func fetchSaves(completion: @escaping([OPs], [Int]) -> Void) {
        var ops = [OPs]()
        var timestamp = [Int]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_USERSAVES.child(uid).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(ops, timestamp)
            } else {
                REF_USERSAVES.child(uid).observe(.childAdded) { snapshot in
                    let tweetID = snapshot.key
                    guard let newTimestamp = snapshot.value as? Int else { return }

                    self.fetchOP(withOPsID: tweetID) { tweet in
                        ops.append(tweet)
                        timestamp.append(newTimestamp)
                        completion(ops, timestamp)
                    }
                }
            }
        }
    }
}
