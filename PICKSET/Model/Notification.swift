//
//  Notification.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/07.
//

import Foundation

enum NotificationType: Int {
    case follow
    case like
    case reply
    case retweet
    case mention
}

struct Notification {
    var tweetID: String?
    var timestamp: Date!
    var user: User
    let notificationID: String
    var tweet: OPs? //やっぱoptionalは存在しない時もあるからoptionalなんだな。今回ならtweetに絡まない通知もあるからね（followとか）
    var type: NotificationType!
    
    init(user: User, notificationID: String, dictionary: [String: AnyObject]) {
        self.user = user
        self.notificationID = notificationID
        
        if let tweetID = dictionary["tweetID"] as? String {
            self.tweetID = tweetID
        }
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type)
        }
    }
}
