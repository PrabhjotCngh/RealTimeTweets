//
//  ViewControllerViewModel.swift
//  DemoApp
//
//  Created by Macbook on 23/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import UIKit
class ViewControllerViewModel : NSObject{
        
    // Callback to reload the login screen.
    var reloadScreen: (_ success: Bool?, _ streamResponse: [ResponseModel]?, _ error: String?)->() = { _,_,_ in }
    
    // Method calls to inform the view model to login.
    func intialiseTwitterLoginCall(with RequestModel: loginAPIRequestModel, withViewController: UIViewController){
        
        self.authoriseUser(with: RequestModel, passViewController: withViewController,completion: { isUserLoggedIn, liveStreamData, error in
            
            if let error = error {
                self.reloadScreen(nil,nil,error)
                return
            }
            
            self.reloadScreen(isUserLoggedIn,liveStreamData,nil)
        })

    }
    
    private func authoriseUser(with requestModel: loginAPIRequestModel, passViewController: UIViewController,completion: @escaping (_ success: Bool?,_ streamModel: [ResponseModel]?, _ error:String?)->()) {
        
        NetworkManager().login(with: requestModel, viewcontroller: passViewController) { (success, streamTweetData, error) in
            
            guard let isLoggedIn = success else {
                
                guard let tweetData = streamTweetData else {
                    completion(false,nil,error)
                    print("error logging in..")
                    return
                }
                
                completion(nil,tweetData,nil)
                return
            }
            completion(isLoggedIn,nil,nil)
            
        }
      
    }
}
