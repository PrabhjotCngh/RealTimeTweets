//
//  Helper.swift
//  DemoApp
//
//  Created by Macbook on 25/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import Foundation
import MBProgressHUD

class ProgressHud {
   static let sharedIndicator = ProgressHud()
    
   func displayPrgressHud(on view : UIView) {
     let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
     loadingNotification.mode = MBProgressHUDMode.indeterminate
     loadingNotification.label.text = "Loading"
   }
    
   func hideProgressHud(onView : UIView) {
       MBProgressHUD.hide(for: onView, animated: true)
   }
}
