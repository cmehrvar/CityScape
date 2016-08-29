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
    
    var uid = ""
    
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
        messagesController?.rootController?.chatController?.matchUID = uid
        
        messagesController?.rootController?.toggleChat({ (bool) in
            
            print("chat toggled")
            
            mainRootController?.chatController?.newObserveMessages()
            
        })
    }
    
    
    
    //Functions
    func loadData() {
        
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        
        ref.child("profilePicture").observeEventType(.Value, withBlock: { (snapshot) in
            
            if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                
                self.profileOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                
            }
        })
        
        
        ref.child("online").observeEventType(.Value, withBlock: { (snapshot) in
            
            if let online = snapshot.value as? Bool {
                
                if online {
                    
                    self.indicatorOutlet.backgroundColor = UIColor.greenColor()
                    
                } else {
                    
                    self.indicatorOutlet.backgroundColor = UIColor.redColor()
                    
                }
            }
        })
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
