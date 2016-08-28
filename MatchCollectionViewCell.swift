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
    
    
    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var indicatorOutlet: UIView!
    
    
    func loadData(uid: String) {
        
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
