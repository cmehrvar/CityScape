//
//  ComposeChatCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-26.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ComposeChatCollectionCell: UICollectionViewCell {
    
    weak var composeController: ComposeChatController?
    
    var uid = ""
    
    @IBOutlet weak var profilePicOutlet: MessageProfileView!
    @IBOutlet weak var onlineIndicatorOutlet: TableViewOnlineIndicatorView!
    @IBOutlet weak var firstNameOutlet: UILabel!

    
    func loadData(data: [NSObject : AnyObject]) {

        if let firstName = data["firstName"] as? String {
            
            firstNameOutlet.text = firstName
            
        }
        
        if let uid = data["uid"] as? String {
            
            self.uid = uid
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)

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
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
