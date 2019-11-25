//
//  MapModel.swift
//  DemoApp
//
//  Created by Macbook on 24/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import Foundation
import Swifter

//MARK: - Stream API request model
class APIRequestModel: NSObject {
    var apiPath           : String = ""
    var baseURL           : TwitterURL = .stream
    var params            : [String: Any] = [:]
    var requestCounter    : Int = 0
}

//MARK: - Stream API response model
class ResponseModel: NSObject {
    let tweetText     : String
    let tweetId       : Int
    let latitude      : Double
    let longitude     : Double
    
    init(tweetText: String, tweetId: Int, latitude: Double,  longitude: Double) {
        self.tweetText       = tweetText
        self.tweetId         = tweetId
        self.latitude        = latitude
        self.longitude       = longitude
    }
}
