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
    
    var data = [AnyHashable: Any]()

    //Outlets
    @IBOutlet weak var profilePicOutlet: VibeHeaderProfilePic!
    @IBOutlet weak var cityRankOutlet: UILabel!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var squadIndicatorOutlet: UIImageView!
    @IBOutlet weak var squadRequestButtonOutlet: UIButton!

    //Action
    @IBAction func squadRequest(_ sender: AnyObject) {
        
        let scopeUserData = data
        let scopeFirstName = firstName
        let scopeLastName = lastName

        if currentSquadInstance == "inSquad" {
            
            //Delete Squad?
            print("toggle messages", terminator: "")

            self.vibesController?.rootController?.toggleChat("squad", key: uid, city: nil, firstName: firstName, lastName: lastName, profile: profilePic, completion: { (bool) in
                
                print("chat toggled", terminator: "")
                
                
            })

        } else if currentSquadInstance == "sentSquad" {
            
            //Cancel send?
            print("cancel send?", terminator: "")
            
            let alertController = UIAlertController(title: "Unsend squad request to \(firstName + " " + lastName)", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Unsend Request", style: .destructive, handler: { (action) in
                
                if let userUID = scopeUserData["userUID"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {

                    let ref = FIRDatabase.database().reference().child("users").child(userUID)
                    
                    DispatchQueue.main.async(execute: {
                        
                        ref.child("squadRequests").child(selfUID).removeValue()
                        ref.child("notifications").child(selfUID).child("squadRequest").removeValue()
                        
                        self.vibesController?.globCollectionView.reloadData()
                        
                    })
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                print("canceled")

            }))
            
            self.vibesController?.present(alertController, animated: true, completion: {
                
                print("alert controller presented")

            })
            
            
        } else if currentSquadInstance == "confirmSquad" {
            
            //Confrim or Deny
            print("confirm or deny", terminator: "")
            
            let alertController = UIAlertController(title: "Confirm \(firstName + " " + lastName) to your squad?", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Add to Squad", style: .default, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.vibesController?.rootController?.selfData, let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String, let scopeUID = scopeUserData["userUID"] as? String {
                    
                    let ref =  FIRDatabase.database().reference().child("users").child(selfUID)

                        DispatchQueue.main.async(execute: {
                            
                            ref.child("notifications").child(scopeUID).child("squadRequest").updateChildValues(["status" : "approved"])
                            ref.child("squadRequests").child(scopeUID).removeValue()
                            
                            ref.child("squad").child(scopeUID).setValue(["firstName" : scopeFirstName, "lastName" : scopeLastName, "uid" : scopeUID])
                            
                            let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
     
                            yourRef.child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                    
                                    appDelegate.pushMessage(scopeUID, token: token, message: "\(myFirstName) is now in your squad!")
                                    
                                    
                                }
                            })

                            
                            
                            let timeInterval = Date().timeIntervalSince1970
                            yourRef.child("notifications").child(selfUID).child("squadRequest").setValue(["firstName" : myFirstName, "lastName" : myLastName, "type" : "addedYou", "timeStamp" : timeInterval, "uid" : selfUID, "read" : false])
                            
                            yourRef.child("squad").child(selfUID).setValue(["firstName" : myFirstName, "lastName" : myLastName, "uid" : selfUID])
                            
                            self.vibesController?.globCollectionView.reloadData()
                            
                        })
                    }
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Reject \(firstName)", style: .destructive, handler: { (action) in

                if let selfUID = FIRAuth.auth()?.currentUser?.uid, let scopeUID = scopeUserData["userUID"] as? String {
                    
                    let ref =  FIRDatabase.database().reference().child("users").child(selfUID)

                        DispatchQueue.main.async(execute: {
                            
                            ref.child("notifications").child(scopeUID).child("squadRequest").removeValue()
                            ref.child("squadRequests").child(scopeUID).removeValue()
                            
                            self.vibesController?.globCollectionView.reloadData()
                            
                        })
                    
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            self.vibesController?.present(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
                
            })
            
            
        } else {
            
            //Send a request
            print("send a request", terminator: "")
            
            let alertController = UIAlertController(title: "Add \(firstName + " " + lastName) to your squad!", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Send Request", style: .default, handler: { (action) in

                if let userUID = scopeUserData["userUID"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.vibesController?.rootController?.selfData, let firstName = selfData["firstName"] as? String, let lastName = selfData["lastName"] as? String {

                    let yourRef = FIRDatabase.database().reference().child("users").child(userUID)
                    
                    yourRef.child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            
                            appDelegate.pushMessage(userUID, token: token, message: "\(firstName) has sent you a squad request")
                            
                            
                        }
                    })

                    let timeInterval = Date().timeIntervalSince1970
                    
                    //0 -> Hasn't responded yet, 1 -> Approved, 2 -> Denied
                    let ref = FIRDatabase.database().reference().child("users").child(userUID)

                    let squadItem = ["uid" : selfUID, "read" : false, "status": 0, "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName] as [String : Any]
                    
                    let notificationItem = ["uid" : selfUID, "read" : false, "status" : "awaitingAction", "type" : "squadRequest", "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName] as [String : Any]
                    
    
                    DispatchQueue.main.async(execute: {
                        
                        ref.child("squadRequests").child(selfUID).setValue(squadItem)
                        ref.child("notifications").child(selfUID).child("squadRequest").setValue(notificationItem)
                        
                        self.vibesController?.globCollectionView.reloadData()
                        
                    })
                }
            }))

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            self.vibesController?.present(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
            })
        }
    }

    @IBAction func toProfile(_ sender: AnyObject) {
        
        if let userUid = data["userUID"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {

            var selfProfile = false
            
            if userUid == selfUID {
                
                selfProfile = true
                
            }
            
            vibesController?.rootController?.toggleProfile(userUid, selfProfile: selfProfile, completion: { (bool) in
                
                print("profile toggled")
                
            })
        }
    }

    func loadCell(_ data: [AnyHashable: Any]) {
        
        self.data = data

        profilePicOutlet.image = nil
        
        self.nameOutlet.adjustsFontSizeToFitWidth = true
        self.nameOutlet.baselineAdjustment = .alignCenters

        if let uid = data["userUID"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            self.uid = uid

            if uid == selfUID {
                
                squadIndicatorOutlet.image = nil
                squadRequestButtonOutlet.isEnabled = false
                
            } else {
                
                squadRequestButtonOutlet.isEnabled = true

                if let selfData = vibesController?.rootController?.selfData {

                    var inMySquad = false
                    var iSentYou = false
                    var youSentMe = false
   
                    if let mySquad = selfData["squad"] as? [AnyHashable: Any] {
                        
                        if mySquad[uid] != nil {
                            
                            inMySquad = true
                            
                        }
                    }

                    if inMySquad {

                        self.squadIndicatorOutlet.image = UIImage(named: "enabledMessage")
                        self.currentSquadInstance = "inSquad"
                        
                    } else {
        
                        if let mySquadRequests = selfData["squadRequests"] as? [AnyHashable: Any] {
                            
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
                            
                            ref.child("squadRequests").observeSingleEvent(of: .value, with: { (snapshot) in

                                if snapshot.exists() {
                                    
                                    if let yourSquadRequests = snapshot.value as? [AnyHashable: Any] {
                                        
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
            
            ref.child("profilePicture").observe(.value, with: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                        
                        self.profilePic = profileString

                        self.profilePicOutlet.sd_setImage(with: url, placeholderImage: nil)
                        
                    }
                }
            })
            
            ref.child("cityRank").observe(.value, with: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let rank = snapshot.value as? Int {

                        self.cityRankOutlet.text = "#\(rank)"
                        
                    }
                }
            })
            
            ref.child("online").observe(.value, with: { (snapshot) in
                
                if self.uid == uid {
                    
                    //DO SOMETHING WITH ONLINE
                    
                }
            })
        }

        
        if let firstName = data["firstName"] as? String, let lastName = data["lastName"] as? String {
            
            self.firstName = firstName
            self.lastName = lastName
            
            let name = firstName + " " + lastName
            nameOutlet.text = name
            
        }
    }
    
    override func prepareForReuse() {
        
        profilePicOutlet.image = nil
        cityRankOutlet.text = nil
        nameOutlet.text = nil
        squadIndicatorOutlet.image = nil
 
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
