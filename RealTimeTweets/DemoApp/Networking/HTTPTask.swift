//
//  HTTPTask.swift
//  DemoApp
//
//  Created by Macbook on 25/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import Foundation
import Alamofire

public enum HTTPTask {
    case upload
    
    case requestWith(bodyParameters: Parameters?, urlParameters : Parameters?)
    
    case request
}
