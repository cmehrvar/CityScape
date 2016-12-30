//
//  AddToChatCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-28.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class AddToChatCollectionCell: UICollectionViewCell {
    
    var uid = ""
    
    @IBOutlet weak var profileOutlet: MessageProfileView!
    @IBOutlet weak var onlineIndicatorOutlet: TableViewOnlineIndicatorView!
    @IBOutlet weak var firstNameOutlet: UILabel!
    
    
    func loadCell(_ data: [AnyHashable: Any]) {
        
        onlineIndicatorOutlet.alpha = 0.75
        
        if let firstName = data["firstName"] as? String {
            
            self.firstNameOutlet.text = firstName
            
        }

        if let uid = data["uid"] as? String {
            
            self.uid = uid
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            ref.child("profilePicture").observe(.value, with: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                        
                        self.profileOutlet.sd_setImage(with: url, placeholderImage: nil)

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
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
