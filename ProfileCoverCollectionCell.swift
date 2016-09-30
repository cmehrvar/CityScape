//
//  ProfileCoverCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-15.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ProfileInfoCollectionCell: UICollectionViewCell {
    
    //Variables
    weak var profileController: ProfileController?
    
    var currentInstance = ""
    
    var uid = ""
    var firstName = ""
    var lastName = ""

    var data = [NSObject : AnyObject]()
    
    //Outlets
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityOutlet: UILabel!
    @IBOutlet weak var squadButtonOutlet: UIButton!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    @IBOutlet weak var occupationOutlet: UILabel!
    
    @IBOutlet weak var squadImageOutlet: UIImageView!
    @IBOutlet weak var messageImageOutlet: UIImageView!
    
    
    //Functions
    func loadData(data: [NSObject:AnyObject]){
        
        self.data = data

        if let userUID = data["uid"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            self.uid = userUID
            
            if userUID == selfUID {
                
                squadImageOutlet.image = nil
                squadButtonOutlet.enabled = false
                
                messageImageOutlet.image = nil
                messageButtonOutlet.enabled = false
                
                
            } else {
                
                squadButtonOutlet.enabled = true
                messageButtonOutlet.enabled = true
                
                var youreInMySquad = false
                var iSentYou = false
                var youSentMe = false
                
                if let squad = data["squad"] as? [NSObject : AnyObject] {
                    
                    if squad[selfUID] != nil {
                        
                        youreInMySquad = true
                        
                        
                    }
                }
                
                if let mySquadRequests = self.profileController?.rootController?.selfData["squadRequests"] as? [NSObject : AnyObject] {
                    
                    for (key, _) in mySquadRequests {
                        
                        if let squadUID = key as? String {
                            
                            if userUID == squadUID {
                                
                                youSentMe = true
                                
                            }
                        }
                    }
                }
                
                if let yourSquadRequests = data["squadRequests"] as? [NSObject : AnyObject] {
                    
                    for (key, _) in yourSquadRequests {
                        
                        if let squadUID = key as? String {
                            
                            if selfUID == squadUID {
                                
                                iSentYou = true
                                
                            }
                        }
                    }
                }
                
                
                if youreInMySquad {
                    
                    squadImageOutlet.image = UIImage(named: "inSquad")
                    messageImageOutlet.image = UIImage(named: "enabledMessage")
                    messageButtonOutlet.enabled = true
                    
                    currentInstance = "inSquad"
                    
                    
                } else {
                    
                    if iSentYou {
                        
                        squadImageOutlet.image = UIImage(named: "sentSquad")
                        messageImageOutlet.image = UIImage(named: "disabledMessage")
                        messageButtonOutlet.enabled = false
                        
                        currentInstance = "sentSquad"
                        
                    } else if youSentMe {
                        
                        squadImageOutlet.image = UIImage(named: "confirmSquad")
                        messageImageOutlet.image = UIImage(named: "disabledMessage")
                        messageButtonOutlet.enabled = false
                        
                        currentInstance = "confirmSquad"
                        
                    } else {
                        
                        squadImageOutlet.image = UIImage(named: "sendSquad")
                        messageImageOutlet.image = UIImage(named: "disabledMessage")
                        messageButtonOutlet.enabled = false
                        
                        currentInstance = "sendSquad"
                    }
                }
            }
        }
        
        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String, age = data["age"] as? NSTimeInterval {
            
            let date = NSDate(timeIntervalSince1970: age)
            let yearsAgo = timeAgoSince(date, showAccronym: false)
            
            nameOutlet.text = firstName + " " + lastName + ", \(String(yearsAgo))"
            
            self.firstName = firstName
            self.lastName = lastName
            
        }
        
        if let city = data["city"] as? String {
            
            var fullCity = city
            
            if let state = data["state"] as? String {
                fullCity += ", " + state
            }
            
            cityOutlet.text = fullCity
            
        } else if let state = data["state"] as? String {
            
            cityOutlet.text = state
            
        }
        
        
        
        if let occupation = data["occupation"] as? String {
            
            occupationOutlet.text = occupation
            
        } else {
            
            if let selfProfile = profileController?.selfProfile {
                
                if selfProfile {
                    
                    occupationOutlet.text = "Tap to add occupation!"
                    
                } else {
                    
                    occupationOutlet.text = nil
                    
                }
                
            } else {
                
                occupationOutlet.text = nil
            }
        }
    }
    
    
    //Actions
    @IBAction func squadRequest(sender: AnyObject) {
        print("squad request")
        
        let scopeUserData = data
        let scopeFirstName = firstName
        let scopeLastName = lastName
  
        
        if currentInstance == "inSquad" {
            
            //Delete Squad?
            print("delete squad?")
  
            let alertController = UIAlertController(title: "Delete \(firstName + " " + lastName) from your squad?", message: nil, preferredStyle: .ActionSheet)
            
            
            alertController.addAction(UIAlertAction(title: "Delete \(firstName)", style: .Destructive, handler: { (action) in

                if let userUID = scopeUserData["uid"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
                    let myRef = FIRDatabase.database().reference().child("users").child(selfUID)

                    myRef.child("notifications").child(userUID).child("squad").removeValue()
                    myRef.child("notifications").child(userUID).child("squadRequest").removeValue()
                    myRef.child("squad").child(userUID).removeValue()
                    myRef.child("squadRequests").child(userUID).removeValue()

                    let yourRef = FIRDatabase.database().reference().child("users").child(userUID)
                    
                    yourRef.child("notifications").child(selfUID).child("squad").removeValue()
                    yourRef.child("notifications").child(selfUID).child("squadRequest").removeValue()
                    yourRef.child("squad").child(selfUID).removeValue()
                    yourRef.child("squadRequests").child(selfUID).removeValue()
    
                }
            }))

            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                
                print("canceled")

            }))
            
            
            self.profileController?.presentViewController(alertController, animated: true, completion: {
                
                print("alert controller presented")

            })

        } else if currentInstance == "sentSquad" {
                
                //Cancel send?
                print("cancel send?")
                
                let alertController = UIAlertController(title: "Unsend squad request to \(firstName + " " + lastName)", message: nil, preferredStyle: .ActionSheet)
                
                alertController.addAction(UIAlertAction(title: "Unsend Request", style: .Destructive, handler: { (action) in
                    
                    if let userUID = scopeUserData["uid"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {
    
                        let ref = FIRDatabase.database().reference().child("users").child(userUID)
                        
                        ref.child("squadRequests").child(selfUID).removeValue()
                        ref.child("notifications").child(selfUID).child("squadRequest").removeValue()
                        
                    
                    }
                }))

                alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                    
                    print("canceled")

                }))
                
                self.profileController?.presentViewController(alertController, animated: true, completion: {
                    
                    print("alert controller presented")
 
                })

            } else if currentInstance == "confirmSquad" {
                
                //Confrim or Deny
                print("confirm or deny")

                let alertController = UIAlertController(title: "Confirm \(firstName + " " + lastName) to your squad?", message: nil, preferredStyle: .ActionSheet)
                
                alertController.addAction(UIAlertAction(title: "Add to Squad", style: .Default, handler: { (action) in

                    if let selfUID = FIRAuth.auth()?.currentUser?.uid, selfData = self.profileController?.rootController?.selfData, myFirstName = selfData["firstName"] as? String, myLastName = selfData["lastName"] as? String, scopeUID = scopeUserData["uid"] as? String {

                            let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
                            ref.child("notifications").child(scopeUID).child("squadRequest").updateChildValues(["status" : "approved"])
                            ref.child("squadRequests").child(scopeUID).removeValue()
                            
                            ref.child("squad").child(scopeUID).setValue(["firstName" : scopeFirstName, "lastName" : scopeLastName, "uid" : scopeUID])
                            
                            let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                            
                            let timeInterval = NSDate().timeIntervalSince1970

                            yourRef.child("notifications").child(selfUID).child("squadRequest").setValue(["firstName" : myFirstName, "lastName" : myLastName, "type" : "addedYou", "timeStamp" : timeInterval, "uid" : selfUID, "read" : false])
                            
                            yourRef.child("squad").child(selfUID).setValue(["firstName" : myFirstName, "lastName" : myLastName, "uid" : selfUID])
       
                        }

                    
                }))
                
                alertController.addAction(UIAlertAction(title: "Reject \(firstName)", style: .Destructive, handler: { (action) in
   
                    
                    if let selfUID = FIRAuth.auth()?.currentUser?.uid, scopeUID = scopeUserData["uid"] as? String {
                        
                        let ref =  FIRDatabase.database().reference().child("users").child(selfUID)

                            ref.child("notifications").child(scopeUID).child("squadRequest").removeValue()
                            ref.child("squadRequests").child(scopeUID).removeValue()

                    }
                }))

                alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                    
                    print("canceled")
 
                }))
                
                self.profileController?.presentViewController(alertController, animated: true, completion: {
                    
                    print("alert controller presented")
                    

                })
                
                
            } else {
                
                //Send a request
                print("send a request")
                
                let alertController = UIAlertController(title: "Add \(firstName + " " + lastName) to your squad!", message: nil, preferredStyle: .ActionSheet)
                
                alertController.addAction(UIAlertAction(title: "Send Request", style: .Default, handler: { (action) in


                    
                    if let userUID = scopeUserData["uid"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid, selfData = self.profileController?.rootController?.selfData, firstName = selfData["firstName"] as? String, lastName = selfData["lastName"] as? String {
                        
                        let timeInterval = NSDate().timeIntervalSince1970
                        
                        //0 -> Hasn't responded yet, 1 -> Approved, 2 -> Denied
                        
                        let ref = FIRDatabase.database().reference().child("users").child(userUID)
    
                        let squadItem = ["uid" : selfUID, "read" : false, "status": 0, "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName]
                        
                        let notificationItem = ["uid" : selfUID, "read" : false, "status" : "awaitingAction", "type" : "squadRequest", "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName]
                        
                        ref.child("squadRequests").child(selfUID).setValue(squadItem)
                        ref.child("notifications").child(selfUID).child("squadRequest").setValue(notificationItem)
                        
                    }
                }))
                
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                    
                    print("canceled")
 

                    
                }))
                
                self.profileController?.presentViewController(alertController, animated: true, completion: {
                    
                    print("alert controller presented")
                    


                    
                })
        }
    }
    
    
    @IBAction func message(sender: AnyObject) {
        print("send message")
        
        let profile = profileController?.profile1
        
        self.profileController?.rootController?.toggleChat("squad", key: uid, city: nil, firstName: firstName, lastName: lastName, profile: profile, completion: { (bool) in
            
            print("chat toggled")

        })
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
