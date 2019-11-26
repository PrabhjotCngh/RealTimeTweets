//
//  NetworkManager.swift
//  DemoApp
//
//  Created by Macbook on 23/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import Foundation
import Swifter

let kConsumerAPIKey     = "0WSjh9IePr3deze6KZcx1EEKR"
let kConsumerSecretKey  = "tBpnXA0g4UsZNJVgCPuW36YQSvM403j9p3YQE071qrT9LDILxx"

struct NetworkManager {
    
    static let environment : NetworkEnvironment = .test
    let router = Router<WebApiType>()
    
    // Initialise Swifter with API keys
    private var swifter = Swifter(
                 consumerKey: kConsumerAPIKey,
                 consumerSecret: kConsumerSecretKey)
    
    // Error handler for try catch block
    enum NoKeyFoundError: Error {
          case missing(String)
    }
    
    // MARK: Make login API request
    func login(with requestModel: loginAPIRequestModel, viewcontroller: UIViewController, completion: @escaping(_ loginSuccess: Bool?, _ response: [ResponseModel]?,_ error:String?)->()) {
        
        swifter.authorize(withCallback: requestModel.callBackURL!, presentingFrom: viewcontroller, success:{ _, _ in
            
             //Call twitter API before authorization expires
            self.callTwitterAPIToGetTweets(with: requestModel) { (response, error) in

                guard let readResponse = response else {
                    print("response nil")
                    return
                }
                completion(nil, readResponse, nil)
            }
            completion(true,nil,nil)
        }, failure:{ error in
            completion(nil,nil,error.localizedDescription)
        })
       
    }
    
    // MARK: Initialise request to fetch latest tweets
    func callTwitterAPIToGetTweets(with model: loginAPIRequestModel, completion: @escaping(_ response: [ResponseModel]?, _ error:String?)->()) {
        
        let initialiseRequestModel = APIRequestModel()
        initialiseRequestModel.apiPath = "statuses/filter.json"
        initialiseRequestModel.baseURL = .stream
        initialiseRequestModel.params = ["locations":model.boundingBox]
        initialiseRequestModel.requestCounter = model.tweetsCount
        
        self.fetchStreamTweets(withModel: initialiseRequestModel) { (response, error) in
            guard let handleResponse = response else {
                print("no object returned")
                return
            }
            
            completion(handleResponse, nil)
                
        }
        
    }
    
