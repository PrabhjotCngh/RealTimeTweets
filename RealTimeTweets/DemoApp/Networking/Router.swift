//
//  Router.swift
//  DemoApp
//
//  Created by Macbook on 25/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import Foundation
import Alamofire

public typealias NetworkRouterCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Error?)->()

protocol NetworkRouter: class {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
    func cancel()
}

/// A class to make API requests using Alamofire.
struct APIManager {
    static let sharedManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120
        return Alamofire.SessionManager(configuration: configuration)
    }()
}

class Router<EndPoint: EndPointType>: NetworkRouter {

     var apiManager = APIManager.sharedManager
    

    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        do {
            let (request,params) = try self.buildRequest(from: route)
            
            self.apiManager.request(request.url!, method: route.httpMethod, parameters: params, encoding: URLEncoding.default, headers: request.allHTTPHeaderFields).responseString(completionHandler: {response in
                switch response.result {
                case .success( _):
                    completion(response.data, response.response, response.error)
                    break
                case .failure(let error):
                    completion(response.data, response.response, error)
                    break
                }
            })
        }
        catch {
            
        }
        
    }
    
    private func buildRequest(from route : EndPoint) throws -> (URLRequest, Parameters) {
        var urlRequest = URLRequest(url: route.baseURL.appendingPathComponent(route.path), cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
        urlRequest.httpMethod = route.httpMethod.rawValue
        if route.headers != nil {
            urlRequest.allHTTPHeaderFields = route.headers
        }
        var params : Parameters = [:]
        switch route.task {
        case .request:
            break
        case .requestWith(let bodyParameters, let urlParameters):
            if bodyParameters != nil {
                for key in (bodyParameters?.keys)! {
                    params[key] = bodyParameters![key]!
                }
            }
            else {
                var req : URLRequestConvertible = urlRequest
                do {
                    urlRequest = try configureParameters(bodyParams: bodyParameters, urlParams: urlParameters, request: &req)
                }
                catch{}
            }
            break
        default:
            break
        }
        return (urlRequest, params)
    }
    
    func cancel() {
        
    }
    
    private func configureParameters(bodyParams:Parameters?, urlParams: Parameters?, request: inout URLRequestConvertible) throws -> URLRequest {
        do {
            if let bodyParams = bodyParams {
                request = try JSONEncoding.default.encode(request, with: bodyParams)
            }
            if let urlParams = urlParams {
                request = try URLEncoding.queryString.encode(request, with: urlParams)
            }
            return request as! URLRequest
        }
        catch {
            throw error
        }
    }
    
    
}
