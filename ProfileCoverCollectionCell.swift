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
import NYAlertViewController

class ProfileInfoCollectionCell: UICollectionViewCell {
    
    //Variables
    weak var profileController: ProfileController?
    
    var currentInstance = ""
    
    var uid = ""
    var firstName = ""
    var lastName = ""

    var data = [AnyHashable: Any]()
    
    //Outlets
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityOutlet: UILabel!
    @IBOutlet weak var squadButtonOutlet: UIButton!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    @IBOutlet weak var occupationOutlet: UILabel!
    
    @IBOutlet weak var squadImageOutlet: UIImageView!
    @IBOutlet weak var messageImageOutlet: UIImageView!
    @IBOutlet weak var addOccupationOutletButton: UIButton!
    
    @IBOutlet weak var reportButtonOutlet: UIButton!
    @IBOutlet weak var reportIconOutlet: UIImageView!
    

    @IBAction func report(_ sender: AnyObject) {
        
        let scopeProfile = profileController
        let scopeUID = uid
        
        let alertController = NYAlertViewController()
        
        alertController.title = "Report \(firstName) \(lastName)?"
        alertController.message = "This will remove \(firstName) from your squad and delete \(firstName) from your matches. You will no longer see content generated from \(firstName). Warning, this cannot be undone."
        
        alertController.backgroundTapDismissalGestureEnabled = true
        
        alertController.alertViewBackgroundColor = UIColor.white
        
        alertController.titleColor = UIColor.black
        alertController.messageColor = UIColor.darkGray
        
        alertController.cancelButtonColor = UIColor.lightGray
        alertController.cancelButtonTitleColor = UIColor.white
        
        alertController.buttonColor = UIColor.red
        alertController.buttonTitleColor = UIColor.white
        
        alertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            print("cancel", terminator: "")
            
            self.profileController?.dismiss(animated: true, completion: nil)
            
        }))
        
        
        alertController.addAction(NYAlertAction(title: "Report", style: .default, handler: { (action) in
            
            print("report user", terminator: "")

            self.profileController?.dismiss(animated: true, completion: {
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
                    let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                    let myRef = FIRDatabase.database().reference().child("users").child(selfUID)
                    
                    myRef.child("reportedUsers").child(scopeUID).setValue(true)
                    
                    yourRef.child("squad").child(scopeUID).removeValue()
                    yourRef.child("matches").child(scopeUID).removeValue()
                    yourRef.child("notifications").child(scopeUID).removeValue()
                    
                    myRef.child("squad").child(scopeUID).removeValue()
                    myRef.child("matches").child(scopeUID).removeValue()
                    myRef.child("notifications").child(scopeUID).removeValue()
                    
                    
                    if let myReported = scopeProfile?.rootController?.selfData["reportedUsers"] as? [String : Bool] {

                        var temp = myReported
                        temp.updateValue(true, forKey: scopeUID)
                        scopeProfile?.rootController?.selfData.updateValue(temp, forKey: "reportedUsers")
                        
                    }

                    scopeProfile?.rootController?.toggleHome({ (bool) in
                        
                        scopeProfile?.rootController?.searchController?.userController?.observeUsers()
                        
                        scopeProfile?.rootController?.nearbyController?.nearbyUsers.removeAll()
                        scopeProfile?.rootController?.nearbyController?.addedCells.removeAll()
                        scopeProfile?.rootController?.nearbyController?.addedCells.removeAll()
                        scopeProfile?.rootController?.nearbyController?.dismissedCells.removeAll()
                        
                        if let myLocation = scopeProfile?.rootController?.nearbyController?.globLocation {
                            
                            scopeProfile?.rootController?.nearbyController?.queryNearby(myLocation)
                            
                            
                        }
                        
                        scopeProfile?.rootController?.clearVibesPlayers()
                        scopeProfile?.rootController?.vibesFeedController?.globCollectionView.contentOffset = CGPoint.zero
                        scopeProfile?.rootController?.vibesFeedController?.observePosts()
                        
                    })
                }
            })
        }))
        
        
        profileController?.present(alertController, animated: true, completion: {
            
            print("presented", terminator: "")
            
        })
    }
    

    @IBAction func addOccupation(_ sender: AnyObject) {
        
        let alertController = NYAlertViewController()
        
        var scopeTextField = UITextField()
        alertController.title = "Current Occupation"
        alertController.message = nil
        alertController.backgroundTapDismissalGestureEnabled = true
        
        alertController.cancelButtonColor = UIColor.lightGray
        alertController.cancelButtonTitleColor = UIColor.black
        
        alertController.buttonColor = UIColor.red
        alertController.buttonTitleColor = UIColor.white
        
        alertController.addTextField { (textField) in
            
            textField?.placeholder = "Enter current occupation..."
            textField?.autocorrectionType = .no
            scopeTextField = textField!
            
        }
        
        alertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            self.profileController?.dismiss(animated: true, completion: nil)
            
        }))

        alertController.addAction(NYAlertAction(title: "Add", style: .default, handler: { (action) in

            self.profileController?.dismiss(animated: true, completion: {
                
                if scopeTextField.text != "" || scopeTextField.text != nil {
                    
                    if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        FIRDatabase.database().reference().child("users").child(selfUID).child("occupation").setValue(scopeTextField.text)
                        
                    }
                }
            })
        }))
        
        self.profileController?.present(alertController, animated: true, completion: {
            
            print("alert controller presented", terminator: "")
            
        })
    }
    
    //Functions
    func loadData(_ data: [AnyHashable: Any]){
        
        self.data = data

        if let userUID = data["uid"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            self.uid = userUID
            
            if userUID == selfUID {

                reportIconOutlet.image = nil
                reportButtonOutlet.isEnabled = false
                
                squadImageOutlet.image = nil
                squadButtonOutlet.isEnabled = false
                
                messageImageOutlet.image = nil
                messageButtonOutlet.isEnabled = false
                
                
            } else {
                
                reportIconOutlet.image = UIImage(named: "reportIcon")
                reportButtonOutlet.isEnabled = true

                squadButtonOutlet.isEnabled = true
                messageButtonOutlet.isEnabled = true
                
                var youreInMySquad = false
                var iSentYou = false
                var youSentMe = false
                
                if let squad = data["squad"] as? [AnyHashable: Any] {
                    
                    if squad[selfUID] != nil {
                        
                        youreInMySquad = true

                    }
                }
                
                if let mySquadRequests = self.profileController?.rootController?.selfData["squadRequests"] as? [AnyHashable: Any] {
                    
                    for (key, _) in mySquadRequests {
                        
                        if let squadUID = key as? String {
                            
                            if userUID == squadUID {
                                
                                youSentMe = true
                                
                            }
                        }
                    }
                }
                
                if let yourSquadRequests = data["squadRequests"] as? [AnyHashable: Any] {
                    
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
                    messageButtonOutlet.isEnabled = true
                    
                    currentInstance = "inSquad"
                    
                    
                } else {
                    
                    if iSentYou {
                        
                        squadImageOutlet.image = UIImage(named: "sentSquad")
                        messageImageOutlet.image = UIImage(named: "disabledMessage")
                        messageButtonOutlet.isEnabled = false
                        
                        currentInstance = "sentSquad"
                        
                    } else if youSentMe {
                        
                        squadImageOutlet.image = UIImage(named: "confirmSquad")
                        messageImageOutlet.image = UIImage(named: "disabledMessage")
                        messageButtonOutlet.isEnabled = false
                        
                        currentInstance = "confirmSquad"
                        
                    } else {
                        
                        squadImageOutlet.image = UIImage(named: "sendSquad")
                        messageImageOutlet.image = UIImage(named: "disabledMessage")
                        messageButtonOutlet.isEnabled = false
                        
                        currentInstance = "sendSquad"
                    }
                }
            }
        }
        
        if let firstName = data["firstName"] as? String, let lastName = data["lastName"] as? String, let age = data["age"] as? TimeInterval {
            
            let date = Date(timeIntervalSince1970: age)
            let yearsAgo = timeAgoSince(date: date as NSDate, showAccronym: false)
            
            nameOutlet.text = firstName + " " + lastName + ", " + yearsAgo
            
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
            
            if let selfProfile = profileController?.selfProfile {
                
                if selfProfile {
                    
                    addOccupationOutletButton.isEnabled = true
                    
                } else {
                    
                    addOccupationOutletButton.isEnabled = false
                    
                }
                
            }
            
        } else {
            
            if let selfProfile = profileController?.selfProfile {
                
                if selfProfile {
                    
                    occupationOutlet.text = "Tap to add occupation!"
                    addOccupationOutletButton.isEnabled = true
                    
                } else {
                    
                    occupationOutlet.text = nil
                    addOccupationOutletButton.isEnabled = false
                    
                }
                
            } else {
                
                occupationOutlet.text = nil
                addOccupationOutletButton.isEnabled = false
            }
        }
    }
    
    
    //Actions
    @IBAction func squadRequest(_ sender: AnyObject) {
        print("squad request", terminator: "")
        
        let scopeUserData = data
        let scopeFirstName = firstName
        let scopeLastName = lastName
  
        
        if currentInstance == "inSquad" {
            
            //Delete Squad?
            print("delete squad?", terminator: "")
  
            let alertController = UIAlertController(title: "Delete \(firstName + " " + lastName) from your squad?", message: nil, preferredStyle: .actionSheet)
            
            
            alertController.addAction(UIAlertAction(title: "Delete \(firstName)", style: .destructive, handler: { (action) in

                if let userUID = scopeUserData["uid"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
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

            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                print("canceled")

            }))
            
            
            self.profileController?.present(alertController, animated: true, completion: {
                
                print("alert controller presented")

            })

        } else if currentInstance == "sentSquad" {
                
                //Cancel send?
                print("cancel send?", terminator: "")
                
                let alertController = UIAlertController(title: "Unsend squad request to \(firstName + " " + lastName)", message: nil, preferredStyle: .actionSheet)
                
                alertController.addAction(UIAlertAction(title: "Unsend Request", style: .destructive, handler: { (action) in
                    
                    if let userUID = scopeUserData["uid"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
    
                        let ref = FIRDatabase.database().reference().child("users").child(userUID)
                        
                        ref.child("squadRequests").child(selfUID).removeValue()
                        ref.child("notifications").child(selfUID).child("squadRequest").removeValue()
                        
                    
                    }
                }))

                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    
                    print("canceled")

                }))
                
                self.profileController?.present(alertController, animated: true, completion: {
                    
                    print("alert controller presented")
 
                })

            } else if currentInstance == "confirmSquad" {
                
                //Confrim or Deny
                print("confirm or deny", terminator: "")

                let alertController = UIAlertController(title: "Confirm \(firstName + " " + lastName) to your squad?", message: nil, preferredStyle: .actionSheet)
                
                alertController.addAction(UIAlertAction(title: "Add to Squad", style: .default, handler: { (action) in


                    if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.profileController?.rootController?.selfData, let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String, let scopeUID = scopeUserData["uid"] as? String {

                        let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                        
                        yourRef.child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
 
                                    
                                    appDelegate.pushMessage(scopeUID, token: token, message: "\(myFirstName) is now in your squad!")

                                
                            }
                        })
                        
                            let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
                            ref.child("notifications").child(scopeUID).child("squadRequest").updateChildValues(["status" : "approved"])
                            ref.child("squadRequests").child(scopeUID).removeValue()
                            
                            ref.child("squad").child(scopeUID).setValue(["firstName" : scopeFirstName, "lastName" : scopeLastName, "uid" : scopeUID])
                            
                        
                            
                            let timeInterval = Date().timeIntervalSince1970

                            yourRef.child("notifications").child(selfUID).child("squadRequest").setValue(["firstName" : myFirstName, "lastName" : myLastName, "type" : "addedYou", "timeStamp" : timeInterval, "uid" : selfUID, "read" : false])
                            
                            yourRef.child("squad").child(selfUID).setValue(["firstName" : myFirstName, "lastName" : myLastName, "uid" : selfUID])
       
                        }

                    
                }))
                
                alertController.addAction(UIAlertAction(title: "Reject \(firstName)", style: .destructive, handler: { (action) in
   
                    
                    if let selfUID = FIRAuth.auth()?.currentUser?.uid, let scopeUID = scopeUserData["uid"] as? String {
                        
                        let ref =  FIRDatabase.database().reference().child("users").child(selfUID)

                            ref.child("notifications").child(scopeUID).child("squadRequest").removeValue()
                            ref.child("squadRequests").child(scopeUID).removeValue()

                    }
                }))

                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    
                    print("canceled")
 
                }))
                
                self.profileController?.present(alertController, animated: true, completion: {
                    
                    print("alert controller presented")
                    

                })
                
                
            } else {
                
                //Send a request
                print("send a request", terminator: "")
                
                let alertController = UIAlertController(title: "Add \(firstName + " " + lastName) to your squad!", message: nil, preferredStyle: .actionSheet)
                
                alertController.addAction(UIAlertAction(title: "Send Request", style: .default, handler: { (action) in

                    if let userUID = scopeUserData["uid"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.profileController?.rootController?.selfData, let firstName = selfData["firstName"] as? String, let lastName = selfData["lastName"] as? String {
                        
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
                        
                        ref.child("squadRequests").child(selfUID).setValue(squadItem)
                        ref.child("notifications").child(selfUID).child("squadRequest").setValue(notificationItem)
                        
                    }
                }))
                
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    
                    print("canceled")
 

                    
                }))
                
                self.profileController?.present(alertController, animated: true, completion: {
                    
                    print("alert controller presented")
                    


                    
                })
        }
    }
    
    
    @IBAction func message(_ sender: AnyObject) {
        print("send message", terminator: "")
        
        let profile = profileController?.profile1
        
        self.profileController?.rootController?.toggleChat("squad", key: uid, city: nil, firstName: firstName, lastName: lastName, profile: profile, completion: { (bool) in
            
            print("chat toggled", terminator: "")

        })
    }
    
    
    
    
    override func prepareForReuse() {

        nameOutlet.text = nil
        cityOutlet.text = nil
        occupationOutlet.text = nil
        squadImageOutlet.image = nil
        messageImageOutlet.image = nil

    }
    
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
