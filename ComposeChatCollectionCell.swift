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
    
    func loadData(_ uid: String) {
        
        self.uid = uid
        
        let ref = FIRDatabase.database().reference().child("users").child(uid)

        ref.child("firstName").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let firstName = snapshot.value as? String {
                
                self.firstNameOutlet.text = firstName
                
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
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
