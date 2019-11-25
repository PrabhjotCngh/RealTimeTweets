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
    
    // Callback to pass data back to screen.
    var reloadScreenWithPolygonData: (_ streamResponse: PolygonResponseModel?, _ error: String?)->() = { _,_ in }
    
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
    
    //MARK: - fetch polygons from users current location
    func intialiseMethodToGetPolygon(with params: [String: Any])  {
        
        self.fetchPolygons(with: params) { (polygons, error) in
            
            guard let polygonValues = polygons  else {
                self.reloadScreenWithPolygonData(nil,error)
                return
            }
            
            self.reloadScreenWithPolygonData(polygonValues,nil)
            
        }
    }
       
    private func fetchPolygons(with params: [String: Any], completion: @escaping (_ polygonStr: PolygonResponseModel?, _ error: String?) -> ()) {
         
        NetworkManager().getPolygons(with: params) { (response, error) in
            
            guard let polygons = response else {
                    completion(nil,error)
                    return
            }
            
            completion(polygons,nil)
        }
    }
}
