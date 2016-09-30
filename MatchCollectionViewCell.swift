//
//  MatchCollectionViewCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-27.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MatchCollectionViewCell: UICollectionViewCell {
    
    weak var messagesController: MessagesController?
    
    var index = 0
    var uid = ""
    var firstName = ""
    var lastName = ""
    var profileString = ""
    
    //Outlets
    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var indicatorOutlet: UIView!

    //Actions
    @IBAction func openChat(sender: AnyObject) {
        
        
        
        let scopeUID = uid
        let scopeFirstname = firstName
        let scopeLastname = lastName
        let scopeProfile = profileString
        
        self.messagesController?.rootController?.toggleChat("matches", key: scopeUID, city: nil, firstName: scopeFirstname, lastName: scopeLastname, profile: scopeProfile, completion: { (bool) in
            
            print("chat toggled")
            
        })
        
        
    }
    

    //Functions
    func loadCell(data: [NSObject : AnyObject]){
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        
        
        
        
        if let uid = data["uid"] as? String {
            
            self.uid = uid
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            ref.child("profilePicture").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                        
                        self.profileString = profileString
                        self.profileOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                        
                    }
                }
            })
 
            ref.child("online").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let online = snapshot.value as? Bool {
                        
                        if online {
                            
                            self.indicatorOutlet.backgroundColor = UIColor.greenColor()
                            
                        } else {
                            
                            self.indicatorOutlet.backgroundColor = UIColor.redColor()
                            
                        }
                    }
                }
            })
        }
        
        
        
        if let read = data["read"] as? Bool {
            
            if read {
                
                nameOutlet.font = UIFont.systemFontOfSize(14)
                nameOutlet.textColor = UIColor.darkGrayColor()
                
            } else {
                
                nameOutlet.font = UIFont.boldSystemFontOfSize(14)
                nameOutlet.textColor = UIColor.blackColor()
                
            }

        } else {
            
            
            nameOutlet.font = UIFont.systemFontOfSize(14)
            nameOutlet.textColor = UIColor.darkGrayColor()
            
            
        }
        
        

        if let firstName = data["firstName"] as? String {
            
            self.firstName = firstName
            nameOutlet.text = firstName
            
        }
        
        if let lastName = data["lastName"] as? String {
            
            self.lastName = lastName

        }
    }

    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
