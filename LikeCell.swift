//
//  LikeCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-16.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class LikeCell: UITableViewCell {

    weak var notificationController: NotificationController?
    
    var uid = ""
    var firstName = ""
    var lastName = ""
    var profile = ""
    
    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var unreadViewOutlet: UIView!
    
    
    @IBAction func goToChat(sender: AnyObject) {
        
        let scopeUID = uid
        let scopeFirstName = firstName
        let scopeLastName = lastName
        let scopeProfile = profile
        
        notificationController?.rootController?.toggleNotifications({ (bool) in
            
            self.notificationController?.rootController?.toggleChat("matches", key: scopeUID, city: nil, firstName: scopeFirstName, lastName: scopeLastName, profile: scopeProfile, completion: { (bool) in
                
                print("chat toggled", terminator: "")
                
            })
        })
    }
    
    
    func loadData(data: [NSObject : AnyObject]){
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .AlignCenters
        
        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {
            
            self.firstName = firstName
            self.lastName = lastName
            
            let name = firstName 
            
            nameOutlet.text = name
        }

        if let uid = data["uid"] as? String {
            
            self.uid = uid
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            ref.child("profilePicture").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                    
                    self.profile = profileString
                    self.profileOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                    
                }
            })
        }
        
        
        if let read = data["read"] as? Bool {
            
            if !read {
                
                self.unreadViewOutlet.alpha = 1
                
            } else {
                
                self.unreadViewOutlet.alpha = 0
                
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .AlignCenters
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
