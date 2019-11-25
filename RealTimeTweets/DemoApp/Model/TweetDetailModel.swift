//
//  TweetDetailModel.swift
//  DemoApp
//
//  Created by Macbook on 24/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import Foundation

// MARK: - Main request body
class TweetDetailRequestModel: NSObject {
    var TweetID    : String = ""
}

// MARK: - Main response body
class TweetDetailResponseModel: NSObject {
    var user: User = User()
    var favorited: Bool  = false
    var fullText: String = ""
    var createdAt: String = ""
    
    enum CodingKeys: String, CodingKey {
        case user, favorited
        case fullText = "full_text"
        case createdAt = "created_at"
    }
}

// MARK: - User
class User: NSObject {
    var followersCount = 0, friendsCount: Int = 0
    var location = "", name: String = ""
    var profileImageURLHTTPS: String = ""
    var idStr: String = ""

    enum CodingKeys: String, CodingKey {
        case followersCount = "followers_count"
        case friendsCount = "friends_count"
        case location, name
        case createdAt = "created_at"
        case profileImageURLHTTPS = "profile_image_url_https"
        case idStr = "id_str"
    }
}

