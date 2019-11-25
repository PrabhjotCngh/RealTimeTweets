//
//  EndPointType.swift
//  DemoApp
//
//  Created by Macbook on 25/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import Foundation
import Alamofire

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}
