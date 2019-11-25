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

    override func viewDidLoad() {
           super.viewDidLoad()
           // Register closure observer method
           observeEvents()
           
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
                        self.loginViewModel.intialiseTwitterLoginCall(with: createRequestModel, withViewController: self)
                             
                }))
                                       
            self.present(alert, animated: true, completion: nil)
        
       }
    
    // Dismiss safari after login and Call back to application
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
          controller.dismiss(animated: true, completion: nil)
    }

}

