//
//  SquadRequestCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-16.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class SquadRequestCell: UITableViewCell {

    var uid = ""
    var firstName = ""
    var lastName = ""
    var profile = ""
    
    var inSquad = false
    
    weak var notificationController: NotificationController?
    
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIImageView!

    @IBOutlet weak var denyImageOutlet: UIImageView!
    @IBOutlet weak var respondImageOutlet: UIImageView!
    @IBOutlet weak var denyButtonOutlet: UIButton!
    @IBOutlet weak var approveButtonOutlet: UIButton!
    @IBOutlet weak var unreadViewOutlet: UIView!
    

    @IBAction func toProfile(_ sender: AnyObject) {
        
        let scopeUID = uid
        
        notificationController?.rootController?.toggleNotifications({ (bool) in

            self.notificationController?.rootController?.toggleProfile(scopeUID, selfProfile: false, completion: { (bool) in
                
                print("profile toggled", terminator: "")
                
            })
        })
    }
    
    
    
    @IBAction func deny(_ sender: AnyObject) {

        self.unreadViewOutlet.alpha = 0
        
        let scopeUID = uid
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
            
            ref.child("notifications").child(scopeUID).child("squadRequest").removeValue()
            ref.child("squadRequests").child(scopeUID).removeValue()
            
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.backgroundColor = UIColor.red
            self.layoutIfNeeded()
            
        }, completion: { (bool) in
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.backgroundColor = UIColor.white
                self.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.notificationController?.globTableViewOutlet.reloadData()
                    
            })
        }) 
    }
    
    @IBAction func approve(_ sender: AnyObject) {

        self.unreadViewOutlet.alpha = 0
        
        if inSquad {
            
            print("toggle messages", terminator: "")
            
            let scopeFirstname = firstName
            let scopeLastname = lastName
            let scopeProfile = profile
            let scopeUID = uid
            
            self.notificationController?.rootController?.toggleNotifications({ (bool) in
                
                self.notificationController?.rootController?.toggleChat("squad", key: scopeUID, city: nil, firstName: scopeFirstname, lastName: scopeLastname, profile: scopeProfile, completion: { (bool) in
                    
                    print("chat toggled", terminator: "")
                    
                })
            })

        } else {

            let scopeUID = uid
            let scopeFirstName = firstName
            let scopeLastName = lastName
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.notificationController?.rootController?.selfData, let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String {
                
                let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
                ref.child("notifications").child(scopeUID).child("squadRequest").updateChildValues(["status" : "approved"])
                ref.child("squadRequests").child(scopeUID).updateChildValues(["status" : 1])
                
                ref.child("squad").child(scopeUID).setValue(["firstName" : scopeFirstName, "lastName" : scopeLastName, "uid" : scopeUID])

                let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)

                yourRef.child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        
                        appDelegate.pushMessage(uid: scopeUID, token: token, message: "\(myFirstName) is now in your squad!")
                        
                        
                    }
                })

                
                let timeInterval = Date().timeIntervalSince1970

                yourRef.child("notifications").child(selfUID).child("squadRequest").setValue(["firstName" : myFirstName, "lastName" : myLastName, "type" : "addedYou", "timeStamp" : timeInterval, "uid" : selfUID, "read" : false])
                
                yourRef.child("squad").child(selfUID).setValue(["firstName" : myFirstName, "lastName" : myLastName, "uid" : selfUID])
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.backgroundColor = UIColor.green
                    self.layoutIfNeeded()
                    
                }, completion: { (bool) in
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        
                        self.backgroundColor = UIColor.white
                        self.layoutIfNeeded()
                        
                        }, completion: { (bool) in
                            
                            self.notificationController?.globTableViewOutlet.reloadData()
                            
                    })
                }) 
            }
        }
    }

    func loadCell(_ data: [AnyHashable: Any]) {

        if let read = data["read"] as? Bool {
            
            if !read {
                
                self.unreadViewOutlet.alpha = 1
                
            } else {
                
                self.unreadViewOutlet.alpha = 0
                
            }
        }
        
        if data["status"] as? String == "approved" || data["type"] as? String == "addedYou" {
            
            self.denyButtonOutlet.isEnabled = false
            self.approveButtonOutlet.isEnabled = true
            
            inSquad = true
            
            denyImageOutlet.image = UIImage(named: "inSquad")
            respondImageOutlet.image = UIImage(named: "enabledMessage")
            
        } else {
            
            self.denyButtonOutlet.isEnabled = true
            self.approveButtonOutlet.isEnabled = true
            
            inSquad = false
            
            denyImageOutlet.image = UIImage(named: "deny")
            respondImageOutlet.image = UIImage(named: "approve")
            
        }

        if let userUID = data["uid"] as? String {
            
            self.uid = userUID

            let ref = FIRDatabase.database().reference().child("users").child(userUID)

            ref.child("profilePicture").observeSingleEvent(of: .value, with: { (snapshot) in

                if let profileString = snapshot.value as? String, let url = URL(string: profileString) {

                    self.profile = profileString
                    self.profilePictureOutlet.sd_setImage(with: url, placeholderImage: nil)

                }
            })
        }
        
        if let firstName = data["firstName"] as? String, let lastName = data["lastName"] as? String {
            
            self.firstName = firstName
            self.lastName = lastName
            
            let name = firstName
            nameOutlet.text = name
            
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
