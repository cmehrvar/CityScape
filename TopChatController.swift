//
//  TopChatController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-24.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class TopChatController: UIViewController {
    
    weak var rootController: MainRootController?
    
    @IBOutlet weak var icon1Outlet: UIImageView!
    @IBOutlet weak var profilePicOutlet: TopChatProfileView!
    @IBOutlet weak var icon2Outlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    
    var uid = ""
    var firstName = ""
    var lastName = ""
    var type = ""
    
    
    @IBAction func toProfile(sender: AnyObject) {
        
        let scopeUID = uid
        var selfProfile = false
        
        let scopeType = type
        
        let alertController = UIAlertController(title: "\(firstName + " " + lastName)", message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "Go to profile", style: .Default, handler: { (action) in
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if selfUID == scopeUID {
                    
                    selfProfile = true
                    
                }
            }
            
            self.rootController?.toggleHome({ (bool) in
                
                self.rootController?.toggleProfile(scopeUID, selfProfile: selfProfile, completion: { (bool) in
                    
                    print("profile toggled")
                    
                })
            })
        }))
        
        var title = ""
        
        if type == "matches" {
            
            title = "Delete Match"
            
        } else if type == "squad" {
            
            title = "Delete from squad"
            
        }
        
        
        alertController.addAction(UIAlertAction(title: title, style: .Destructive, handler: { (action) in
            
            self.rootController?.toggleHome({ (bool) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
                    let myRef = FIRDatabase.database().reference().child("users").child(selfUID)
                    let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                    
                    if scopeType == "matches" {
                        
                        myRef.child("notifications").child(scopeUID).child("matches").removeValue()
                        myRef.child("notifications").child(scopeUID).child("likesYou").removeValue()
                        myRef.child("matches").child(scopeUID).removeValue()
                        myRef.child("sentMatches").child(scopeUID).removeValue()
                        myRef.child("matchesDisplayed").child(scopeUID).removeValue()
                        
                        yourRef.child("notifications").child(selfUID).child("matches").removeValue()
                        yourRef.child("notifications").child(selfUID).child("likesYou").removeValue()
                        yourRef.child("matches").child(selfUID).removeValue()
                        yourRef.child("sentMatches").child(selfUID).removeValue()
                        yourRef.child("matchesDisplayed").child(selfUID).removeValue()
                        
                        
                    } else if scopeType == "squad" {
                        
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
 
                    }
                }
            })
        }))
        
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
            print("canceled")
            
        }))
        
        self.presentViewController(alertController, animated: true, completion: {
            
            print("alert controller presented")
            
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .AlignCenters
        
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
