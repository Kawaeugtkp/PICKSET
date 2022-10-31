//
//  UserService.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import Firebase

typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)

struct UserService {
    static let shared = UserService()
    
    func fetchUser(uid: String, completion: @escaping(User) -> Void) { //ここには元々uidの引数がなかったが、TweetModelの引数にUserが必要でその過程でこのfetchuserを使うことになった。しかし、以下のコードのように、元はuidをcurrentuserにしていたので、これでは当然所望のuidとはならない。したがって引数でuidを設定することになった
        //guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in //ユーザーのデータ（名前とかパスワードとか）はリアルタイムに更新されるわけではないのでobservesingleeventでいい //snapshotは配列。keyがtweetIDでvalueがその一個下の階層のやつ（captionとかlikeとか）
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
        }
    }
    
    func fetchUsers(completion: @escaping([User]) -> Void) {
        var users = [User]()
        REF_USERS.observe(.childAdded) { snapshot in
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            users.append(user)
            completion(users)
        }
    }
    
    func followUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
                
        UserService.shared.fetchUser(uid: uid) { toUser in
            NotificationService.shared.UploadNotification(type: .follow, toUser: toUser) { notificationID in
                let values = ["notificationID": notificationID, "timestamp": Int(NSDate().timeIntervalSince1970)]
                REF_USER_FOLLOWING.child(currentUid).child(uid).updateChildValues(values) { (err, ref) in //notificationIDがどこで使われているかREF_USER_FOLLOWINGで検索かけて調べる
                    REF_USER_FOLLOWERS.child(uid).updateChildValues([currentUid: Int(NSDate().timeIntervalSince1970)], withCompletionBlock: completion)
                }
            }
        }
    }
    
    func unfollowUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUid).child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let notificationID = dictionary["notificationID"] as? String else { return }
            UserService.shared.fetchUser(uid: uid) { toUser in
                NotificationService.shared.removeNotification(toUser: toUser, notificationID: notificationID) { (err, ref) in
                    REF_USER_FOLLOWING.child(currentUid).child(uid).removeValue { (err, ref) in
                        REF_USER_FOLLOWERS.child(uid).child(currentUid).removeValue(completionBlock: completion)
                    }
                }
            }
        }
    }
    
    func fetchFollowing(user: User, completion: @escaping([User], [Int]) -> Void) {
        var users = [User]()
        var timestamp = [Int]()
        REF_USER_FOLLOWING.child(user.uid).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(users, timestamp)
            } else {
                REF_USER_FOLLOWING.child(user.uid).observe(.childAdded) { snapshot in
                    let uid = snapshot.key
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    guard let thisTimestanp = dictionary["timestamp"] as? Int else { return }
                    
                    self.fetchUser(uid: uid) { user in
                        users.append(user)
                        timestamp.append(thisTimestanp)
                        completion(users, timestamp)
                    }
                }
            }
        }
    }
    
    func fetchFollowers(user: User, completion: @escaping([User], [Int]) -> Void) {
        var users = [User]()
        var timestamp = [Int]()
        REF_USER_FOLLOWERS.child(user.uid).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(users, timestamp)
            } else {
                REF_USER_FOLLOWERS.child(user.uid).observe(.childAdded) { snapshot in
                    let uid = snapshot.key
                    guard let thisTimestanp = snapshot.value as? Int else { return }
                    
                    self.fetchUser(uid: uid) { user in
                        users.append(user)
                        timestamp.append(thisTimestanp)
                        completion(users, timestamp)
                    }
                }
            }
        }
    }
    
    func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUid).child(uid).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    func fetchUserStats(uid: String, completion: @escaping(UserRelationStats) -> Void) {
        REF_USER_FOLLOWERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            let followers = snapshot.children.allObjects.count
            
            REF_USER_FOLLOWING.child(uid).observeSingleEvent(of: .value) { snapshot in
                let following = snapshot.children.allObjects.count
                
                let stats = UserRelationStats(followers: followers, following: following)
                completion(stats)
            } //completionの中にはこの関数をcontrollerとかで呼び出した時に使いたいものを入れる（今回ならUserRelationStats。フォロワーとフォローの数を使わないといけないから
        }
    }
    
    func updateProfileImage(image: UIImage, completion: @escaping(URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let filename = NSUUID().uuidString
        let ref = STORAGE_PROFILE_IMAGES.child(filename)
        
        ref.putData(imageData, metadata: nil) { (meta, err) in
            ref.downloadURL { (url, err) in
                guard let profileImageUrl = url?.absoluteString else { return } //元はescapingの中身がStringだからここの文章も意味がわかったが、途中でURL?に変更したことによって意味不明になった。実際、この下のvaluesの定義においてもprofileImageUrlではUserのViewではURL?になっているのにこの定義においてはStringになっている
                let values = ["profileImageUrl": profileImageUrl]
                
                REF_USERS.child(uid).updateChildValues(values) { (err, ref) in
                    completion(url)
                }
            }
        }
    }
    
    func saveUserData(user: User, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["fullname": user.fullname, "username": user.username]
        
        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion) //特にcompletionでやることなくて、printしたりするぐらいだからこれでいいっぽい
    }
    
    func fetchUser(withUsername username: String, completion: @escaping(User) -> Void) {
        REF_USER_USERNAMES.child(username).observeSingleEvent(of: .value) { snapshot in
            guard let uid = snapshot.value as? String else { return }
            self.fetchUser(uid: uid, completion: completion)
        }
    }
    func fetchUser(completion: @escaping() -> Void) {
        REF_USER_USERNAMES.observe(.childAdded) { snapshot in
            print(snapshot)
        }
    }
    
    func fetchLikes(opinion: OPs, completion: @escaping([User], [Int]) -> Void) {
        var users = [User]()
        var timestamp = [Int]()
        REF_OPINION_LIKES.child(opinion.opsID).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(users, timestamp)
            } else {
                REF_OPINION_LIKES.child(opinion.opsID).observe(.childAdded) { snapshot in
                    let uid = snapshot.key
                    guard let thisTimestanp = snapshot.value as? Int else { return }
                    
                    self.fetchUser(uid: uid) { likedUser in
                        users.append(likedUser)
                        timestamp.append(thisTimestanp)
                        completion(users, timestamp)
                    }
                }
            }
        }
    }
}
