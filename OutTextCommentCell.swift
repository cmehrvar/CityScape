//
//  OutTextCommentCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-01.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class OutTextCommentCell: UITableViewCell {
    
    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var textOutlet: UILabel!
    
    func loadData(data: [String : AnyObject?]) {
        
        if let profileURLString = data["profilePic"] as? String, profileURL = NSURL(string: profileURLString) {
            
            profileOutlet.sd_setImageWithURL(profileURL, placeholderImage: nil)
            
        }
        
        textOutlet.text = data["text"] as? String
        
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
