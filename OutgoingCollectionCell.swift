//
//  OutgoingCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-29.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class OutgoingCollectionCell: UICollectionViewCell {
    
    var uid = ""
    
    @IBOutlet weak var profileOutlet: TopChatProfileView!
    @IBOutlet weak var messageBubbleOutlet: UIView!
    @IBOutlet weak var textOutlet: UILabel!
    
    func loadData(_ data: [AnyHashable: Any]){
        
        messageBubbleOutlet.layer.cornerRadius = 8
        
        if let text = data["text"] as? String {
            
            textOutlet.text = text
            
        }
        
        if let uid = data["senderId"] as? String {
            
            self.uid = uid
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            ref.child("profilePicture").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                    
                    if self.uid == uid {
                        
                        self.profileOutlet.sd_setImage(with: url, placeholderImage: nil)
                        
                    }
                }
            })
        }
    }
    
    
    override func prepareForReuse() {
        
        profileOutlet.image = nil
        textOutlet.text = nil
        
    }
    
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }

    
}
