//
//  InMediaCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-10-04.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


class InMediaCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var videoOutlet: UIView!
    @IBOutlet weak var profileOutlet: TopChatProfileView!
    @IBOutlet weak var nameOutlet: UILabel!
    
    var player = 0
    var isImage = false
    var key = ""
    
    func loadCell(_ showName: Bool, message: [AnyHashable: Any]) {
        
        imageOutlet.layer.borderWidth = 1
        videoOutlet.layer.borderWidth = 1
        
        imageOutlet.layer.borderColor = UIColor.darkGray.cgColor
        videoOutlet.layer.borderColor = UIColor.darkGray.cgColor
        
        imageOutlet.layer.cornerRadius = 12
        videoOutlet.layer.cornerRadius = 12
        
        
        if showName {
            
            if let name = message["senderDisplayName"] as? String {
                
                nameOutlet.text = name
                
            }
            
        } else {
            
            nameOutlet.text = nil
            
        }

        if let key = message["key"] as? String {
            
            self.key = key
            
            if let uid = message["senderId"] as? String {
                
                let userRef = FIRDatabase.database().reference().child("users").child(uid)
                
                userRef.child("profilePicture").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if !snapshot.exists() {
                        
                        if self.key == key {
                            
                            self.profileOutlet.image = UIImage(named: "appIcon")
                            
                        }
      
                    } else {
                        
                        if self.key == key {
                            
                            if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                                
                                self.profileOutlet.sd_setImage(with: url, placeholderImage: nil)
                                
                            }
                        }
                    }
                })
            }
            
            if let isImage = message["isImage"] as? Bool {
                
                self.isImage = isImage
                
                if isImage {
                    
                    if let imageURL = message["media"] as? String, let url = URL(string: imageURL) {
                        
                        imageOutlet.sd_setImage(with: url, placeholderImage: nil)
                        
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        
        imageOutlet.image = nil
        profileOutlet.image = nil
        nameOutlet.text = nil
        
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
    
}
