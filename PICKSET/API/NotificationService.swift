//
//  NotificationService.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import Firebase

struct NotificationService {
    static let shared = NotificationService()
    
    func UploadNotification(type: NotificationType, toUser user: User, tweetID: String? = nil, completion: @escaping(String) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values: [String: Any] = ["timestamp": Int(NSDate().timeIntervalSince1970), "uid": uid, "type": type.rawValue]
        
        if let tweetID = tweetID {
            values["tweetID"] = tweetID
        }
        REF_NOTIFICATIONS.child(user.uid).childByAutoId().updateChildValues(values) { (err, ref) in
            guard let notificationID = ref.key else { return }
            completion(notificationID)
        }
    }
    
    func removeNotification(toUser user: User, notificationID: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_NOTIFICATIONS.child(user.uid).child(notificationID).removeValue(completionBlock: completion)
    }
    
    func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        var notifications = [Notification]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_NOTIFICATIONS.child(uid).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(notifications)
            } else {
                REF_NOTIFICATIONS.child(uid).observe(.childAdded) { snapshot in
                    guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                    guard let uid = dictionary["uid"] as? String else { return }
                    
                    UserService.shared.fetchUser(uid: uid) { user in
                        let notification = Notification(user: user, notificationID: snapshot.key, dictionary: dictionary)
                        notifications.append(notification)
                        completion(notifications)
                    }
                }
            }
        }
    }
}
