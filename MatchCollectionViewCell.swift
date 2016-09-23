//
//  MatchCollectionViewCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-27.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MatchCollectionViewCell: UICollectionViewCell {
    
    weak var messagesController: MessagesController?
    
    var index = 0
    var uid = ""
    var firstName = ""
    var lastName = ""
    var profileString = ""
    
    //Outlets
    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var indicatorOutlet: UIView!
    
    
    //Actions
    @IBAction func openChat(sender: AnyObject) {
        
        let mainRootController = messagesController?.rootController

        guard let selfUID = FIRAuth.auth()?.currentUser?.uid else {return}

        let refToPass = "/users/\(selfUID)/matches/\(uid)"
        
        messagesController?.rootController?.chatController?.passedRef = refToPass
        messagesController?.rootController?.chatController?.typeOfChat = "match"
        messagesController?.rootController?.chatController?.ownerUID = uid
        
        messagesController?.rootController?.bottomNavController?.chatNameOutlet.text = firstName + " " + lastName
        
        if let url = NSURL(string: profileString) {
            
            messagesController?.rootController?.bottomNavController?.chatProfileOutlet.sd_setImageWithURL(url, placeholderImage: nil)
            
        }
        
        messagesController?.rootController?.toggleChat({ (bool) in
            
            print("chat toggled")
            
            mainRootController?.chatController?.newObserveMessages()
            
        })
    }
    

    //Functions
    func loadCell(data: [NSObject : AnyObject]){
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        
        if let uid = data["uid"] as? String {
            
            self.uid = uid
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            ref.child("profilePicture").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                        
                        self.profileOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                        
                    }
                }
            })
 
            ref.child("online").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let online = snapshot.value as? Bool {
                        
                        if online {
                            
                            self.indicatorOutlet.backgroundColor = UIColor.greenColor()
                            
                        } else {
                            
                            self.indicatorOutlet.backgroundColor = UIColor.redColor()
                            
                        }
                    }
                }
            })
        }

        if let firstName = data["firstName"] as? String {
            
            self.firstName = firstName
            nameOutlet.text = firstName
            
        }
        
        if let lastName = data["lastName"] as? String {
            
            self.lastName = lastName

        }
    }

    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
