//
//  MessageCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-16.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class MessageCell: UITableViewCell {
    
    weak var notificationController: NotificationController?
    
    var profile = ""
    var firstName = ""
    var lastName = ""
    var type = ""
    var uid = ""

    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var messageOutlet: UILabel!
    @IBOutlet weak var chatTypeImageOutlet: UIImageView!

    
    @IBAction func goToMessage(sender: AnyObject) {
        
        let scopeUID = uid
        let scopeType = type
        let scopeFirstName = firstName
        let scopeLastName = lastName
        let scopeProfile = profile
        
        notificationController?.rootController?.toggleNotifications({ (bool) in

            self.notificationController?.rootController?.toggleChat(scopeType, userUID: scopeUID, postUID: nil, city: nil, firstName: scopeFirstName, lastName: scopeLastName, profile: scopeProfile, completion: { (bool) in
                
                print("chat toggled")
                
            })
        })
    }
    
    
    
    
    func loadCell(data: [NSObject : AnyObject]) {

        if let read = data["read"] as? Bool {
            
            if !read {
                
                self.backgroundColor = UIColor.yellowColor()
                
            } else {
                
                self.backgroundColor = UIColor.whiteColor()
                
            }
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

        if let type = data["type"] as? String {
            
            self.type = type
            
            if type == "squad" {
                
                chatTypeImageOutlet.image = UIImage(named: "sendSquad")

            } else if type == "matches" {
 
                chatTypeImageOutlet.image = UIImage(named: "sendMatch")

            }
        }
        
        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {
            
            self.firstName = firstName
            self.lastName = lastName
            
            let name = firstName + " " + lastName
            nameOutlet.text = name
            
        }
        
        if let text = data["text"] as? String {
            
            messageOutlet.text = text
            
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