    // MARK: Make API request to fetch latest tweets
    func fetchStreamTweets(withModel: APIRequestModel,completion: @escaping(_ response: [ResponseModel]?, _ error:String?)->()) {
        
        var counter = 0
        var saveResponse: [ResponseModel] = []
        swifter.client.get(withModel.apiPath, baseURL: withModel.baseURL, parameters: withModel.params, uploadProgress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
            
        }, downloadProgress: { (data, totalBytesReceived, totalBytesExpectedToReceive, response) in
            counter += 1
            print(counter)
            self.streamTweetsResponseHandlerMethod(responseData: data) { (response, error) in
                
                guard let model = response else {
                    print("error")
                    return
                }
                saveResponse.append(model)
                //completion(saveResponse,nil)
            }
            
            if counter == withModel.requestCounter {
                completion(saveResponse,nil)
                //DispatchQueue.global().suspend()
            }
           
                       
        }, success: { (data, response) in
        }) { (error) in
            print(error.localizedDescription)
        }
    
   }

    // MARK: Latest tweets API response handler method
   func streamTweetsResponseHandlerMethod(responseData: Data,completion: @escaping(_ response: ResponseModel?, _ error:String?)->()) {
    
    do {
        // make sure this JSON is in the format we expect
        if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
            // try to read out a string array
            //print(json)
            // Extract Tweeet
            guard let tweetText = json["text"] as? String  else {
                throw NoKeyFoundError.missing("text")
            }
            
            // Extract tweet id
            guard let tweetId = json["id"] as? Int else {
                throw NoKeyFoundError.missing("id")
            }
            
            // Extract place
            guard let place = json["place"] as? NSDictionary else {
                throw NoKeyFoundError.missing("place")
                // handle code
            }
            
            // Extract bounding_box
            guard let boundingBox = place["bounding_box"] as? NSDictionary else {
                throw NoKeyFoundError.missing("bounding_box")
            }
            
            // Extract coordinates
            guard let coordinates = boundingBox["coordinates"] as? NSArray else {
                throw NoKeyFoundError.missing("coordinates")
            }
            
            // Extract latLongArray
            guard let latLongArray = coordinates[0] as? NSArray else {
                throw NoKeyFoundError.missing("latLongArray")
            }
            
            // Extract latLongInnerArray
            guard let latLongInnerArray = latLongArray.firstObject as? NSArray else {
                throw NoKeyFoundError.missing("latLongInnerArray")
            }
            
            // Extract latitude
            guard let latStr = latLongInnerArray[1] as? Double else {
                throw NoKeyFoundError.missing("latitude")
            }
            
            // Extract longitude
            guard let longStr = latLongInnerArray[0] as? Double else {
                throw NoKeyFoundError.missing("longitude")
            }
            
            let model = ResponseModel(tweetText: tweetText, tweetId: tweetId, latitude: latStr, longitude: longStr)
            completion(model,nil)
            
        }
    } catch let error as NSError {
        print("Failed to load: \(error.localizedDescription)")
        completion(nil,error.localizedDescription)
    }

    }
    
    // MARK: Fetch tweet details from tweet ID
    func tweetDetails(withAPI Request: TweetDetailRequestModel, completion: @escaping(_ response: TweetDetailResponseModel?, _ error:String?)->()) {
         
        swifter.getTweet(for: Request.TweetID, trimUser: false, includeMyRetweet: false, includeEntities: false, includeExtAltText: false, tweetMode: .extended, success: { jsonResponse in
            
            // Parse response
            self.tweetDetailResponseHandlerMethod(responseJSONData: jsonResponse) { (responseModel, error) in
                guard let modelObj = responseModel else {
                    //print(error!)
                    return
                }
                completion(modelObj,nil)
            }
  
        }, failure:{ error in
            completion(nil,error.localizedDescription)
        })
    }
    
    // MARK: Latest tweets API response handler method
    func tweetDetailResponseHandlerMethod(responseJSONData: JSON,completion: @escaping(_ response: TweetDetailResponseModel?, _ error:String?)->()) {
        do {
            
            // Extract user
            guard let user = responseJSONData["user"].object  else {
                throw NoKeyFoundError.missing("user")
            }
            
            // Extract user followers count
            guard let followersCount = user["followers_count"]?.integer else {
                throw NoKeyFoundError.missing("followers_count")
            }
            
            // Extract user friends count
            guard let friendsCount = user["friends_count"]?.integer else {
                throw NoKeyFoundError.missing("friends_count")
            }
            
            // Extract user location
            guard let userLocation = user["location"]?.string else {
                throw NoKeyFoundError.missing("location")
            }
            
            // Extract user name
            guard let username = user["name"]?.string else {
                throw NoKeyFoundError.missing("name")
            }

            // Extract user profile image URL 
            guard let profileImageurl = user["profile_image_url_https"]?.string else {
                throw NoKeyFoundError.missing("profile_image_url_https")
            }
            
            // Extract user id string
            guard let userID = user["id_str"]?.string else {
                throw NoKeyFoundError.missing("id_str")
            }
            
            let userData = User()
            userData.followersCount  = followersCount
            userData.friendsCount    = friendsCount
            userData.location        = userLocation
            userData.name            = username
            userData.profileImageURLHTTPS = profileImageurl
            userData.idStr           = userID
           
            let responseModelObj     = TweetDetailResponseModel()
            responseModelObj.user    = userData
            
            
            // Extract user favourite status
            guard let favoritStatus = responseJSONData["favorited"].bool else {
                throw NoKeyFoundError.missing("favorited")
            }
            
            // Extract user favourite status
            guard let createdAt = responseJSONData["created_at"].string else {
                  throw NoKeyFoundError.missing("created_at")
            }
            
            // Extract user tweet description
            guard let tweetDescription = responseJSONData["full_text"].string else {
                throw NoKeyFoundError.missing("full_text")
            }
            
            responseModelObj.favorited = favoritStatus
            responseModelObj.fullText  = tweetDescription
            responseModelObj.createdAt = createdAt
            
            completion(responseModelObj,nil)
            
        } catch let error as NSError {
               print("Failed to load: \(error.localizedDescription)")
               completion(nil,error.localizedDescription)
           }
        
    }

    //MARK: Download user image
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    //MARK: API call to get polygons from users current location
    func getPolygons(with params:[String: Any], completion: @escaping(_ polgons: PolygonResponseModel?,_ error:String?)->()) {
        
        router.request(.polygonEndPoints(urlParams: params)) { (data, response, error) in
            
            self.polygonResponseHandlerMethod(with: data!) { (response, error) in
                
                guard let modelResponse = response else {
                    print("error")
                    return
                }
                completion(modelResponse,nil)
            }
        }
        
    }
    
    // MARK: Latest tweets API response handler method
    func polygonResponseHandlerMethod(with responseData: Data,completion: @escaping(_ response: PolygonResponseModel?, _ error:String?)->()) {
       
         do {
           // make sure this JSON is in the format we expect
           if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? NSArray {
               // try to read out a string array
            
               // Extract main json
                guard let jsonDict = json[0] as? NSDictionary else {
                      throw NoKeyFoundError.missing("MainJson")
                }
            
                // Extract boundingbox
                guard let boundingArray = jsonDict["boundingbox"] as? [String] else {
                      throw NoKeyFoundError.missing("boundingbox")
                }
            
                
                let responseModelObj           = PolygonResponseModel()
                responseModelObj.boundingbox   = boundingArray
                completion(responseModelObj,nil)
               }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                completion(nil,error.localizedDescription)
            }
        }
}


