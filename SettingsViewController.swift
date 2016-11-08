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

    @IBAction func imMale(_ sender: AnyObject) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("gender").setValue("male")
            toggleGenderColour(1)
            
        }
    }

    @IBAction func imFemale(_ sender: AnyObject) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("gender").setValue("female")
            toggleGenderColour(2)
            
        }
    }

    @IBAction func intoMen(_ sender: AnyObject) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("interestedIn").setValue(["male"])
            toggleInterestedInColor(1)
            query()
            
        }
    }

    @IBAction func intoWomen(_ sender: AnyObject) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("interestedIn").setValue(["female"])
            toggleInterestedInColor(2)
            query()
            
        }
    }

    @IBAction func intoBoth(_ sender: AnyObject) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("interestedIn").setValue(["male", "female"])
            toggleInterestedInColor(3)
            query()
            
        }
    }

    @IBAction func deleteAccount(_ sender: AnyObject) {
        
        let alertController = NYAlertViewController()
        
        alertController.title = "Delete Account?"
        alertController.titleColor = UIColor.red
        alertController.message = "This will delete your account along with all its contents. You will lose all made connections and no longer appear visible. Warning, your past account history will not be retrievable. You can always sign back in with Facebook, creating a new account."
        alertController.messageColor = UIColor.darkGray
        alertController.cancelButtonColor = UIColor.lightGray
        alertController.cancelButtonTitleColor = UIColor.white
        alertController.buttonColor = UIColor.red
        alertController.buttonTitleColor = UIColor.white
        
        alertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alertController.addAction(NYAlertAction(title: "Delete", style: .default, handler: { (action) in
            
            if let currentUser = FIRAuth.auth()?.currentUser {
                
                let myUID = currentUser.uid
                
                self.dismiss(animated: true, completion: {

                        FIRDatabase.database().reference().child("leaders").child(myUID).removeValue()
                        
                        let myRef = FIRDatabase.database().reference().child("users").child(myUID)
                        
                        myRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if let myData = snapshot.value as? [AnyHashable: Any] {
                                
                                if let facebookId = myData["facebookId"] as? String {
                                    
                                    FIRDatabase.database().reference().child("facebookUIDs").child(facebookId).removeValue()
                                    
                                }
                                
                                if let mySquad = myData["squad"] as? [AnyHashable: Any] {
                                    
                                    for (_, value) in mySquad {
                                        
                                        if let squadMember = value as? [AnyHashable : Any], let uid = squadMember["uid"] as? String {
                                            
                                            FIRDatabase.database().reference().child("users").child(uid).child("notifications").child(myUID).removeValue()
                                            FIRDatabase.database().reference().child("users").child(uid).child("squad").child(myUID)
                                                .removeValue()
                                            
                                        }
                                    }
                                }
                                
                                if let myMatches = myData["matches"] as? [AnyHashable: Any] {
                                    
                                    for (_, value) in myMatches {
                                        
                                        if let matchMember = value as? [AnyHashable : Any], let uid = matchMember["uid"] as? String {
                                            
                                            FIRDatabase.database().reference().child("users").child(uid).child("notifications").child(myUID).removeValue()
                                            FIRDatabase.database().reference().child("users").child(uid).child("matches").child(myUID).removeValue()
                                            
                                        }
                                    }
                                }
                                
                                if let myGroupChats = myData["groupChats"] as? [AnyHashable: Any] {
                                    
                                    for (_, chat) in myGroupChats {
                                        
                                        if let chatValue = chat as? [AnyHashable : Any] {
                                            
                                            if let key = chatValue["key"] as? String, let members = chatValue["members"] as? [String : Bool] {
                                                
                                                var newMembers = members
                                                newMembers.removeValue(forKey: myUID)
           
                                                FIRDatabase.database().reference().child("groupChats").child(key).child("members").setValue(newMembers)
                                                
                                                for (member, _) in members {
                                                    
                                                    FIRDatabase.database().reference().child("users").child(member).child("notifications").child(myUID).removeValue()
                                                    
                                                    FIRDatabase.database().reference().child("users").child(member).child("groupChats").child(key).child("members").setValue(newMembers)
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                if let myPosts = myData["posts"] as? [AnyHashable : Any] {
                                    
                                    for (_, value) in myPosts {
                                        
                                        if let post = value as? [AnyHashable : Any], let city = post["city"] as? String, let key = post["postChildKey"] as? String {
                                            
                                            FIRDatabase.database().reference().child("posts").child(city).child(key).removeValue()
                                            FIRDatabase.database().reference().child("allPosts").child(key).removeValue()
                                            
                                            FIRDatabase.database().reference().child("posts").child(city).queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                                                
                                                if !snapshot.exists() {
                                                    
                                                    FIRDatabase.database().reference().child("cityLocations").child(city).removeValue()
                                                    
                                                }
                                            })
                                        }
                                    }
                                }
                                
                                
                                FIRDatabase.database().reference().child("users").child(myUID).removeValue()
                                FIRDatabase.database().reference().child("userLocations").child(myUID).removeValue()
                                FIRDatabase.database().reference().child("userScores").child(myUID).removeValue()
                                FIRDatabase.database().reference().child("userUIDs").child(myUID).removeValue()
                                
                                FIRDatabase.database().reference().child("lastCityRank").observeSingleEvent(of: .value, with: { (snapshot) in
                                    
                                    if let rank = snapshot.value as? Int {
                                        
                                        FIRDatabase.database().reference().child("lastCityRank").setValue(rank - 1)
                                        
                                    }
                                })
                                
                                
                                
                                
                                do {
                                    try FIRAuth.auth()?.signOut()
                                } catch let error {
                                    print(error)
                                }
                                
                                FBSDKLoginManager().logOut()
                                
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "initial") as! LogInController
                                
                                self.present(vc, animated: true) {
                                    
                                    currentUser.delete(completion: { (error) in
                                        
                                        if error == nil {
                                            
                                            print("user deleted")

                                        }
                                    })
                                }
                            }
                        })
                        
                    
                })
            }
        }))

        self.present(alertController, animated: true) {
            
            print("alert controller presented")
            
        }
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(uid).child("online").setValue(false)
            
            FBSDKLoginManager().logOut()
            
            var scopeError: Error?
            
            do {
                try FIRAuth.auth()?.signOut()
            } catch let error {
                
                scopeError = error
                
                print(error)
            }
            
            if scopeError == nil {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "initial") as! LogInController
                
                present(vc, animated: true) {
                    
                    
                    
                }
            }
        }
    }
    
    @IBAction func contactUs(_ sender: AnyObject) {
        
        rootController?.toggleContactUs({ (bool) in
            
            print("contact us toggled")
            
        })
        
        
    }
    
    @IBAction func back(_ sender: AnyObject) {
        
        rootController?.toggleSettings({ (bool) in
            
            print("settings closed")
            
        })
    }
    
    func toggleGenderColour(_ button: Int) {
        
        if button == 1 {
            
            maleButtonView.backgroundColor = UIColor.white
            maleButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), for: UIControlState())
            
            femaleButtonView.backgroundColor = UIColor.clear
            femaleButtonOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
            
        } else if button == 2 {
            
            femaleButtonView.backgroundColor = UIColor.white
            femaleButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), for: UIControlState())
            
            maleButtonView.backgroundColor = UIColor.clear
            maleButtonOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
            
        }
    }
    
    
    func query(){
        
        self.rootController?.nearbyController?.addedCells.removeAll()
        self.rootController?.nearbyController?.dismissedCells.removeAll()
        self.rootController?.nearbyController?.nearbyUsers.removeAll()
        self.rootController?.nearbyController?.users.removeAll()
        
        if let myLatitude = self.rootController?.selfData["latitude"] as? CLLocationDegrees, let myLongitude = self.rootController?.selfData["longitude"] as? CLLocationDegrees {
            
            let myLocation = CLLocation(latitude: myLatitude, longitude: myLongitude)
            
            self.rootController?.nearbyController?.queryNearby(myLocation)
            
        }
    }
    
    
    func toggleInterestedInColor(_ button: Int) {
        
        if button == 1 {
            
            intoMenView.backgroundColor = UIColor.white
            intoMenOutlet.setTitleColor(UIColor(netHex: 0xDF412E), for: UIControlState())
            
            intoWomenView.backgroundColor = UIColor.clear
            intoWomenOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
            intoBothView.backgroundColor = UIColor.clear
            intoBothOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
            
        } else if button == 2 {
            
            intoMenView.backgroundColor = UIColor.clear
            intoMenOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
            intoWomenView.backgroundColor = UIColor.white
            intoWomenOutlet.setTitleColor(UIColor(netHex: 0xDF412E), for: UIControlState())
            
            intoBothView.backgroundColor = UIColor.clear
            intoBothOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
            
        } else if button == 3 {
            
            intoMenView.backgroundColor = UIColor.clear
            intoMenOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
            intoWomenView.backgroundColor = UIColor.clear
            intoWomenOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
            intoBothView.backgroundColor = UIColor.white
            intoBothOutlet.setTitleColor(UIColor(netHex: 0xDF412E), for: UIControlState())
            
            
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
