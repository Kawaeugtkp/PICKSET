//
//  SetService.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/24.
//

import Firebase

struct SetService {
    static let shared = SetService()
    
    func uploadSet(setText: String, post: OPs, completion: @escaping(Error?, DatabaseReference) -> Void)  {
        let values = ["timestamp": Int(NSDate().timeIntervalSince1970), "votes": 0, "setText": setText] as [String : Any]
        
        REF_POST_SETS.child(post.opsID).childByAutoId().updateChildValues(values, withCompletionBlock: completion)
    }
    
    func fetchSets(post: OPs, completion: @escaping([Sets]) -> Void) {
        var sets = [Sets]()
        
        REF_POST_SETS.child(post.opsID).observe(.childAdded) { snapshot in
            let setID = snapshot.key
            REF_POST_SETS.child(post.opsID).child(setID).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let set = Sets(setID: setID, dictionary: dictionary)
                sets.append(set)
                completion(sets)
            }
        }
    }
    
    func fetchSet(post: OPs, setID: String, completion: @escaping(Sets) -> Void) {
        REF_POST_SETS.child(post.opsID).child(setID).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let set = Sets(setID: setID, dictionary: dictionary)
            completion(set)
        }
    }
    
    func fetchSetID(post: OPs, completion: @escaping(String) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USER_SETS.child(post.opsID).child(currentUid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let setID = dictionary["setID"] as? String else { return }
                completion(setID)
            } else {
                completion("nothing")
            }
        }
    }
    
    func fetchSelectedSetID(post: OPs, completion: @escaping(String) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USER_SELECTED.child(post.opsID).child(currentUid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let setID = dictionary["setID"] as? String else { return }
                completion(setID)
            } else {
                completion("nothing")
            }
        }
    }
    
    func updateSet(post: OPs, newSetID: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        //        let likes = opinion.didLike ? opinion.likes - 1 : opinion.likes + 1
        //        REF_OPS.child(opinion.opsID).child("likes").setValue(likes)
        fetchSetID(post: post) { setID in
            if setID == "nothing" {
                let vote = post.vote + 1
                REF_OPS.child(post.opsID).child("vote").setValue(vote)
                fetchSet(post: post, setID: newSetID) { onSet in
                    let pick = onSet.votes + 1
                    REF_POST_SETS.child(post.opsID).child(newSetID).child("votes").setValue(pick)
                }
                REF_POST_USERS.child(post.opsID).updateChildValues([currentUid: 1]) { (err, ref) in
                    REF_USER_SETS.child(post.opsID).child(currentUid).updateChildValues(["setID": newSetID]) { (err, ref) in
                        REF_POST_SETUSERS.child(post.opsID).child(newSetID).child(currentUid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
                    }
                }
            } else {
                fetchSet(post: post, setID: setID) { onSet in
                    let pick = onSet.votes - 1
                    REF_POST_SETS.child(post.opsID).child(setID).child("votes").setValue(pick)
                }
                fetchSet(post: post, setID: newSetID) { onSet in
                    let pick = onSet.votes + 1
                    REF_POST_SETS.child(post.opsID).child(newSetID).child("votes").setValue(pick)
                }
                REF_USER_SETS.child(post.opsID).child(currentUid).removeValue { (err, ref) in
                    REF_POST_SETUSERS.child(post.opsID).child(setID).child(currentUid).removeValue { (err, ref) in
                        fase1(postID: post.opsID, uid: currentUid, newSetID: newSetID, completion: completion)
                        REF_POST_OPINIONS.child(post.opsID).child(setID).child(currentUid).observeSingleEvent(of: .value) { snapshot in
                            if snapshot.exists() {
                                OPsService.shared.removeOpinions(postID: post.opsID, setID: setID) { (err, ref) in
                                    print("DEBUG: come on")
                                    fase1(postID: post.opsID, uid: currentUid, newSetID: newSetID, completion: completion)
                                }
                            } else {
                                fase1(postID: post.opsID, uid: currentUid, newSetID: newSetID, completion: completion)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fase1(postID: String, uid: String, newSetID: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_USER_POSTLIKES.child(uid).child(postID).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                OPsService.shared.decreaseLikeCount(postID: postID) { (err, ref) in
                    REF_USER_SETS.child(postID).child(uid).updateChildValues(["setID": newSetID]) { (err, ref) in
                        REF_POST_SETUSERS.child(postID).child(newSetID).child(uid).updateChildValues([uid: 1], withCompletionBlock: completion)
                    }
                }
            } else {
                REF_USER_SETS.child(postID).child(uid).updateChildValues(["setID": newSetID]) { (err, ref) in
                    REF_POST_SETUSERS.child(postID).child(newSetID).child(uid).updateChildValues([uid: 1], withCompletionBlock: completion)
                }
            }
        }
    }
    
    func chechIfUserPicked(post: OPs, setID: String, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_POST_SETUSERS.child(post.opsID).child(setID).child(uid).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    func updateSelect(post: OPs, newSetID: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        fetchSelectedSetID(post: post) { setID in
            if setID == "nothing" {
                REF_USER_SELECTED.child(post.opsID).child(currentUid).updateChildValues(["setID": newSetID]) { (err, ref) in
                    REF_POST_SELECTED.child(post.opsID).child(newSetID).child(currentUid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
                }
            } else {
                REF_USER_SELECTED.child(post.opsID).child(currentUid).removeValue { (err, ref) in
                    REF_POST_SELECTED.child(post.opsID).child(setID).child(currentUid).removeValue { (err, ref) in
                        REF_USER_SELECTED.child(post.opsID).child(currentUid).updateChildValues(["setID": newSetID]) { (err, ref) in
                            REF_POST_SELECTED.child(post.opsID).child(newSetID).child(currentUid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
                        }
                    }
                }
            }
        }
    }
//DEBUG: REF_USER_SELECTED removed
//DEBUG: REF_POST_SELECTED removed
//DEBUG: REF_POST_SELECTED update
//DEBUG: REF_USER_SELECTED update
//DEBUG: REF_POST_SELECTED update この並びから、まず普通に消える。で、その後、消えた状態をnothingだと判断してもともとselectだったものが入る。そして、その後選択し直されたやつがupdate版として入る
    
    func chechIfUserSelected(post: OPs, setID: String, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_POST_SELECTED.child(post.opsID).child(setID).child(uid).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    func fetchSetVotes(post: OPs, setID: String, completion: @escaping(Int) -> Void) {
        REF_POST_SETUSERS.child(post.opsID).child(setID).observeSingleEvent(of: .value) { snapshot in
            let setVotes = snapshot.children.allObjects.count
            completion(setVotes)
        }
    }
    
    func fetchVotes(post: OPs, completion: @escaping(Int) -> Void) {
        REF_POST_USERS.child(post.opsID).observe(.value) { snapshot in
            if snapshot.exists() {
                let votes = snapshot.children.allObjects.count
                completion(votes)
            } else {
                completion(0)
            }
        }
        //        var votes = 0 //これは最初の段階で選択者がいないセットがその後選ばれたら追加されることになっている。だから、多分このやり方ではダメ。もうセットを何か選択した時点でpost-usersみたいなデータを作る必要あり
        //        print("DEBUG: first votes = \(votes)")
        //        REF_POST_SETUSERS.child(post.opsID).observe(.childAdded) { snapshot in
        //            let setID = snapshot.key
        //            fetchSetVotes(post: post, setID: setID) { setVotes in
        //                votes += setVotes
        //                print("DEBUG: setcount is \(votes)")
        //                completion(votes)
        //            }
        ////            print("DEBUG: setcount is \(votes)")
        ////            completion(votes)
        //        }
    }
    
    func checkIfOpinionUserSelectThisSet(post: OPs, setID: String, uid: String, completion: @escaping(Bool) -> Void) {
        REF_POST_SETUSERS.child(post.opsID).child(setID).child(uid).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
}
