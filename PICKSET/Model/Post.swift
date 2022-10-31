//
//  Post.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/17.
//

import Foundation
import Firebase

struct Post {
    let timestamp: Date!
    let topic: String
    let uid: String
    var vote: Int
    var description: String?
}
