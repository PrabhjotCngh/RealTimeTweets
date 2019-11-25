//
//  WebAPIEndPoints.swift
//  DemoApp
//
//  Created by Macbook on 25/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkEnvironment {
    case test
    case prod
    case dev
}

public enum WebApiType {
    case polygonEndPoints(urlParams: [String: Any])
}

extension WebApiType: EndPointType {

    var environmentBaseURL : String {
        switch self {
        case .polygonEndPoints:
            return "https://nominatim.openstreetmap.org/"
        }
    }

    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .polygonEndPoints:
            return "search.php"
        }
    }
       
    var httpMethod: HTTPMethod {
        switch self {
        case .polygonEndPoints:
            return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .polygonEndPoints(let urlParams):
            return .requestWith(bodyParameters: nil, urlParameters: urlParams)
        }
    }
      
    var headers: HTTPHeaders? {
        switch self {
        case .polygonEndPoints:
            return nil
        }
    }
}
