//
//  TweetViewModel.swift
//  DemoApp
//
//  Created by Macbook on 24/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import Foundation
import UIKit

class TweetDetailViewModel : NSObject{
    
    // Callback to reload the tweet details screen.
    var reloadScreen: (_ tweetDetailModel: TweetDetailResponseModel?, _ error: String?)->() = { _,_ in }
    
    // Callback to pass profile image to the controller
    var setProfileImage: (_ image: UIImage) ->() = { _ in }
    
    // Object to save stream API response to pass it to tableview
    var tableViewData: TweetDetailResponseModel?
    
    //MARK: - Fetch details of user by passing tweet id
    func initialiseTweetDetailAPI(tweetID: TweetDetailRequestModel)  {
        self.fetchTweetDetail(withTweet: tweetID, completion: { detailModelResponse, error in
            
            if let error = error {
                self.reloadScreen(nil,error)
                return
            }
            
            // Save response locally in object
            self.tableViewData = detailModelResponse
            
            // Update view controller
            self.reloadScreen(detailModelResponse,nil)
        })
    }
    
    private func fetchTweetDetail(withTweet ID: TweetDetailRequestModel,completion: @escaping (_ tweetDetails: TweetDetailResponseModel?, _ error:String?)->()) {
        
        NetworkManager().tweetDetails(withAPI: ID) { (tweetDetailsData, error) in
             
            guard let detailModelObj = tweetDetailsData else {
                print(error as Any)
                completion(nil, error)
                return
            }
            completion(detailModelObj, nil)
        }
        
    }
    
    //MARK: - Download user profile Image method
    func downloadImage(from url: URL) {
        NetworkManager().getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let downloadedImage = UIImage(data: data)
            self.setProfileImage(downloadedImage!)
           
        }
    }
}

extension TweetDetailViewModel: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
     }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let _ = tableViewData else {
            return 0
        }
        return 6
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let userData = tableViewData else {
            return UITableViewCell()
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as? TweetTableViewCell {
              switch indexPath.row {
                     case 0:
                          cell.cellTextLabel.text       = "Username"
                          cell.cellDetailTextLabel.text = userData.user.name
                     case 1:
                          cell.cellTextLabel.text       = "Location"
                          cell.cellDetailTextLabel.text = userData.user.location
                     case 2:
                          cell.cellTextLabel.text       = "Friends"
                          cell.cellDetailTextLabel.text = "\(String(describing: userData.user.friendsCount))"
                     case 3:
                          cell.cellTextLabel.text       = "Followers"
                          cell.cellDetailTextLabel.text = "\(String(describing: userData.user.followersCount))"
                     case 4:
                          cell.cellTextLabel.text       = "Tweet Date/Time"
                          cell.cellDetailTextLabel.text = userData.createdAt
                     case 5:
                          cell.cellTextLabel.text       = "Tweet"
                          cell.cellDetailTextLabel.text = userData.fullText
                     default: break
             }
             
             return cell
        }
        
         return UITableViewCell()
    }

}

extension TweetDetailViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
