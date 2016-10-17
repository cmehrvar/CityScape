//
//  MessageTableCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-25.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MessageTableCell: UITableViewCell {

    weak var messagesController: MessagesController?
    
    var uid = ""
    var profile = ""
    var firstName = ""
    var lastName = ""
    var type = ""
    
    @IBOutlet weak var profileOutlet: MessageProfileView!
    @IBOutlet weak var onlineIndicatorOutlet: UIView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var textOutlet: UILabel!
    @IBOutlet weak var typeIndicatorImageOutlet: UIImageView!

    @IBAction func goToMessage(_ sender: AnyObject) {
 
        messagesController?.rootController?.toggleChat(type, key: uid, city: nil, firstName: firstName, lastName: lastName, profile: profile, completion: { (bool) in
            
            print("chat toggled", terminator: "")
            
        })
    }

    
    func loadCell(_ data: [AnyHashable: Any]) {
        
        var scopeUID = ""
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .alignCenters
  
        if let read = data["read"] as? Bool {
            
            if read {
                
                nameOutlet.font = UIFont(name: "ProximaNovaSoft-Regular", size: 25)
                nameOutlet.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
                
                textOutlet.font = UIFont(name: "ProximaNovaSoft-Regular", size: 17)
                textOutlet.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
                
                
                
            } else {
                
                nameOutlet.font = UIFont(name: "ProximaNovaSoftW03-Semibold", size: 25)
                nameOutlet.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
                
                textOutlet.font = UIFont(name: "ProximaNovaSoftW03-Semibold", size: 17)
                textOutlet.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
            }
        }
        
        if let type = data["type"] as? String {
            
            self.type = type
            
            if type == "squad" || type == "groupChats" {
                
                typeIndicatorImageOutlet.image = UIImage(named: "sendSquad")
                
            } else if type == "matches" {
                
                typeIndicatorImageOutlet.image = UIImage(named: "sendMatch")
                
            }
        }
        
        
        
        if type == "groupChats" {
            
            self.onlineIndicatorOutlet.alpha = 0

            if let title = data["title"] as? String {
                
                self.nameOutlet.text = title
                
            }
            
            
            if let members = data["members"] as? [String : Bool] {
                
                self.textOutlet.text = "\(members.count) Members in chat"
                
            }
            
            
            if let key = data["key"] as? String {
                
                self.uid = key
                
            }
            
            if let chatPhoto = data["groupPhoto"] as? String, let url = URL(string: chatPhoto) {

                self.profileOutlet.sd_setImage(with: url, placeholderImage: nil)
 
            } else {
                
                self.profileOutlet.image = UIImage(named: "icon")
                
            }
  
        } else {
            
            self.onlineIndicatorOutlet.alpha = 1
            
            if let text = data["text"] as? String {
                
                self.textOutlet.text = text
                
            }
            
            if let senderId = data["senderId"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if senderId != selfUID {
                    
                    self.uid = senderId
                    scopeUID = senderId
                    
                    if let firstName = data["firstName"] as? String, let lastName = data["lastName"] as? String {
                        
                        self.firstName = firstName
                        self.lastName = lastName
                        
                        self.nameOutlet.text = firstName + " " + lastName
                        
                    }
                    
                } else {
                    
                    if let userUid = data["userUID"] as? String {
                        
                        self.uid = userUid
                        scopeUID = userUid
                        
                        let yourRef = FIRDatabase.database().reference().child("users").child(userUid)
                        
                        yourRef.child("firstName").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if let firstName = snapshot.value as? String {
                                
                                yourRef.child("lastName").observeSingleEvent(of: .value, with: { (snapshot) in
                                    
                                    if let lastName = snapshot.value as? String {
                                        
                                        if self.uid == scopeUID {
                                            
                                            self.firstName = firstName
                                            self.lastName = lastName
                                            
                                            self.nameOutlet.text = firstName + " " + lastName
                                            
                                        }
                                    }
                                })
                            }
                        })
                    }
                }
            }
            
            
            if !scopeUID.isEmpty {
                
                let ref = FIRDatabase.database().reference().child("users").child(scopeUID)
                
                ref.child("profilePicture").observe(.value, with: { (snapshot) in
                    
                    if self.uid == scopeUID {
                        
                        if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                            
                            self.profile = profileString
                            
                            self.profileOutlet.sd_setImage(with: url, placeholderImage: nil)
                            
                        }
                    }
                })
                
                ref.child("online").observe(.value, with: { (snapshot) in
                    
                    if self.uid == scopeUID {
     
                        if let online = snapshot.value as? Bool {
                            
                            if online {
                                
                                self.onlineIndicatorOutlet.backgroundColor = UIColor.green
                                
                            } else {
                                
                                self.onlineIndicatorOutlet.backgroundColor = UIColor.red
                                
                            }
                        }
                    }
                })
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        onlineIndicatorOutlet.layer.cornerRadius = 8
        onlineIndicatorOutlet.layer.borderWidth = 2
        onlineIndicatorOutlet.layer.borderColor = UIColor.white.cgColor
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
