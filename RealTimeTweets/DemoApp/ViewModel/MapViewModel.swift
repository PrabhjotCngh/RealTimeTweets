//
//  MapViewModel.swift
//  DemoApp
//
//  Created by Macbook on 24/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import Foundation
import UIKit

class MapViewModel : NSObject{
    
    /*
    // Callback to reload the screen.
    var reloadScreen: (_ tweetData: [TweetModel]?, _ error: String?)->() = { _,_ in }
    
    
    // Method calls to inform the view model to fetch live tweets.
    func intialiseCall(requestParams: APIRequestModel){
        
        self.fetchTweets(withAPI: requestParams, completion: { tweetRecords, error in
            
            if let error = error {
                self.reloadScreen(nil,error)
                return
            }
            
            self.reloadScreen(tweetRecords,nil)
        })

    }
    
    private func fetchTweets(withAPI model: APIRequestModel,completion: @escaping (_ tweetData: [TweetModel]?, _ error:String?)->()) {
        
        NetworkManager().fetchStreamTweets(withModel: model) { (response, error) in
            
            guard let responseModel = response else {
                print(error!)
                return
            }
            
            print(responseModel)
        }
    }
    */
}
