//
//  VibeHeaderCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-03.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class VibeHeaderCollectionCell: UICollectionViewCell {
    
    weak var vibesController: NewVibesController?
    
    var data = [NSObject : AnyObject]()
    
    
    //Outlets
    @IBOutlet weak var profilePicOutlet: VibeHeaderProfilePic!
    @IBOutlet weak var cityRankOutlet: UILabel!
    @IBOutlet weak var nameOutlet: UILabel!
    
    
    
    //Action
    @IBAction func squadRequest(sender: AnyObject) {
        
        
        
        
    }
    
    
    @IBAction func toProfile(sender: AnyObject) {
        
        if let userUid = data["userUID"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {
         
            var selfProfile = false
            
            if userUid == selfUID {
                
                selfProfile = true
                
            }
            
            vibesController?.rootController?.toggleProfile(userUid, selfProfile: selfProfile, completion: { (bool) in
                
                print("profile toggled")
                
            })
        }
    }
    
    
    func loadCell(data: [NSObject : AnyObject]) {
        
        self.data = data
        
        if let profileString = data["profilePicture"] as? String, url = NSURL(string: profileString) {
            
            profilePicOutlet.sd_setImageWithURL(url, placeholderImage: nil)
            
        }
        
        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {
            
            let name = firstName + " " + lastName
            nameOutlet.text = name
            
        }
        
        if let rank = data["cityRank"] as? Int {
            
            cityRankOutlet.text = "#\(String(rank))"
            
        }

    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
