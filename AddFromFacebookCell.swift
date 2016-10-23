//
//  AddFromFacebookCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-10-21.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class AddFromFacebookCell: UITableViewCell {

    var data = [AnyHashable: Any]()
    var firstName = ""
    var lastName = ""
    var profile = ""
    
    var currentSquadInstance = ""
    var uid = ""
    var selfSquad = false
    
    weak var addFromFaceookController: AddFromFacebookController?
    
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
    @IBAction func inSquad(_ sender: AnyObject) {
        
        let scopeUID = uid
        
        let alertController = UIAlertController(title: "Delete \(firstName + " " + lastName) from your squad?", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete \(firstName)", style: .destructive, handler: { (action) in
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                let myRef = FIRDatabase.database().reference().child("users").child(selfUID)
                
                DispatchQueue.main.async(execute: {
                    
                    myRef.child("notifications").child(scopeUID).child("squad").removeValue()
                    myRef.child("notifications").child(scopeUID).child("squadRequest").removeValue()
                    myRef.child("squad").child(scopeUID).removeValue()
                    myRef.child("squadRequests").child(scopeUID).removeValue()
                    
                    self.addFromFaceookController?.globTableViewOutlet.reloadData()
                    
                })
                
                
                let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                
                DispatchQueue.main.async(execute: {
                    
                    yourRef.child("notifications").child(selfUID).child("squad").removeValue()
                    yourRef.child("notifications").child(selfUID).child("squadRequest").removeValue()
                    yourRef.child("squad").child(selfUID).removeValue()
                    yourRef.child("squadRequests").child(selfUID).removeValue()
                    
                    self.addFromFaceookController?.globTableViewOutlet.reloadData()
                    
                })
            }
        }))
        
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            print("canceled")
            
        }))
        
        
        self.addFromFaceookController?.present(alertController, animated: true, completion: {
            
            print("alert controller presented")
            
        })
    }
    
    @IBAction func messageSquad(_ sender: AnyObject) {
        
        //let scopeUserData = data
        let scopeUID = uid
        let scopeFirstName = firstName
        let scopeLastName = lastName
        
        if currentSquadInstance == "inSquad" {
            
            //Delete Squad?
            print("toggle messages", terminator: "")
            
            self.addFromFaceookController?.mainRootController?.toggleChat("squad", key: scopeUID, city: nil, firstName: scopeFirstName, lastName: scopeLastName, profile: profile, completion: { (bool) in
                
                print("chat toggled", terminator: "")
                
            })
            
        } else if currentSquadInstance == "sentSquad" {
            
            //Cancel send?
            print("cancel send?", terminator: "")
            
            let alertController = UIAlertController(title: "Unsend squad request to \(firstName + " " + lastName)", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Unsend Request", style: .destructive, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
                    let ref = FIRDatabase.database().reference().child("users").child(scopeUID)
                    
                    ref.child("squadRequests").child(selfUID).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let mySquadRequest = snapshot.value as? [AnyHashable: Any] {
                            
                            if let notKey = mySquadRequest["notificationKey"] as? String {
                                
                                DispatchQueue.main.async(execute: {
                                    
                                    ref.child("squadRequests").child(selfUID).removeValue()
                                    ref.child("notifications").child(notKey).removeValue()
                                    
                                    self.addFromFaceookController?.globTableViewOutlet.reloadData()
                                    
                                })
                            }
                        }
                    })
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            let popover = alertController.popoverPresentationController
            popover?.sourceView = self
            popover?.sourceRect = self.bounds
            popover?.permittedArrowDirections = UIPopoverArrowDirection.any
            
            self.addFromFaceookController?.present(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
            })
            
            
        } else if currentSquadInstance == "confirmSquad" {
            
            //Confrim or Deny
            print("confirm or deny", terminator: "")
            
            let alertController = UIAlertController(title: "Confirm \(firstName + " " + lastName) to your squad?", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Add to Squad", style: .default, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.addFromFaceookController?.mainRootController?.selfData, let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String {
                    
                    let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
                    
                    if let mySquadRequests = selfData["squadRequests"] as? [AnyHashable: Any], let userSquadRequest = mySquadRequests[scopeUID] as? [AnyHashable: Any], let scopeNotificationKey = userSquadRequest["notificationKey"] as? String {
                        
                        DispatchQueue.main.async(execute: {
                            
                            ref.child("notifications").child(scopeNotificationKey).updateChildValues(["status" : "approved"])
                            ref.child("squadRequests").child(scopeUID).removeValue()
                            
                            ref.child("squad").child(scopeUID).setValue(["firstName" : scopeFirstName, "lastName" : scopeLastName, "uid" : scopeUID])
                            
                            let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                            
                            yourRef.child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                    
                                    appDelegate.pushMessage(scopeUID, token: token, message: "\(myFirstName) has sent you a squad request")
                                    
                                    
                                }
                            })
                            
                            
                            let timeInterval = Date().timeIntervalSince1970
                            
                            let key = yourRef.child("notifications").childByAutoId().key
                            
                            yourRef.child("notifications").child(key).setValue(["firstName" : myFirstName, "lastName" : myLastName, "type" : "addedYou", "timeStamp" : timeInterval, "uid" : selfUID, "read" : false, "notificationKey" : key])
                            
                            yourRef.child("squad").child(selfUID).setValue(["firstName" : myFirstName, "lastName" : myLastName, "uid" : selfUID])
                            
                            self.addFromFaceookController?.globTableViewOutlet.reloadData()
                            
                        })
                    }
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Reject \(firstName)", style: .destructive, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
                    let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
                    
                    if let selfData = self.addFromFaceookController?.mainRootController?.selfData, let mySquadRequests = selfData["squadRequests"] as? [AnyHashable: Any], let userSquadRequest = mySquadRequests[scopeUID] as? [AnyHashable: Any], let scopeNotificationKey = userSquadRequest["notificationKey"] as? String {
                        
                        DispatchQueue.main.async(execute: {
                            
                            ref.child("notifications").child(scopeNotificationKey).removeValue()
                            ref.child("squadRequests").child(scopeUID).removeValue()
                            
                            self.addFromFaceookController?.globTableViewOutlet.reloadData()
                            
                        })
                    }
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            let popover = alertController.popoverPresentationController
            popover?.sourceView = self
            popover?.sourceRect = self.bounds
            popover?.permittedArrowDirections = UIPopoverArrowDirection.any
            
            self.addFromFaceookController?.present(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
                
            })
            
            
        } else {
            
            //Send a request
            print(currentSquadInstance, terminator: "")
            print("send a request", terminator: "")
            
            let alertController = UIAlertController(title: "Add \(firstName + " " + lastName) to your squad!", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Send Request", style: .default, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.addFromFaceookController?.mainRootController?.selfData, let firstName = selfData["firstName"] as? String, let lastName = selfData["lastName"] as? String {
                    
                    let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                    
                    yourRef.child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            
                            appDelegate.pushMessage(scopeUID, token: token, message: "\(firstName) has sent you a squad request")
                            
                            
                        }
                    })
                    
                    
                    let timeInterval = Date().timeIntervalSince1970
                    
                    //0 -> Hasn't responded yet, 1 -> Approved, 2 -> Denied
                    let ref = FIRDatabase.database().reference().child("users").child(scopeUID)
                    
                    let notificationKey = ref.child("notifications").childByAutoId().key
                    
                    let squadItem = ["uid" : selfUID, "read" : false, "status": 0, "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName, "notificationKey" : notificationKey] as [String : Any]
                    
                    let notificationItem = ["uid" : selfUID, "read" : false, "status" : "awaitingAction", "type" : "squadRequest", "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName, "notificationKey" : notificationKey] as [String : Any]
                    
                    
                    DispatchQueue.main.async(execute: {
                        
                        ref.child("squadRequests").child(selfUID).setValue(squadItem)
                        ref.child("notifications").child(notificationKey).setValue(notificationItem)
                        
                        self.addFromFaceookController?.globTableViewOutlet.reloadData()
                        
                    })
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            let popover = alertController.popoverPresentationController
            popover?.sourceView = self
            popover?.sourceRect = self.bounds
            popover?.permittedArrowDirections = UIPopoverArrowDirection.any
            
            self.addFromFaceookController?.present(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
            })
        }
    }
    
    
    @IBAction func toProfile(_ sender: AnyObject) {
        
        var selfProfile = false
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if self.uid == selfUID {
                
                selfProfile = true
                
            }
        }
        
        addFromFaceookController?.mainRootController?.toggleProfile(uid, selfProfile: selfProfile, completion: { (bool) in
            
            print("profile toggled", terminator: "")
            
        })
    }
    
    
    //Functions
    func loadCell(_ data: [AnyHashable: Any]) {
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .alignCenters
        
        if let firstName = data["firstName"] as? String, let lastName = data["lastName"] as? String {
            
            self.firstName = firstName
            self.lastName = lastName
            
            nameOutlet.text = firstName + " " + lastName
            
        }
        
        if let uid = data["uid"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            self.uid = uid
            
            if let  selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if uid == selfUID {
                    
                    inSquadButton.isEnabled = false
                    inSquadIconOutlet.image = nil
                    buttonIconOutlet.image = nil
                    buttonOutlet.isEnabled = false
                    
                } else {
                    
                    buttonOutlet.isEnabled = true
                    
                    if let selfData = addFromFaceookController?.mainRootController?.selfData {
                        
                        var inMySquad = false
                        var iSentYou = false
                        var youSentMe = false
                        
                        if let mySquad = selfData["squad"] as? [AnyHashable: Any] {
                            
                            if mySquad[uid] != nil {
                                
                                inMySquad = true
                                
                            }
                        }
                        
                        if inMySquad {
                            
                            self.inSquadButton.isEnabled = true
                            self.inSquadIconOutlet.image = UIImage(named: "inSquad")
                            
                            self.buttonIconOutlet.image = UIImage(named: "enabledMessage")
                            self.currentSquadInstance = "inSquad"
                            
                        } else {
                            
                            self.inSquadButton.isEnabled = false
                            self.inSquadIconOutlet.image = nil
                            
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
                                
                                self.buttonIconOutlet.image = UIImage(named: "confirmSquad")
                                self.currentSquadInstance = "confirmSquad"
                                
                            } else {
                                
                                let ref = FIRDatabase.database().reference().child("users").child(uid)
                                
                                ref.child("squadRequests").observeSingleEvent(of: .value, with: { (snapshot) in
                                    
                                    print(snapshot.value)
                                    
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
            
            
            ref.child("profilePicture").observe(.value, with: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                        
                        self.profile = profileString
                        self.profilePicOutlet.sd_setImage(with: url, placeholderImage: nil)
                    }
                }
            })
            
            
            ref.child("cityRank").observe(.value, with: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let rank = snapshot.value as? Int {
                        
                        self.rankOutlet.text = "#\(rank)"
                        
                    }
                }
            })
            
            
            ref.child("online").observe(.value, with: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let online = snapshot.value as? Bool {
                        
                        if selfUID == uid {
                            
                            self.onlineIndicator.alpha = 0
                            
                        } else {
                            
                            self.onlineIndicator.alpha = 1
                            
                            if online {
                                
                                self.onlineIndicator.backgroundColor = UIColor.green
                                
                            } else {
                                
                                self.onlineIndicator.backgroundColor = UIColor.red
                                
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
