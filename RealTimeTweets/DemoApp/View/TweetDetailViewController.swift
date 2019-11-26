//
//  TweetDetailViewController.swift
//  DemoApp
//
//  Created by Macbook on 24/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import UIKit
import SDWebImage

class TweetDetailViewController: UIViewController {
     
    // MARK: TableView IBOutlet
    @IBOutlet var detailTableView: UITableView!
    
    // MARK: Imageview IBOutlet
    @IBOutlet var profileImageView: UIImageView!
    
    var tweetId : Int = 0
    private var viewModelTweet = TweetDetailViewModel ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register closure observer method here
        observeEvents()
                        
        // Initialise Table view method
        intialiseTableView()
        
        // create request to fetch user and tweet details
        let tweetModelObj = TweetDetailRequestModel()
        tweetModelObj.TweetID = String(tweetId)
        viewModelTweet.initialiseTweetDetailAPI(tweetID: tweetModelObj)
    }
    
    // Back button handler method
    @IBAction func didTouchUpInsideBackButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private
    private func intialiseTableView()  {
             
           detailTableView?.estimatedRowHeight = 50
           detailTableView?.rowHeight = UITableView.automaticDimension
           detailTableView?.sectionHeaderHeight = 0
           detailTableView?.sectionFooterHeight = 0
           detailTableView?.allowsSelection = false
           detailTableView?.separatorStyle = .singleLine
           detailTableView?.dataSource = viewModelTweet
           detailTableView?.delegate = viewModelTweet
           detailTableView?.tableFooterView = UIView.init()
           detailTableView?.register(TweetTableViewCell.nib, forCellReuseIdentifier: TweetTableViewCell.identifier)
          
        }
    
    // Function to observe various event call backs from the viewmodel as well as Notifications.
    private func observeEvents() {
        viewModelTweet.reloadScreen = { tweetDetails, error in
                  
             if let errorMessage = error {
                print(errorMessage)
                return
             }
            self.detailTableView.reloadData()
            let imageURL = URL(string: (tweetDetails?.user.profileImageURLHTTPS)!)
             let setPlaceHolderImage = UIImage(named: "PlaceholderImage")
            guard let URL = imageURL else {
                DispatchQueue.main.async() {
                    self.profileImageView.image = setPlaceHolderImage
                }
                return
            }
            
            self.viewModelTweet.downloadImage(from: URL)
        }
        
        viewModelTweet.setProfileImage = { profileImage in
            
            DispatchQueue.main.async() {
                self.profileImageView.image = profileImage
            }
        
        }
    }

}
/*
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
*/
