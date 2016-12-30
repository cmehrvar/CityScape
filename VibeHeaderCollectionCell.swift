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
import NYAlertViewController

class VibeHeaderCollectionCell: UICollectionReusableView {
    
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
    @IBOutlet weak var onlineIndicatorOutlet: UIView!
    @IBOutlet weak var cityOutlet: UILabel!
    

    //Action
    @IBAction func squadRequest(_ sender: AnyObject) {
        
        let scopeUID = uid
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
            
            let alertController = NYAlertViewController()
            
            alertController.title = "\(firstName + " " + lastName)"
            alertController.titleColor = UIColor.black
            
            alertController.message = "Unsend squad request to \(firstName + " " + lastName)"
            alertController.messageColor = UIColor.black
            
            alertController.buttonColor = UIColor.red
            alertController.buttonTitleColor = UIColor.white
            
            alertController.cancelButtonColor = UIColor.lightGray
            alertController.cancelButtonTitleColor = UIColor.white
            
            if let imageToAdd = profilePicOutlet.image {
                
                DispatchQueue.main.async(execute: {
                    
                    let imageView = UIImageView(image: imageToAdd)
                    imageView.clipsToBounds = true
                    imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 1, constant: 0))
                    
                    imageView.contentMode = .scaleAspectFill
                    
                    alertController.alertViewContentView = imageView
                    
                })
            }
            
            alertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                self.vibesController?.dismiss(animated: true, completion: nil)
                
            }))
            
            alertController.addAction(NYAlertAction(title: "Unsend", style: .default, handler: { (action) in
                
                
                
                if let userUID = scopeUserData["userUID"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
                    let ref = FIRDatabase.database().reference().child("users").child(userUID)
                    
                    DispatchQueue.main.async(execute: {
                        
                        ref.child("squadRequests").child(selfUID).removeValue()
                        ref.child("notifications").child(selfUID).child("squadRequest").removeValue()
                        
                        self.vibesController?.globCollectionView.reloadData()
                        
                        self.vibesController?.dismiss(animated: true, completion: nil)
                        
                    })
                }
            }))

            self.vibesController?.present(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
            })

            
        } else if currentSquadInstance == "confirmSquad" {
            
            print("cancel send?", terminator: "")
            
            let alertController = NYAlertViewController()
            
            alertController.title = "\(firstName + " " + lastName)"
            alertController.titleColor = UIColor.black
            
            alertController.message = "\(firstName + " " + lastName) has requested to be in your squad. Wanna let em in?"
            alertController.messageColor = UIColor.black
            
            alertController.buttonColor = UIColor.red
            alertController.buttonTitleColor = UIColor.white
            
            alertController.cancelButtonColor = UIColor.lightGray
            alertController.cancelButtonTitleColor = UIColor.white
            
            if let imageToAdd = profilePicOutlet.image {
                
                DispatchQueue.main.async(execute: {
                    
                    let imageView = UIImageView(image: imageToAdd)
                    imageView.clipsToBounds = true
                    imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 1, constant: 0))
                    
                    imageView.contentMode = .scaleAspectFill
                    
                    alertController.alertViewContentView = imageView
                    
                })
            }
            
            alertController.addAction(NYAlertAction(title: "Add to Squad", style: .default, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.vibesController?.rootController?.selfData, let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String, let scopeUID = scopeUserData["uid"] as? String {
                    
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
                    
                    self.vibesController?.globCollectionView.reloadData()
                    
                    self.vibesController?.dismiss(animated: true, completion: nil)
                    
                }
            }))

            alertController.addAction(NYAlertAction(title: "Reject", style: .cancel, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, let scopeUID = scopeUserData["userUID"] as? String {
                    
                    let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
                    
                    DispatchQueue.main.async(execute: {
                        
                        ref.child("notifications").child(scopeUID).child("squadRequest").removeValue()
                        ref.child("squadRequests").child(scopeUID).removeValue()
                        
                        self.vibesController?.globCollectionView.reloadData()
                        self.vibesController?.dismiss(animated: true, completion: nil)
                        
                    })
                }
            }))
            
            alertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                self.vibesController?.dismiss(animated: true, completion: nil)
                
            }))
            
            
            self.vibesController?.present(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
            })

        } else {
            
            //Cancel send?
            print("cancel send?", terminator: "")
            
            let alertController = NYAlertViewController()
            
            alertController.title = "\(firstName + " " + lastName)"
            alertController.titleColor = UIColor.black
            
            alertController.message = "Wanna add to \(firstName + " " + lastName) your squad?"
            alertController.messageColor = UIColor.black
            
            alertController.buttonColor = UIColor.red
            alertController.buttonTitleColor = UIColor.white
            
            alertController.cancelButtonColor = UIColor.lightGray
            alertController.cancelButtonTitleColor = UIColor.white
            
            if let imageToAdd = profilePicOutlet.image {
                
                DispatchQueue.main.async(execute: {
                    
                    let imageView = UIImageView(image: imageToAdd)
                    imageView.clipsToBounds = true
                    imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 1, constant: 0))
                    
                    imageView.contentMode = .scaleAspectFill
                    
                    alertController.alertViewContentView = imageView
                    
                })
            }
            
            alertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                self.vibesController?.dismiss(animated: true, completion: nil)
                
            }))
            
            alertController.addAction(NYAlertAction(title: "Send Request", style: .default, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.vibesController?.rootController?.selfData, let firstName = selfData["firstName"] as? String, let lastName = selfData["lastName"] as? String, let scopeUID = scopeUserData["userUID"] as? String {
                    
                    let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                    yourRef.keepSynced(true)
                    yourRef.child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            
                            appDelegate.pushMessage(uid: scopeUID, token: token, message: "\(firstName) has sent you a squad request")
                            
                            
                        }
                    })
                    
                    
                    let timeInterval = Date().timeIntervalSince1970
                    
                    //0 -> Hasn't responded yet, 1 -> Approved, 2 -> Denied
                    let ref = FIRDatabase.database().reference().child("users").child(scopeUID)
                    
                    let squadItem = ["uid" : selfUID, "read" : false, "status": 0, "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName] as [String : Any]
                    
                    let notificationItem = ["uid" : selfUID, "read" : false, "status" : "awaitingAction", "type" : "squadRequest", "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName] as [String : Any]
                    
                    ref.child("squadRequests").child(selfUID).setValue(squadItem)
                    ref.child("notifications").child(selfUID).child("squadRequest").setValue(notificationItem)
                    
                    self.vibesController?.dismiss(animated: true, completion: nil)
                    
                    self.vibesController?.globCollectionView.reloadData()
                    
                }
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
        
        self.onlineIndicatorOutlet.layer.cornerRadius = 5
        
        self.data = data
        
        if vibesController?.rootController?.bottomNavController?.torontoOutlet.text == "The World" {
            
            if let city = data["city"] as? String {
                
                cityOutlet.text = city
                
            }

        } else {
            
            cityOutlet.text = ""
            
        }

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
                    
                    if let online = snapshot.value as? Bool {
                        
                        if online {
                            
                            self.onlineIndicatorOutlet.backgroundColor = UIColor.green

                        } else {
                            
                            self.onlineIndicatorOutlet.backgroundColor = UIColor.red
     
                        }
                    }
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

}
