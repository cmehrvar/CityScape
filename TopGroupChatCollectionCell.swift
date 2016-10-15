//
//  TopGroupChatCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-28.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class TopGroupChatCollectionCell: UICollectionViewCell {
    
    weak var topChatController: TopChatController?
    
    var uid = ""
    var firstName = ""
    var lastName = ""
    
    @IBOutlet weak var profilePicOutlet: MessageProfileView!
    @IBOutlet weak var onlineIndicatorOutlet: TableViewOnlineIndicatorView!
    @IBOutlet weak var firstNameOutlet: UILabel!
    
    func loadData(uid: String) {
        
        self.uid = uid
        
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        
        ref.child("firstName").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if self.uid == uid {
                
                if let firstName = snapshot.value as? String {
                    
                    self.firstName = firstName
                    self.firstNameOutlet.text = firstName
                    
                }
            }
        })
        
        ref.child("lastName").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if self.uid == uid {
                
                if let lastName = snapshot.value as? String {
                    
                    self.lastName = lastName
                    
                }
            }
        })
        
        ref.child("profilePicture").observeEventType(.Value, withBlock: { (snapshot) in
            
            if self.uid == uid {
                
                if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                    
                    self.profilePicOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                    
                }
            }
        })
        
        
        ref.child("online").observeEventType(.Value, withBlock: { (snapshot) in
            
            if self.uid == uid {
                
                if let online = snapshot.value as? Bool {
                    
                    if online {
                        
                        self.onlineIndicatorOutlet.backgroundColor = UIColor.greenColor()
                        
                    } else {
                        
                        self.onlineIndicatorOutlet.backgroundColor = UIColor.redColor()
                        
                    }
                }
            }
        })
    }
    
    
    @IBAction func toProfile(sender: AnyObject) {
        
        let scopeUID = uid
        let name = firstName + " " + lastName

        let alertController = UIAlertController(title: "\(name)", message: "Go to \(name)'s profile?", preferredStyle: .ActionSheet)

        alertController.addAction(UIAlertAction(title: "Go to profile", style: .Default, handler: { (action) in
            
            self.topChatController?.rootController?.toggleHome({ (bool) in
                
                self.topChatController?.rootController?.toggleProfile(scopeUID, selfProfile: false, completion: { (bool) in
                    
                    print("profile toggled", terminator: "")
                    
                })
            })
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
            print("canceled", terminator: "")
            
        }))
        
        topChatController?.presentViewController(alertController, animated: true, completion: {
            
            print("controller presented", terminator: "")
            
        })
    }

    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
