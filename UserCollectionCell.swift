//
//  UserCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-14.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class UserCollectionCell: UICollectionViewCell {
    
    weak var userController: UserController?
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var squadRequestButtonOutlet: UIButton!
    
    var userUID = ""

    @IBAction func goToUser(_ sender: AnyObject) {

        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            var selfProfile = false
            
            if uid == userUID {
                
                selfProfile = true
                
            }
            
            userController?.searchController?.rootController?.toggleProfile(userUID, selfProfile: selfProfile, completion: { (bool) in
                
                print("profile toggled")
                
            })
        }
    }

    func updateUI(_ data: [AnyHashable: Any]){
        
        userNameOutlet.adjustsFontSizeToFitWidth = true
        userNameOutlet.baselineAdjustment = .alignCenters
        
        
        if let uid = data["uid"] as? String {
            
            userUID = uid
            
        }
        
        
        if let firstName = data["firstName"] as? String, let lastName = data["lastName"] as? String {
            
            let name = firstName + " " + lastName
            
            userNameOutlet.text = name
            
        }
        
        if let profileString = data["profilePicture"] as? String, let url = URL(string: profileString){
            
            imageOutlet.sd_setImage(with: url)
            
        }
        
        cellView.layer.cornerRadius = 15
        
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
