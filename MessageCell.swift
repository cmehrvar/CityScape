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
    var chatKey = ""

    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var messageOutlet: UILabel!
    @IBOutlet weak var chatTypeImageOutlet: UIImageView!
    @IBOutlet weak var unreadViewOutlet: UIView!

    
    @IBAction func goToMessage(_ sender: AnyObject) {
        
        let scopeUID = uid
        let scopeChatKey = chatKey
        
        let scopeType = type
        let scopeFirstName = firstName
        let scopeLastName = lastName
        let scopeProfile = profile
        
        notificationController?.rootController?.toggleNotifications({ (bool) in
            
            if scopeType == "groupChats" {
                
                self.notificationController?.rootController?.toggleChat("groupChats", key: scopeChatKey, city: nil, firstName: nil, lastName: nil, profile: nil, completion: { (bool) in
                    
                    print("chat toggled", terminator: "")
                    
                })
                
            } else {
                
                self.notificationController?.rootController?.toggleChat(scopeType, key: scopeUID, city: nil, firstName: scopeFirstName, lastName: scopeLastName, profile: scopeProfile, completion: { (bool) in
                    
                    print("chat toggled", terminator: "")
                    
                })
            }
        })
    }
    
    func loadCell(_ data: [AnyHashable: Any]) {

        if let read = data["read"] as? Bool {
            
            if !read {

                self.unreadViewOutlet.alpha = 1
                
            } else {
                
                self.unreadViewOutlet.alpha = 0
                
            }
        }
     
        if let uid = data["uid"] as? String {
            
            self.uid = uid
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            ref.child("profilePicture").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                    
                    self.profile = profileString
                    self.profileOutlet.sd_setImage(with: url, placeholderImage: nil)

                }
            })
        }

        
        if let chatTitle = data["title"] as? String {
            
            nameOutlet.text = chatTitle
            
        }
        
        if let type = data["type"] as? String {
            
            self.type = type
            
            if type == "squad" || type == "groupChats" {
                
                chatTypeImageOutlet.image = UIImage(named: "enabledMessage")

                if type == "groupChats" {
                    
                    if let key = data["chatKey"] as? String {
                        
                        self.chatKey = key
                        
                        let ref = FIRDatabase.database().reference().child("groupChats").child(key)
                        
                        ref.child("groupPhoto").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if snapshot.exists() {
                                
                                if self.chatKey == key {
                                    
                                    if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                                        
                                        self.profileOutlet.sd_setImage(with: url, placeholderImage: nil)
                                        
                                    }
                                }
                                
                            } else {
                                
                                self.profileOutlet.image = UIImage(named: "icon")
                                
                            }
                        })
                    }
                }

            } else if type == "matches" {
 
                chatTypeImageOutlet.image = UIImage(named: "enabledMessage")

            }
        }
        
        if let firstName = data["firstName"] as? String, let lastName = data["lastName"] as? String {
            
            self.firstName = firstName
            self.lastName = lastName
            
            let name = firstName
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
