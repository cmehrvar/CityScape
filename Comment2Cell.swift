//
//  Comment2Cell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-17.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class Comment2Cell: UITableViewCell {
    
    @IBOutlet weak var inProfileOutlet: UIImageView!
    @IBOutlet weak var inTextOutlet: UILabel!
    @IBOutlet weak var inNameOutlet: UILabel!
    @IBOutlet weak var inTextBubble: TextBubble!
    @IBOutlet weak var outNameOutlet: UILabel!
    @IBOutlet weak var outTextOutlet: UILabel!
    @IBOutlet weak var outProfileOutlet: UIImageView!
    @IBOutlet weak var outTextBubble: TextBubble!
    
    func loadData(data: [String:String?]){
        
        if let inName = data["inName"] {
            self.inNameOutlet.text = inName
        } else {
            self.inNameOutlet.text = ""
        }
        
        if let inText = data["inText"] {
            self.inTextOutlet.text = inText
            self.inTextBubble.backgroundColor = UIColor(red: 192, green: 192, blue: 192)
            
        } else {
            self.inTextOutlet.text = ""
            self.inTextBubble.backgroundColor = .None
        }
        
        if let profileString = data["inProfilePic"]{
            
            if let actualString = profileString, profileUrl = NSURL(string: actualString) {
                
                self.inProfileOutlet.sd_setImageWithURL(profileUrl, placeholderImage: nil)
                
                
            } else {
                
                self.inProfileOutlet.image = nil
                
            }
            
        } else {
            
            self.inProfileOutlet.image = nil
            
        }
        
        if let outName = data["outName"] {
            self.outNameOutlet.text = outName
        } else {
            self.outNameOutlet.text = ""
        }
        
        if let outText = data["outText"] {
            self.outTextOutlet.text = outText
            self.outTextBubble.backgroundColor = UIColor(red: 0, green: 122, blue: 255)
            
        } else {
            self.outTextOutlet.text = ""
            self.outTextBubble.backgroundColor = .None
        }
        
        
        if let profileString = data["outProfilePic"]{
            
            if let actualString = profileString, profileUrl = NSURL(string: actualString) {
                
                self.outProfileOutlet.sd_setImageWithURL(profileUrl, placeholderImage: nil)
                
                
            } else {
                
                self.outProfileOutlet.image = nil
                
            }
            
        } else {
            
            self.outProfileOutlet.image = nil
            
        }

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
