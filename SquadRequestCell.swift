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
    var notificationKey = ""
    var firstName = ""
    var lastName = ""
    
    weak var notificationController: NotificationController?
    
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    
    
    @IBOutlet weak var respondImageOutlet: UIImageView!
    @IBOutlet weak var denyButtonOutlet: UIButton!
    @IBOutlet weak var approveButtonOutlet: UIButton!

    @IBAction func toProfile(sender: AnyObject) {
        
        let scopeUID = uid
        
        notificationController?.rootController?.toggleNotifications({ (bool) in
            
            self.notificationController?.rootController?.toggleProfile(scopeUID, selfProfile: false, completion: { (bool) in
                
                print("profile toggled")
                
            })
        })
    }
    
    
    
    @IBAction func deny(sender: AnyObject) {
        
        let scopeNotificationKey = notificationKey
        let scopeUID = uid
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
            
            ref.child("notifications").child(scopeNotificationKey).removeValue()
            ref.child("squadRequests").child(scopeUID).removeValue()
            
        }
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.backgroundColor = UIColor.redColor()
            self.layoutIfNeeded()
            
        }) { (bool) in
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.backgroundColor = UIColor.whiteColor()
                self.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.notificationController?.globTableViewOutlet.reloadData()
                
            })
        }
    }
    
    @IBAction func approve(sender: AnyObject) {
        
        let scopeNotificationKey = notificationKey
        let scopeUID = uid
        let scopeFirstName = firstName
        let scopeLastName = lastName

        if let selfUID = FIRAuth.auth()?.currentUser?.uid, selfData = self.notificationController?.rootController?.selfData, myFirstName = selfData["firstName"] as? String, myLastName = selfData["lastName"] as? String {
            
            let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
            
            ref.child("notifications").child(scopeNotificationKey).updateChildValues(["status" : "approved"])
            ref.child("squadRequests").child(scopeUID).updateChildValues(["status" : 1])
            
            ref.child("squad").child(scopeUID).setValue(["firstName" : scopeFirstName, "lastName" : scopeLastName, "uid" : scopeUID])
            
            
            let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
            
            let timeInterval = NSDate().timeIntervalSince1970
            
            let key = yourRef.child("notifications").childByAutoId().key
            
            yourRef.child("notifications").child(key).setValue(["firstName" : myFirstName, "lastName" : myLastName, "type" : "addedYou", "timeStamp" : timeInterval, "uid" : selfUID, "read" : false, "notificationKey" : key])
            
            yourRef.child("squad").child(selfUID).setValue(["firstName" : myFirstName, "lastName" : myLastName, "uid" : selfUID])
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.backgroundColor = UIColor.greenColor()
                self.layoutIfNeeded()
                
            }) { (bool) in
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.backgroundColor = UIColor.whiteColor()
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.notificationController?.globTableViewOutlet.reloadData()
                        
                })
            }
        }
    }
    
    
    
    func loadCell(data: [NSObject : AnyObject]) {
        
        
        if let key = data["notificationKey"] as? String {
            
            self.notificationKey = key
            
        }

        if let read = data["read"] as? Bool {
            
            if !read {
                
                self.backgroundColor = UIColor.yellowColor()
                
            } else {
                
                self.backgroundColor = UIColor.whiteColor()
                
            }
        }
        
        if data["status"] as? String == "approved" || data["type"] as? String == "addedYou" {
            
            denyButtonOutlet.alpha = 0
            approveButtonOutlet.alpha = 0
            
            respondImageOutlet.image = UIImage(named: "inSquad")
            
        } else if data["status"] as? String == "denied" {
            
            denyButtonOutlet.alpha = 0
            approveButtonOutlet.alpha = 0
            
            respondImageOutlet.image = UIImage(named: "RedX")
            
        } else {
            
            denyButtonOutlet.alpha = 1
            approveButtonOutlet.alpha = 1
            
            respondImageOutlet.image = nil
            
        }

        if let userUID = data["uid"] as? String {
            
            self.uid = userUID

            let ref = FIRDatabase.database().reference().child("users").child(userUID)

            ref.child("profilePicture").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                    
                    self.profilePictureOutlet.sd_setImageWithURL(url, placeholderImage: nil)

                }
            })
        }
        
        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {
            
            self.firstName = firstName
            self.lastName = lastName
            
            let name = firstName + " " + lastName
            nameOutlet.text = name
            
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
