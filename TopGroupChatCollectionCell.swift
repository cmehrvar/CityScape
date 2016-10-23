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
    
    func loadData(_ uid: String) {
        
        self.uid = uid
        
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        
        ref.child("firstName").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if self.uid == uid {
                
                if let firstName = snapshot.value as? String {
                    
                    self.firstName = firstName
                    self.firstNameOutlet.text = firstName
                    
                }
            }
        })
        
        ref.child("lastName").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if self.uid == uid {
                
                if let lastName = snapshot.value as? String {
                    
                    self.lastName = lastName
                    
                }
            }
        })
        
        ref.child("profilePicture").observe(.value, with: { (snapshot) in
            
            if self.uid == uid {
                
                if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                    
                    self.profilePicOutlet.sd_setImage(with: url, placeholderImage: nil)
                    
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
    
    
    @IBAction func toProfile(_ sender: AnyObject) {
        
        let scopeUID = uid
        let name = firstName + " " + lastName

        let alertController = UIAlertController(title: "\(name)", message: "Go to \(name)'s profile?", preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Go to profile", style: .default, handler: { (action) in
            
            self.topChatController?.rootController?.toggleHome({ (bool) in
                
                self.topChatController?.rootController?.toggleProfile(scopeUID, selfProfile: false, completion: { (bool) in
                    
                    print("profile toggled", terminator: "")
                    
                })
            })
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            print("canceled", terminator: "")
            
        }))
        
        let popover = alertController.popoverPresentationController
        popover?.sourceView = self
        popover?.sourceRect = self.bounds
        popover?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        topChatController?.present(alertController, animated: true, completion: {
            
            print("controller presented", terminator: "")
            
        })
    }

    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
