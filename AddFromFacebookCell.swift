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
import NYAlertViewController

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
        
        let alertController = NYAlertViewController()
        
        alertController.title = "\(firstName + " " + lastName)"
        alertController.titleColor = UIColor.black
        
        alertController.message = "Remove \(firstName + " " + lastName) from your squad?"
        alertController.messageColor = UIColor.black
        
        alertController.buttonColor = UIColor.red
        alertController.buttonTitleColor = UIColor.white
        
        alertController.cancelButtonColor = UIColor.lightGray
        alertController.cancelButtonTitleColor = UIColor.white
        
        alertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            self.addFromFaceookController?.dismiss(animated: true, completion: nil)
            
        }))
        
        alertController.addAction(NYAlertAction(title:  "Delete \(firstName)", style: .default, handler: { (action) in
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                let myRef = FIRDatabase.database().reference().child("users").child(selfUID)
                
                myRef.child("notifications").child(scopeUID).child("squad").removeValue()
                myRef.child("notifications").child(scopeUID).child("squadRequest").removeValue()
                myRef.child("squad").child(scopeUID).removeValue()
                myRef.child("squadRequests").child(scopeUID).removeValue()
                
                let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                
                yourRef.child("notifications").child(selfUID).child("squad").removeValue()
                yourRef.child("notifications").child(selfUID).child("squadRequest").removeValue()
                yourRef.child("squad").child(selfUID).removeValue()
                yourRef.child("squadRequests").child(selfUID).removeValue()
                
                if let selfData = self.addFromFaceookController?.mainRootController?.selfData {
                    
                    var mySquad = selfData["squad"] as? [NSObject : AnyObject]
                    var mySquadRequests = selfData["squadRequests"] as? [NSObject : AnyObject]
                    
                    mySquad?.removeValue(forKey: scopeUID as NSObject)
                    mySquadRequests?.removeValue(forKey: scopeUID as NSObject)
                    
                    self.addFromFaceookController?.mainRootController?.selfData["squad"] = mySquad
                    self.addFromFaceookController?.mainRootController?.selfData["squadRequests"] = mySquadRequests
                    
                }
                
                self.addFromFaceookController?.globTableViewOutlet.reloadData()
                
            }
            
            self.addFromFaceookController?.dismiss(animated: true, completion: nil)

            
        }))

        self.addFromFaceookController?.present(alertController, animated: true, completion: {
            
            print("alert controller presented")
            
        })
    }
    
    @IBAction func messageSquad(_ sender: AnyObject) {
        
        let scopeUID = uid
        let scopeUserData = data
        let scopeFirstName = firstName
        let scopeLastName = lastName
        
        if currentSquadInstance == "inSquad" {
            
            //Delete Squad?
            print("toggle messages", terminator: "")
            
            self.addFromFaceookController?.mainRootController?.toggleChat("squad", key: uid, city: nil, firstName: firstName, lastName: lastName, profile: profile, completion: { (bool) in
                
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
                
                self.addFromFaceookController?.dismiss(animated: true, completion: nil)
                
            }))
            
            alertController.addAction(NYAlertAction(title: "Unsend", style: .default, handler: { (action) in
                
                if let userUID = scopeUserData["userUID"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
                    let ref = FIRDatabase.database().reference().child("users").child(userUID)
                    
                    DispatchQueue.main.async(execute: {
                        
                        ref.child("squadRequests").child(selfUID).removeValue()
                        ref.child("notifications").child(selfUID).child("squadRequest").removeValue()
                        
                        self.addFromFaceookController?.globTableViewOutlet.reloadData()
                        
                        self.addFromFaceookController?.dismiss(animated: true, completion: nil)
                        
                    })
                }
            }))
            
            self.addFromFaceookController?.present(alertController, animated: true, completion: {
                
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
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.addFromFaceookController?.mainRootController?.selfData, let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String, let scopeUID = scopeUserData["uid"] as? String {
                    
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
                    
                    self.addFromFaceookController?.globTableViewOutlet.reloadData()
                    
                    self.addFromFaceookController?.dismiss(animated: true, completion: nil)
                    
                }
            }))
            
            alertController.addAction(NYAlertAction(title: "Reject", style: .cancel, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, let scopeUID = scopeUserData["userUID"] as? String {
                    
                    let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
                    
                    DispatchQueue.main.async(execute: {
                        
                        ref.child("notifications").child(scopeUID).child("squadRequest").removeValue()
                        ref.child("squadRequests").child(scopeUID).removeValue()
                        
                        self.addFromFaceookController?.dismiss(animated: true, completion: nil)
                        self.addFromFaceookController?.globTableViewOutlet.reloadData()
                        
                    })
                }
            }))
            
            alertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                self.addFromFaceookController?.dismiss(animated: true, completion: nil)
                
            }))
            
            
            self.addFromFaceookController?.present(alertController, animated: true, completion: {
                
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
                
                self.addFromFaceookController?.dismiss(animated: true, completion: nil)
                
            }))
            
            alertController.addAction(NYAlertAction(title: "Send Request", style: .default, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.addFromFaceookController?.mainRootController?.selfData, let firstName = selfData["firstName"] as? String, let lastName = selfData["lastName"] as? String, let scopeUID = scopeUserData["userUID"] as? String {
                    
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
                    
                    self.addFromFaceookController?.dismiss(animated: true, completion: nil)
                    self.addFromFaceookController?.globTableViewOutlet.reloadData()
                    
                }
            }))
            
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
        
        self.data = data
        
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
                            
                            self.onlineIndicator.alpha = 0.75
                            
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
