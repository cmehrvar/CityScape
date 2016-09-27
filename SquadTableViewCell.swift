//
//  SquadTableViewCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-21.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class SquadTableViewCell: UITableViewCell {
    
    var data = [NSObject : AnyObject]()
    var firstName = ""
    var lastName = ""
    var profile = ""
    
    var currentSquadInstance = ""
    var uid = ""
    var selfSquad = false
    
    weak var squadCountController: SquadCountController?
    
    //Outlets
    @IBOutlet weak var profilePicOutlet: TableViewProfilePicView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var rankOutlet: UILabel!
    @IBOutlet weak var onlineIndicator: TableViewOnlineIndicatorView!
    @IBOutlet weak var buttonIconOutlet: UIImageView!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var inSquadButton: UIButton!
    @IBOutlet weak var inSquadIconOutlet: UIImageView!
    
    
    
    //Actions
    @IBAction func inSquad(sender: AnyObject) {
        
        let scopeUID = uid
        
        let alertController = UIAlertController(title: "Delete \(firstName + " " + lastName) from your squad?", message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete \(firstName)", style: .Destructive, handler: { (action) in
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                let myRef = FIRDatabase.database().reference().child("users").child(selfUID)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    myRef.child("notifications").child(scopeUID).child("squad").removeValue()
                    myRef.child("notifications").child(scopeUID).child("squadRequest").removeValue()
                    myRef.child("squad").child(scopeUID).removeValue()
                    myRef.child("squadRequests").child(scopeUID).removeValue()
                    
                    self.squadCountController?.globTableViewOutlet.reloadData()
                    
                })
                
                
                let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    yourRef.child("notifications").child(selfUID).child("squad").removeValue()
                    yourRef.child("notifications").child(selfUID).child("squadRequest").removeValue()
                    yourRef.child("squad").child(selfUID).removeValue()
                    yourRef.child("squadRequests").child(selfUID).removeValue()
                    
                    self.squadCountController?.globTableViewOutlet.reloadData()
                    
                })
            }
        }))
        
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
            print("canceled")
            
        }))
        
        
        self.squadCountController?.presentViewController(alertController, animated: true, completion: {
            
            print("alert controller presented")
            
        })
    }
    
    @IBAction func messageSquad(sender: AnyObject) {
        
        //let scopeUserData = data
        let scopeUID = uid
        let scopeFirstName = firstName
        let scopeLastName = lastName
        
        if currentSquadInstance == "inSquad" {
            
            //Delete Squad?
            print("toggle messages")
            
            self.squadCountController?.rootController?.toggleChat("squad", userUID: scopeUID, postUID: nil, city: nil, firstName: scopeFirstName, lastName: scopeLastName, profile: profile, completion: { (bool) in
                
                print("chat toggled")
                
            })

        } else if currentSquadInstance == "sentSquad" {
            
            //Cancel send?
            print("cancel send?")
            
            let alertController = UIAlertController(title: "Unsend squad request to \(firstName + " " + lastName)", message: nil, preferredStyle: .ActionSheet)
            
            alertController.addAction(UIAlertAction(title: "Unsend Request", style: .Destructive, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
                    let ref = FIRDatabase.database().reference().child("users").child(scopeUID)
                    
                    ref.child("squadRequests").child(selfUID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        
                        if let mySquadRequest = snapshot.value as? [NSObject : AnyObject] {
                            
                            if let notKey = mySquadRequest["notificationKey"] as? String {
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    ref.child("squadRequests").child(selfUID).removeValue()
                                    ref.child("notifications").child(notKey).removeValue()
                                    
                                    self.squadCountController?.globTableViewOutlet.reloadData()
                                    
                                })
                            }
                        }
                    })
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            self.squadCountController?.presentViewController(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
            })
            
            
        } else if currentSquadInstance == "confirmSquad" {
            
            //Confrim or Deny
            print("confirm or deny")
            
            let alertController = UIAlertController(title: "Confirm \(firstName + " " + lastName) to your squad?", message: nil, preferredStyle: .ActionSheet)
            
            alertController.addAction(UIAlertAction(title: "Add to Squad", style: .Default, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, selfData = self.squadCountController?.rootController?.selfData, myFirstName = selfData["firstName"] as? String, myLastName = selfData["lastName"] as? String {
                    
                    let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
                    
                    if let mySquadRequests = selfData["squadRequests"] as? [NSObject : AnyObject], userSquadRequest = mySquadRequests[scopeUID] as? [NSObject : AnyObject], scopeNotificationKey = userSquadRequest["notificationKey"] as? String {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            ref.child("notifications").child(scopeNotificationKey).updateChildValues(["status" : "approved"])
                            ref.child("squadRequests").child(scopeUID).removeValue()
                            
                            ref.child("squad").child(scopeUID).setValue(["firstName" : scopeFirstName, "lastName" : scopeLastName, "uid" : scopeUID])
                            
                            let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                            
                            let timeInterval = NSDate().timeIntervalSince1970
                            
                            let key = yourRef.child("notifications").childByAutoId().key
                            
                            yourRef.child("notifications").child(key).setValue(["firstName" : myFirstName, "lastName" : myLastName, "type" : "addedYou", "timeStamp" : timeInterval, "uid" : selfUID, "read" : false, "notificationKey" : key])
                            
                            yourRef.child("squad").child(selfUID).setValue(["firstName" : myFirstName, "lastName" : myLastName, "uid" : selfUID])
                            
                            self.squadCountController?.globTableViewOutlet.reloadData()
                            
                        })
                    }
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Reject \(firstName)", style: .Destructive, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
                    let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
                    
                    if let selfData = self.squadCountController?.rootController?.selfData, mySquadRequests = selfData["squadRequests"] as? [NSObject : AnyObject], userSquadRequest = mySquadRequests[scopeUID] as? [NSObject : AnyObject], scopeNotificationKey = userSquadRequest["notificationKey"] as? String {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            ref.child("notifications").child(scopeNotificationKey).removeValue()
                            ref.child("squadRequests").child(scopeUID).removeValue()
                            
                            self.squadCountController?.globTableViewOutlet.reloadData()
                            
                        })
                    }
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            self.squadCountController?.presentViewController(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
                
            })
            
            
        } else {
            
            //Send a request
            print(currentSquadInstance)
            print("send a request")
            
            let alertController = UIAlertController(title: "Add \(firstName + " " + lastName) to your squad!", message: nil, preferredStyle: .ActionSheet)
            
            alertController.addAction(UIAlertAction(title: "Send Request", style: .Default, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, selfData = self.squadCountController?.rootController?.selfData, firstName = selfData["firstName"] as? String, lastName = selfData["lastName"] as? String {
                    
                    let timeInterval = NSDate().timeIntervalSince1970
                    
                    //0 -> Hasn't responded yet, 1 -> Approved, 2 -> Denied
                    let ref = FIRDatabase.database().reference().child("users").child(scopeUID)
                    
                    let notificationKey = ref.child("notifications").childByAutoId().key
                    
                    let squadItem = ["uid" : selfUID, "read" : false, "status": 0, "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName, "notificationKey" : notificationKey]
                    
                    let notificationItem = ["uid" : selfUID, "read" : false, "status" : "awaitingAction", "type" : "squadRequest", "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName, "notificationKey" : notificationKey]
                    
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        ref.child("squadRequests").child(selfUID).setValue(squadItem)
                        ref.child("notifications").child(notificationKey).setValue(notificationItem)
                        
                        self.squadCountController?.globTableViewOutlet.reloadData()
                        
                    })
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            self.squadCountController?.presentViewController(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
            })
        }
    }
    
    
    @IBAction func toProfile(sender: AnyObject) {
        
        var selfProfile = false
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if self.uid == selfUID {
                
                selfProfile = true
                
            }
        }
        
        squadCountController?.rootController?.toggleProfile(uid, selfProfile: selfProfile, completion: { (bool) in
            
            print("profile toggled")
            
            self.squadCountController?.rootController?.toggleHome({ (bool) in
                
                print("home toggled")
                
            })
        })
    }
    
    
    //Functions
    func loadCell(data: [NSObject : AnyObject]) {
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .AlignCenters
        
        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {
            
            self.firstName = firstName
            self.lastName = lastName

            nameOutlet.text = firstName
            
        }
        
        if let uid = data["uid"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            self.uid = uid
            
            if let  selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if uid == selfUID {
                    
                    buttonIconOutlet.image = nil
                    buttonOutlet.enabled = false
                    
                } else {
                    
                    buttonOutlet.enabled = true
                    
                    if let selfData = squadCountController?.rootController?.selfData {
                        
                        var inMySquad = false
                        var iSentYou = false
                        var youSentMe = false
                        
                        if let mySquad = selfData["squad"] as? [NSObject : AnyObject] {
                            
                            if mySquad[uid] != nil {
                                
                                inMySquad = true
                                
                            }
                        }
                        
                        if inMySquad {
                            
                            self.inSquadButton.enabled = true
                            self.inSquadIconOutlet.image = UIImage(named: "inSquad")
                            
                            self.buttonIconOutlet.image = UIImage(named: "enabledMessage")
                            self.currentSquadInstance = "inSquad"
                            
                        } else {
                            
                            self.inSquadButton.enabled = false
                            self.inSquadIconOutlet.image = nil
                            
                            if let mySquadRequests = selfData["squadRequests"] as? [NSObject : AnyObject] {
                                
                                for (key, _) in mySquadRequests {
                                    
                                    if let squadUID = key as? String {
                                        
                                        if uid == squadUID {
                                            
                                            youSentMe = true
                                            
                                        }
                                    }
                                }
                            }
                            
                            if youSentMe {
                                
                                self.buttonIconOutlet.image = UIImage(named: "confirmSquad")
                                self.currentSquadInstance = "confirmSquad"
                                
                            } else {
                                
                                let ref = FIRDatabase.database().reference().child("users").child(uid)
                                
                                ref.child("squadRequests").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                    
                                    print(snapshot.value)
                                    
                                    if snapshot.exists() {
                                        
                                        if let yourSquadRequests = snapshot.value as? [NSObject : AnyObject] {
                                            
                                            for (key, _) in yourSquadRequests {
                                                
                                                if let squadUID = key as? String {
                                                    
                                                    if selfUID == squadUID {
                                                        
                                                        iSentYou = true
                                                        
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if iSentYou {
                                            
                                            if self.uid == uid {
                                                
                                                self.buttonIconOutlet.image = UIImage(named: "sentSquad")
                                                self.currentSquadInstance = "sentSquad"
                                                
                                            }
                                            
                                        } else {
                                            
                                            if self.uid == uid {
                                                
                                                self.buttonIconOutlet.image = UIImage(named: "sendSquad")
                                                self.currentSquadInstance = "sendSquad"
                                                
                                            }
                                        }
                                        
                                    } else {
                                        
                                        if self.uid == uid {
                                            
                                            self.buttonIconOutlet.image = UIImage(named: "sendSquad")
                                            self.currentSquadInstance = "sendSquad"
                                            
                                        }
                                    }
                                })
                            }
                        }
                    }
                    
                }
            }
            
            
            ref.child("profilePicture").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                        
                        self.profile = profileString
                        self.profilePicOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                    }
                }
            })
            
            
            ref.child("cityRank").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let rank = snapshot.value as? Int {
                        
                        self.rankOutlet.text = "#\(rank)"
                        
                    }
                }
            })
            
            
            ref.child("online").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let online = snapshot.value as? Bool {
                        
                        if selfUID == uid {
                            
                            self.onlineIndicator.alpha = 0
                            
                        } else {
                            
                            self.onlineIndicator.alpha = 1
                            
                            if online {
                                
                                self.onlineIndicator.backgroundColor = UIColor.greenColor()
                                
                            } else {
                                
                                self.onlineIndicator.backgroundColor = UIColor.redColor()
                                
                            }
                        }
                    }
                }
            })
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
