//
//  SettingsViewController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-10-15.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import NYAlertViewController
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class SettingsViewController: UIViewController {
    
    weak var rootController: MainRootController?
    
    @IBOutlet weak var maleButtonView: NavButtonView!
    @IBOutlet weak var maleButtonOutlet: UIButton!
    @IBOutlet weak var femaleButtonView: NavButtonView!
    @IBOutlet weak var femaleButtonOutlet: UIButton!
    
    @IBOutlet weak var intoMenView: NavButtonView!
    @IBOutlet weak var intoMenOutlet: UIButton!
    @IBOutlet weak var intoWomenView: NavButtonView!
    @IBOutlet weak var intoWomenOutlet: UIButton!
    @IBOutlet weak var intoBothView: NavButtonView!
    @IBOutlet weak var intoBothOutlet: UIButton!
    
    
    @IBOutlet weak var logOutViewOutlet: UIView!
    
    
    
    @IBAction func imMale(sender: AnyObject) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("gender").setValue("male")
            toggleGenderColour(1)
            
        }
        
        
        
    }
    
    
    @IBAction func imFemale(sender: AnyObject) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("gender").setValue("female")
            toggleGenderColour(2)
            
        }
        
    }
    
    
    
    
    @IBAction func intoMen(sender: AnyObject) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("interestedIn").setValue(["male"])
            toggleInterestedInColor(1)
            
        }
        
    }
    
    
    @IBAction func intoWomen(sender: AnyObject) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("interestedIn").setValue(["female"])
            toggleInterestedInColor(2)
            
        }
        
    }
    
    
    @IBAction func intoBoth(sender: AnyObject) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("interestedIn").setValue(["male", "female"])
            toggleInterestedInColor(3)
            
        }
        
    }
    
    
    
    @IBAction func deleteAccount(sender: AnyObject) {
        
        let alertController = NYAlertViewController()
        
        alertController.title = "Delete Account?"
        alertController.titleColor = UIColor.redColor()
        alertController.message = "This will delete your account along with all its contents. You will lose all made connections and no longer appear visible. Warning, your past account history will not be retrievable. You can always sign back in with Facebook, creating a new account."
        alertController.messageColor = UIColor.darkGrayColor()
        alertController.cancelButtonColor = UIColor.lightGrayColor()
        alertController.cancelButtonTitleColor = UIColor.whiteColor()
        alertController.buttonColor = UIColor.redColor()
        alertController.buttonTitleColor = UIColor.whiteColor()
        
        alertController.addAction(NYAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        alertController.addAction(NYAlertAction(title: "Delete", style: .Default, handler: { (action) in
            
            if let currentUser = FIRAuth.auth()?.currentUser {
                
                let myUID = currentUser.uid
                
                self.dismissViewControllerAnimated(true, completion: {

                    let myRef = FIRDatabase.database().reference().child("users").child(myUID)
                    
                    myRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        
                        
                        if let myData = snapshot.value as? [NSObject : AnyObject] {
                            
                            if let mySquad = myData["squad"] as? [NSObject : AnyObject] {
                                
                                for (_, value) in mySquad {
                                    
                                    if let uid = value["uid"] as? String {
                                        
                                        FIRDatabase.database().reference().child("users").child(uid).child("squad").child(myUID)
                                            .removeValue()
                                    }
                                }
                            }
                            
                            if let myMatches = myData["matches"] as? [NSObject : AnyObject] {
                                
                                for (_, value) in myMatches {
                                    
                                    if let uid = value ["uid"] as? String {
                                        
                                        FIRDatabase.database().reference().child("users").child(uid).child("matches").child(myUID).removeValue()
                                        
                                    }
                                }
                            }
                            
                            if let myGroupChats = myData["groupChats"] as? [NSObject : AnyObject] {
                                
                                for (_, chat) in myGroupChats {
                                    
                                    if let key = chat["key"] as? String, members = chat["members"] as? [String : Bool] {
                                        
                                        var newMembers = members
                                        newMembers.removeValueForKey(myUID)
                                        
                                        FIRDatabase.database().reference().child("groupChats").child(key).child("members").setValue(newMembers)
                                        
                                        for (member, _) in members {
                                            FIRDatabase.database().reference().child("users").child(member).child("groupChats").child(key).child("members").setValue(newMembers)
                                            
                                        }
                                    }
                                }
                            }
                            
                            
                            FIRDatabase.database().reference().child("users").child(myUID).removeValue()
                            FIRDatabase.database().reference().child("userLocations").child(myUID).removeValue()
                            FIRDatabase.database().reference().child("userScores").child(myUID).removeValue()
                            FIRDatabase.database().reference().child("userUIDs").child(myUID).removeValue()
                            
                            FIRDatabase.database().reference().child("lastCityRank").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                
                                if let rank = snapshot.value as? Int {
                                    
                                    FIRDatabase.database().reference().child("lastCityRank").setValue(rank - 1)
                                    
                                }
                            })
                            
                            currentUser.deleteWithCompletion({ (error) in
                                
                                if error == nil {
                                    
                                    FBSDKLoginManager().logOut()
                                    
                                    do {
                                        try FIRAuth.auth()?.signOut()
                                    } catch let signOutError {
                                        print(signOutError)
                                    }
                                    
                                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("initial") as! LogInController
                                    
                                    self.presentViewController(vc, animated: true) {
                                        
                                    }
                                }
                            })
                        }
                    })
                })
            }
        }))
        
        self.presentViewController(alertController, animated: true) {
            
            print("alert controller presented")
            
        }
    }
    
    @IBAction func logOut(sender: AnyObject) {
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            FBSDKLoginManager().logOut()
            
            var scopeError: ErrorType?
            
            do {
                try FIRAuth.auth()?.signOut()
            } catch let error {
                
                scopeError = error
                
                print(error)
            }
            
            if scopeError == nil {
                
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("initial") as! LogInController
                
                presentViewController(vc, animated: true) {
                    
                    FIRDatabase.database().reference().child("users").child(uid).child("online").setValue(false)
                    
                }
            }
        }
    }
    
    @IBAction func contactUs(sender: AnyObject) {
        
        rootController?.toggleContactUs({ (bool) in
            
            print("contact us toggled")
            
        })
        
        
    }
    
    @IBAction func back(sender: AnyObject) {
        
        rootController?.toggleSettings({ (bool) in
            
            print("settings closed")
            
        })
    }
    
    func toggleGenderColour(button: Int) {
        
        if button == 1 {
            
            maleButtonView.backgroundColor = UIColor.whiteColor()
            maleButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), forState: .Normal)
            
            femaleButtonView.backgroundColor = UIColor.clearColor()
            femaleButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            
        } else if button == 2 {
            
            femaleButtonView.backgroundColor = UIColor.whiteColor()
            femaleButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), forState: .Normal)
            
            maleButtonView.backgroundColor = UIColor.clearColor()
            maleButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            
        }
    }
    
    func toggleInterestedInColor(button: Int) {
        
        self.rootController?.nearbyController?.addedCells.removeAll()
        self.rootController?.nearbyController?.dismissedCells.removeAll()
        self.rootController?.nearbyController?.nearbyUsers.removeAll()
        self.rootController?.nearbyController?.users.removeAll()
        
        if let myLatitude = self.rootController?.selfData["latitude"] as? CLLocationDegrees, myLongitude = self.rootController?.selfData["longitude"] as? CLLocationDegrees {
            
            let myLocation = CLLocation(latitude: myLatitude, longitude: myLongitude)
            
            self.rootController?.nearbyController?.queryNearby(myLocation)
            
            
        }
        
        
        if button == 1 {
            
            intoMenView.backgroundColor = UIColor.whiteColor()
            intoMenOutlet.setTitleColor(UIColor(netHex: 0xDF412E), forState: .Normal)
            
            intoWomenView.backgroundColor = UIColor.clearColor()
            intoWomenOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            intoBothView.backgroundColor = UIColor.clearColor()
            intoBothOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            
        } else if button == 2 {
            
            intoMenView.backgroundColor = UIColor.clearColor()
            intoMenOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            intoWomenView.backgroundColor = UIColor.whiteColor()
            intoWomenOutlet.setTitleColor(UIColor(netHex: 0xDF412E), forState: .Normal)
            
            intoBothView.backgroundColor = UIColor.clearColor()
            intoBothOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            
        } else if button == 3 {
            
            intoMenView.backgroundColor = UIColor.clearColor()
            intoMenOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            intoWomenView.backgroundColor = UIColor.clearColor()
            intoWomenOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            intoBothView.backgroundColor = UIColor.whiteColor()
            intoBothOutlet.setTitleColor(UIColor(netHex: 0xDF412E), forState: .Normal)
            
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logOutViewOutlet.layer.cornerRadius = 12
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
