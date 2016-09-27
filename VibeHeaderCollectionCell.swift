//
//  VibeHeaderCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-03.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class VibeHeaderCollectionCell: UICollectionViewCell {
    
    weak var vibesController: NewVibesController?
    
    var uid = ""
    var currentSquadInstance = ""
    var firstName = ""
    var lastName = ""
    var profilePic = ""
    
    var data = [NSObject : AnyObject]()

    //Outlets
    @IBOutlet weak var profilePicOutlet: VibeHeaderProfilePic!
    @IBOutlet weak var cityRankOutlet: UILabel!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var squadIndicatorOutlet: UIImageView!
    @IBOutlet weak var squadRequestButtonOutlet: UIButton!

    //Action
    @IBAction func squadRequest(sender: AnyObject) {
        
        let scopeUserData = data
        let scopeFirstName = firstName
        let scopeLastName = lastName

        if currentSquadInstance == "inSquad" {
            
            //Delete Squad?
            print("toggle messages")

            self.vibesController?.rootController?.toggleChat("squad", userUID: uid, postUID: nil, city: nil, firstName: firstName, lastName: lastName, profile: profilePic, completion: { (bool) in
                
                print("chat toggled")
                
                
            })

        } else if currentSquadInstance == "sentSquad" {
            
            //Cancel send?
            print("cancel send?")
            
            let alertController = UIAlertController(title: "Unsend squad request to \(firstName + " " + lastName)", message: nil, preferredStyle: .ActionSheet)
            
            alertController.addAction(UIAlertAction(title: "Unsend Request", style: .Destructive, handler: { (action) in
                
                if let userUID = scopeUserData["userUID"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {

                    let ref = FIRDatabase.database().reference().child("users").child(userUID)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        ref.child("squadRequests").child(selfUID).removeValue()
                        ref.child("notifications").child(selfUID).child("squadRequest").removeValue()
                        
                        self.vibesController?.globCollectionView.reloadData()
                        
                    })
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                
                print("canceled")

            }))
            
            self.vibesController?.presentViewController(alertController, animated: true, completion: {
                
                print("alert controller presented")

            })
            
            
        } else if currentSquadInstance == "confirmSquad" {
            
            //Confrim or Deny
            print("confirm or deny")
            
            let alertController = UIAlertController(title: "Confirm \(firstName + " " + lastName) to your squad?", message: nil, preferredStyle: .ActionSheet)
            
            alertController.addAction(UIAlertAction(title: "Add to Squad", style: .Default, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, selfData = self.vibesController?.rootController?.selfData, myFirstName = selfData["firstName"] as? String, myLastName = selfData["lastName"] as? String, scopeUID = scopeUserData["userUID"] as? String {
                    
                    let ref =  FIRDatabase.database().reference().child("users").child(selfUID)


                        dispatch_async(dispatch_get_main_queue(), {
                            
                            ref.child("notifications").child(scopeUID).child("squadRequest").updateChildValues(["status" : "approved"])
                            ref.child("squadRequests").child(scopeUID).removeValue()
                            
                            ref.child("squad").child(scopeUID).setValue(["firstName" : scopeFirstName, "lastName" : scopeLastName, "uid" : scopeUID])
                            
                            let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                            
                            let timeInterval = NSDate().timeIntervalSince1970

                            
                            yourRef.child("notifications").child(selfUID).child("squadRequest").setValue(["firstName" : myFirstName, "lastName" : myLastName, "type" : "addedYou", "timeStamp" : timeInterval, "uid" : selfUID, "read" : false])
                            
                            yourRef.child("squad").child(selfUID).setValue(["firstName" : myFirstName, "lastName" : myLastName, "uid" : selfUID])
                            
                            self.vibesController?.globCollectionView.reloadData()
                            
                        })
                    }
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Reject \(firstName)", style: .Destructive, handler: { (action) in

                if let selfUID = FIRAuth.auth()?.currentUser?.uid, scopeUID = scopeUserData["userUID"] as? String {
                    
                    let ref =  FIRDatabase.database().reference().child("users").child(selfUID)

                        dispatch_async(dispatch_get_main_queue(), {
                            
                            ref.child("notifications").child(scopeUID).child("squadRequest").removeValue()
                            ref.child("squadRequests").child(scopeUID).removeValue()
                            
                            self.vibesController?.globCollectionView.reloadData()
                            
                        })
                    
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            self.vibesController?.presentViewController(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
                
            })
            
            
        } else {
            
            //Send a request
            print("send a request")
            
            let alertController = UIAlertController(title: "Add \(firstName + " " + lastName) to your squad!", message: nil, preferredStyle: .ActionSheet)
            
            alertController.addAction(UIAlertAction(title: "Send Request", style: .Default, handler: { (action) in

                if let userUID = scopeUserData["userUID"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid, selfData = self.vibesController?.rootController?.selfData, firstName = selfData["firstName"] as? String, lastName = selfData["lastName"] as? String {
                    
                    let timeInterval = NSDate().timeIntervalSince1970
                    
                    //0 -> Hasn't responded yet, 1 -> Approved, 2 -> Denied
                    let ref = FIRDatabase.database().reference().child("users").child(userUID)

                    let squadItem = ["uid" : selfUID, "read" : false, "status": 0, "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName]
                    
                    let notificationItem = ["uid" : selfUID, "read" : false, "status" : "awaitingAction", "type" : "squadRequest", "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName]
                    
    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        ref.child("squadRequests").child(selfUID).setValue(squadItem)
                        ref.child("notifications").child(selfUID).child("squadRequest").setValue(notificationItem)
                        
                        self.vibesController?.globCollectionView.reloadData()
                        
                    })
                }
            }))

            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            self.vibesController?.presentViewController(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
            })
        }
    }

    @IBAction func toProfile(sender: AnyObject) {
        
        if let userUid = data["userUID"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {

            var selfProfile = false
            
            if userUid == selfUID {
                
                selfProfile = true
                
            }
            
            vibesController?.rootController?.toggleProfile(userUid, selfProfile: selfProfile, completion: { (bool) in
                
                print("profile toggled")
                
            })
        }
    }

    func loadCell(data: [NSObject : AnyObject]) {
        
        self.data = data

        profilePicOutlet.image = nil
        
        self.nameOutlet.adjustsFontSizeToFitWidth = true
        self.nameOutlet.baselineAdjustment = .AlignCenters

        if let uid = data["userUID"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            self.uid = uid
 
            if let profilePic = self.vibesController?.profilePics[uid], url = NSURL(string: profilePic) {
               
                profilePicOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                
            }
            
            
            if let rank = self.vibesController?.ranks[uid] {
                
                cityRankOutlet.text = "#\(rank)"
                
            }
            

            if uid == selfUID {
                
                squadIndicatorOutlet.image = nil
                squadRequestButtonOutlet.enabled = false
                
            } else {
                
                squadRequestButtonOutlet.enabled = true

                if let selfData = vibesController?.rootController?.selfData {

                    var inMySquad = false
                    var iSentYou = false
                    var youSentMe = false
   
                    if let mySquad = selfData["squad"] as? [NSObject : AnyObject] {
                        
                        if mySquad[uid] != nil {
                            
                            inMySquad = true
                            
                        }
                    }

                    if inMySquad {

                        self.squadIndicatorOutlet.image = UIImage(named: "enabledMessage")
                        self.currentSquadInstance = "inSquad"
                        
                    } else {
        
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
                            
                            self.squadIndicatorOutlet.image = UIImage(named: "confirmSquad")
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
                                            
                                            self.squadIndicatorOutlet.image = UIImage(named: "sentSquad")
                                            self.currentSquadInstance = "sentSquad"
                                            
                                        }
  
                                    } else {
                                        
                                        if self.uid == uid {
                                            
                                            self.squadIndicatorOutlet.image = UIImage(named: "sendSquad")
                                            self.currentSquadInstance = "sendSquad"
                                            
                                        }
                                    }
  
                                } else {
                                    
                                    if self.uid == uid {
                                        
                                        self.squadIndicatorOutlet.image = UIImage(named: "sendSquad")
                                        self.currentSquadInstance = "sendSquad"
                                        
                                    }
                                }
                            })
                        }
                    }
                }
            }

            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            ref.child("profilePicture").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                        
                        self.profilePic = profileString
                        
                        self.vibesController?.profilePics[uid] = profileString
                        self.profilePicOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                        
                    }
                }
            })
            
            ref.child("cityRank").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let rank = snapshot.value as? Int {
                        
                        self.vibesController?.ranks[uid] = rank
                        self.cityRankOutlet.text = "#\(rank)"
                        
                    }
                }
            })
            
            ref.child("online").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    //DO SOMETHING WITH ONLINE
                    
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
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
