//
//  IncomingCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-29.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class IncomingCollectionCell: UICollectionViewCell {
    
    var uid = ""
    
    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var messageBubbleOutlet: UIView!
    @IBOutlet weak var textOutlet: UILabel!
    @IBOutlet weak var nameOutlet: UILabel!
    
    func loadData(_ loadName: Bool, data: [AnyHashable: Any]){
        
        self.profileOutlet.layer.cornerRadius = 17
        
        messageBubbleOutlet.layer.cornerRadius = 8
        
        if let text = data["text"] as? String {
            
            textOutlet.text = text
            
        }
        
        if let uid = data["senderId"] as? String {
            
            self.uid = uid
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            if loadName {
                
                profileOutlet.alpha = 1
                ref.child("profilePicture").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                        
                        if self.uid == uid {
                            
                            self.profileOutlet.sd_setImage(with: url, placeholderImage: nil)
                            
                        }
                    }
                })
            } else {
                
                profileOutlet.alpha = 0
                
            }
            
            if loadName {
                
                if let name = data["senderDisplayName"] as? String {
                    
                    self.nameOutlet.text = name
                    
                }
            } else {
                
                self.nameOutlet.text = ""
                
            }
        }
    }
    
    
    override func prepareForReuse() {
        
        profileOutlet.image = nil
        textOutlet.text = nil
        nameOutlet.text = nil

    }
    
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }

    
}
