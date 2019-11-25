//
//  ViewControllerModel.swift
//  DemoApp
//
//  Created by Macbook on 23/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import Foundation

//MARK: - Login API request model
class loginAPIRequestModel: NSObject {
    var callBackURL       : URL!
    var tweetsCount       : Int = 0
    var boundingBox       : String = ""
}

// MARK: - polygon Response Model
class PolygonResponseModel: NSObject {
    var boundingbox: [String] = []
}


