//
//  UploadTweetViewModel.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import UIKit

enum UploadTweetConfiguration {
    case tweet
    case reply(OPs)
}

struct UploadTweetViewModel {
    
    let actionButtonTitle: String
    let placeholderText: String
    var shouldShowReplyLabel: Bool
    var replyText: String? //これは、今回ならshouldShowReplyLabelがtrueじゃないと存在しないからoptional
    
    init(config: UploadTweetConfiguration) {
        switch config {
        case .tweet:
            actionButtonTitle = "Post"
            placeholderText = "あなたの意見を聞かせてください"
            shouldShowReplyLabel = false
        case .reply(let tweet):
            actionButtonTitle = "Reply"
            placeholderText = "Tweet your reply"
            shouldShowReplyLabel = true
            replyText = "Replying to @\(tweet.user.username)"
        }
    }
}
