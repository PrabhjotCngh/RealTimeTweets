//
//  TweetTableViewCell.swift
//  DemoApp
//
//  Created by Macbook on 24/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var cellTextLabel: UILabel!
    @IBOutlet weak var cellDetailTextLabel: UILabel!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
          
    static var identifier: String {
        return String(describing: self)
    }
          
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
