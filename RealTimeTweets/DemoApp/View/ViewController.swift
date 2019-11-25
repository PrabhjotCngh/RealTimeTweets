//
//  ViewController.swift
//  DemoApp
//
//  Created by Macbook on 23/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//


import UIKit
import Swifter
import SafariServices

class ViewController: UIViewController,SFSafariViewControllerDelegate {

    private var loginViewModel = ViewControllerViewModel ()
    var boundingBoxStr: String?
    override func viewDidLoad() {
           super.viewDidLoad()
            // Register closure observer method
            observeEvents()
            boundingBoxStr = ""
            // Show loader
            ProgressHud.sharedIndicator.displayPrgressHud(on: self.view)
        
            // Register to receive location notification
            NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(_:)), name: NSNotification.Name(rawValue: "LocationUpdates"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func methodOfReceivedNotification(_ notification: NSNotification)  {
           if let dictInfo = notification.userInfo  as NSDictionary? {
               guard let setCity = dictInfo["city"] as? String else {
                      print("failed to get location")
                   return
               }
               
               let requestModel = [ "q" : setCity, "polygon_geojson" : 0, "format" : "json"] as [String : Any]
               self.loginViewModel.intialiseMethodToGetPolygon(with: requestModel)

           }
       }
    
    // Twitter login handler method
     @IBAction func didTouchUpInsideLoginButton(_ sender: AnyObject) {
        // First ask user about number of tweets he/she want to fetch from API request
        self.numberOfTweetToFetch()
     }
    
    // Function to observe various event call backs from the viewmodel as well as Notifications.
    private func observeEvents() {
              
        loginViewModel.reloadScreen = { isLoggingIn, streamAPIResponse, error in
                 
               if let errorMessage = error {
                 print(errorMessage)
                 return
               }
               
               if let checker = isLoggingIn {
                   if checker {
                     // login Success, now navigate to next screen
                    self.performSegue(withIdentifier: "showMap", sender: self)
                   }
               }
            
               // Send notification to map view on getting response from live tweet stream API 
               if let response = streamAPIResponse {
                     let userInfoDetails = ["APIResponse": response] as [String : [ResponseModel]]
                     NotificationCenter.default.post(name: Notification.Name("updateMapWithStreamAPIData"), object: nil, userInfo: userInfoDetails)
                     
               }
          }
        
        loginViewModel.reloadScreenWithPolygonData = { polygons, error in

               guard let boundingBox = polygons else {
                      print("error in polygon")
                      return
               }
               
               let firstLong  = boundingBox.boundingbox[2]
               let firstLat   = boundingBox.boundingbox[0]
               let secondLong = boundingBox.boundingbox[3]
               let secondLat  = boundingBox.boundingbox[1]
            
               self.boundingBoxStr = "\(firstLong),\(firstLat),\(secondLong),\(secondLat)"
               DispatchQueue.main.async() {
                  // hide loader
                  ProgressHud.sharedIndicator.hideProgressHud(onView: self.view)
               }
        }
    }
    
    func numberOfTweetToFetch() {
       
           self.showAlertFromHome(title: "Please input the number of tweets you want to fetch! \n NOTE: The greater number you will enter, the more time it will take to fetch the real time tweets.", placeholder: "Enter Here...", "Get Tweets!")
       }
       
    func showAlertFromHome(title : String, placeholder : String, _ buttonTitle: String?) {
                     
            // create the alert
            let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
                     
            alert.addTextField { (textField) in
                    textField.placeholder = placeholder
                    textField.keyboardType = .numberPad
            }
               
            alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
                        let textField = alert.textFields![0]
                        let trimmedStr = textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        if trimmedStr.isEmpty {
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                
                        // Take user input and then call API
                        let url = URL(string: "DemoApp://success")!
                        let createRequestModel = loginAPIRequestModel()
                        createRequestModel.callBackURL = url
                        createRequestModel.tweetsCount = Int(trimmedStr)!
                        createRequestModel.boundingBox = self.boundingBoxStr!
                        self.loginViewModel.intialiseTwitterLoginCall(with: createRequestModel, withViewController: self)
                             
                }))
                                       
            self.present(alert, animated: true, completion: nil)
        
       }
    
    // Dismiss safari after login and Call back to application
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
          controller.dismiss(animated: true, completion: nil)
    }

}

