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

    var uid = ""
    var firstName = ""
    var lastName = ""

    @IBOutlet weak var profilePicOutlet: TableViewProfilePicView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityRankOutlet: UILabel!

    @IBAction func toProfile(_ sender: AnyObject) {
        
        requestController?.rootController?.toggleProfile(uid, selfProfile: false, completion: { (bool) in
            
            print("profile toggled", terminator: "")
            
            self.requestController?.rootController?.toggleHome({ (bool) in
                
                print("home toggled", terminator: "")
                
            })
        })
    }
    
    @IBAction func deny(_ sender: AnyObject) {

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
                    
                    self.requestController?.globTableViewOutlet.reloadData()
    
            })
        }) 
    }
    
    
    @IBAction func approve(_ sender: AnyObject) {

        let scopeUID = uid
        let scopeFirstName = firstName
        let scopeLastName = lastName
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.requestController?.rootController?.selfData, let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String {
            
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
            
            let key = yourRef.child("notifications").childByAutoId().key
            
            yourRef.child("notifications").child(key).setValue(["firstName" : myFirstName, "lastName" : myLastName, "type" : "addedYou", "timeStamp" : timeInterval, "uid" : selfUID, "read" : false, "notificationKey" : key])
            
            yourRef.child("squad").child(selfUID).setValue(["firstName" : myFirstName, "lastName" : myLastName, "uid" : selfUID])
   
        }
        
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.backgroundColor = UIColor.green
            self.layoutIfNeeded()
            
        }, completion: { (bool) in
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.backgroundColor = UIColor.white
                self.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.requestController?.globTableViewOutlet.reloadData()
                    
                    
            })
        }) 
    }
    

    func loadCell(_ data: [AnyHashable: Any]) {
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .alignCenters
        
        if let uid = data["uid"] as? String {
            
            self.uid = uid
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            ref.child("profilePicture").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                    
                    self.profilePicOutlet.sd_setImage(with: url, placeholderImage: nil)
                    
                }
            })
            
            ref.child("cityRank").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let rank = snapshot.value as? Int {
                    
                    self.cityRankOutlet.text = "#\(rank)"
                    
                }
            })
        }
        
        if let firstName = data["firstName"] as? String, let lastName = data["lastName"] as? String {
            
            self.firstName = firstName
            self.lastName = lastName
            
            nameOutlet.text = firstName + " " + lastName
            
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
