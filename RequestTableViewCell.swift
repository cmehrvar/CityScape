//
//  RequestTableViewCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-21.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class RequestTableViewCell: UITableViewCell {
    
    weak var requestController: RequestsController?
    
    var notificationKey = ""
    var uid = ""
    var firstName = ""
    var lastName = ""

    @IBOutlet weak var profilePicOutlet: TableViewProfilePicView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityRankOutlet: UILabel!

    @IBAction func toProfile(sender: AnyObject) {
        
        requestController?.rootController?.toggleProfile(uid, selfProfile: false, completion: { (bool) in
            
            print("profile toggled")
            
            self.requestController?.rootController?.toggleHome({ (bool) in
                
                print("home toggled")
                
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
                    
                    self.requestController?.globTableViewOutlet.reloadData()
    
            })
        }
    }
    
    
    @IBAction func approve(sender: AnyObject) {
        
        let scopeNotificationKey = notificationKey
        let scopeUID = uid
        let scopeFirstName = firstName
        let scopeLastName = lastName
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid, selfData = self.requestController?.rootController?.selfData, myFirstName = selfData["firstName"] as? String, myLastName = selfData["lastName"] as? String {
            
            let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
            
            ref.child("notifications").child(scopeNotificationKey).updateChildValues(["status" : "approved"])
            ref.child("squadRequests").child(scopeUID).updateChildValues(["status" : 1])
            
            ref.child("squad").child(scopeUID).setValue(["firstName" : scopeFirstName, "lastName" : scopeLastName, "uid" : scopeUID])
            
            
            let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
            
            let timeInterval = NSDate().timeIntervalSince1970
            
            let key = yourRef.child("notifications").childByAutoId().key
            
            yourRef.child("notifications").child(key).setValue(["firstName" : myFirstName, "lastName" : myLastName, "type" : "addedYou", "timeStamp" : timeInterval, "uid" : selfUID, "read" : false, "notificationKey" : key])
            
            yourRef.child("squad").child(selfUID).setValue(["firstName" : myFirstName, "lastName" : myLastName, "uid" : selfUID])
   
        }
        
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.backgroundColor = UIColor.greenColor()
            self.layoutIfNeeded()
            
        }) { (bool) in
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.backgroundColor = UIColor.whiteColor()
                self.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.requestController?.globTableViewOutlet.reloadData()
                    
                    
            })
        }
    }
    

    func loadCell(data: [NSObject : AnyObject]) {
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .AlignCenters
        
        
        if let key = data["notificationKey"] as? String {
            
            self.notificationKey = key
            
        }
        
        if let uid = data["uid"] as? String {
            
            self.uid = uid
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            ref.child("profilePicture").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                    
                    self.profilePicOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                    
                }
            })
            
            ref.child("cityRank").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let rank = snapshot.value as? Int {
                    
                    self.cityRankOutlet.text = "#\(rank)"
                    
                }
            })
        }
        
        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {
            
            self.firstName = firstName
            self.lastName = lastName
            
            nameOutlet.text = firstName
            
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
