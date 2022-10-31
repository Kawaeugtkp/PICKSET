//
//  Constants.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import Firebase
import FirebaseAuth
import FirebaseStorage

let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_TWEETS = DB_REF.child("tweets")
let REF_USER_TWEETS = DB_REF.child("user-tweets")
let REF_USER_FOLLOWERS = DB_REF.child("user-followers")
let REF_USER_FOLLOWING = DB_REF.child("user-following")
let REF_OPINION_REPLIES = DB_REF.child("opinion-replies")
let REF_USER_LIKES = DB_REF.child("user-likes")
let REF_TWEET_LIKES = DB_REF.child("tweet-likes")
let REF_NOTIFICATIONS = DB_REF.child("notifications")
let REF_USER_REPLIES = DB_REF.child("user-replies")
let REF_USER_USERNAMES = DB_REF.child("user-usernames")
let REF_POST = DB_REF.child("post")
let REF_USER_POSTS = DB_REF.child("user-posts")
let REF_OPS = DB_REF.child("ops")
let REF_USER_OPS = DB_REF.child("user-ops")
let REF_POST_SETS = DB_REF.child("post-sets")
let REF_USER_SETS = DB_REF.child("user-sets")
let REF_POST_SETUSERS = DB_REF.child("post-setusers")
let REF_USER_OPINIONS = DB_REF.child("user-opinions")
let REF_POST_OPINIONS = DB_REF.child("post-opinions")
let REF_SETUSERS_OPINIONS = DB_REF.child("setusers-opinions")
let REF_USER_SELECTED = DB_REF.child("user-selected")
let REF_POST_SELECTED = DB_REF.child("post-selected")
let REF_POST_USERS = DB_REF.child("post-users")
let REF_OPINION_LIKES = DB_REF.child("opinion-likes")
let REF_USER_POSTLIKES = DB_REF.child("user-postlikes")
let REF_CATEGORIES = DB_REF.child("categories")
let REF_SAVEOPS = DB_REF.child("saveops")
let REF_USERSAVES = DB_REF.child("usersaves")
