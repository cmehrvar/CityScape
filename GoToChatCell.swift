//
//  GoToChatCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-29.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import NYAlertViewController
import Firebase
import FirebaseDatabase
import FirebaseAuth

class GoToChatCell: UICollectionViewCell {
    
    weak var vibesController: NewVibesController?
    var city = ""
    var postKey = ""
    var userUID = ""
    var firstName = ""
    var lastName = ""
    
    
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var reportOutlet: UIButton!
    @IBOutlet weak var reportIcon: UIImageView!
    
    
    @IBAction func revealChat(sender: AnyObject) {
        
        vibesController?.rootController?.toggleChat("posts", key: postKey, city: city, firstName: nil, lastName: nil, profile: nil, completion: { (bool) in
            
            print("chat toggled")
            
        })
    }

    @IBAction func report(sender: AnyObject) {
        
        let scopeUID = userUID
        
        let alertController = NYAlertViewController()
        
        alertController.title = "Report \(firstName) \(lastName)?"
        alertController.message = "This will remove \(firstName) from your squad and delete \(firstName) from your matches. You will no longer see content generated from \(firstName). Warning, this cannot be undone."
        
        alertController.backgroundTapDismissalGestureEnabled = true

        alertController.alertViewBackgroundColor = UIColor.whiteColor()
        
        alertController.titleColor = UIColor.blackColor()
        alertController.messageColor = UIColor.darkGrayColor()
        
        alertController.cancelButtonColor = UIColor.lightGrayColor()
        alertController.cancelButtonTitleColor = UIColor.whiteColor()

        alertController.buttonColor = UIColor.redColor()
        alertController.buttonTitleColor = UIColor.whiteColor()
        
        alertController.addAction(NYAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
            print("cancel")
            
            self.vibesController?.dismissViewControllerAnimated(true, completion: nil)
            
        }))

        
        alertController.addAction(NYAlertAction(title: "Report", style: .Default, handler: { (action) in
            
            print("report user")
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                let myRef = FIRDatabase.database().reference().child("users").child(selfUID)
                
                myRef.child("reportedUsers").child(scopeUID).setValue(true)
                myRef.child("squad").child(scopeUID).removeValue()
                myRef.child("matches").child(scopeUID).removeValue()
                myRef.child("notifications").child(scopeUID).removeValue()
                
                
                self.vibesController?.rootController?.selfData.updateValue([scopeUID : true], forKey: "reportedUsers")
                
                self.vibesController?.rootController?.clearVibesPlayers()
                self.vibesController?.globCollectionView.contentOffset = CGPointZero
                self.vibesController?.observePosts()
                
            }

            self.vibesController?.dismissViewControllerAnimated(true, completion: nil)
            
        }))

        
        vibesController?.presentViewController(alertController, animated: true, completion: {
            
            print("presented")
            
        })
    }
    
    
    func loadData(data: [NSObject : AnyObject]) {

        if let firstName = data["firstName"] as? String {
            
            self.firstName = firstName
            
        }
        
        if let lastName = data["lastName"] as? String {
            
            self.lastName = lastName
            
        }
        
        if let uid = data["userUID"] as? String {
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if uid == selfUID {
                    
                    self.reportIcon.image = nil
                    self.reportOutlet.enabled = false
                    
                } else {
                    
                    self.reportIcon.image = UIImage(named: "reportIcon")
                    self.reportOutlet.enabled = true
                    
                }
            }

            self.userUID = uid
            
        }
        
        if let scopeCity = data["city"] as? String {
            
            self.city = scopeCity
            
        }
        
        if let key = data["postChildKey"] as? String {
            
            self.postKey = key
            
        }
        
        if data["messages"] != nil {
            
            buttonOutlet.setTitle("Reveal chat", forState: .Normal)
            
        } else {
            
            buttonOutlet.setTitle("Start the conversation!", forState: .Normal)
            
        }
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }

}
