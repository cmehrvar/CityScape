//
//  LeaderboardCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-10-10.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class LeaderboardCell: UITableViewCell {

    weak var leaderController: LeaderboardController?
    
    var uid = ""
    
    @IBOutlet weak var rankOutlet: UILabel!
    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var onlineIndicatorOutlet: TableViewOnlineIndicatorView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityOutlet: UILabel!
    
    
    
    @IBAction func toProfile(_ sender: AnyObject) {
        
        var selfProfile = false
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if uid == selfUID {
                
                selfProfile = true
                
            }
        }
        
        leaderController?.rootController?.toggleProfile(uid, selfProfile: selfProfile, completion: { (bool) in
            
            
            
        })
    }

    func loadCell(_ uid: String) {
        
        self.uid = uid
        
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        ref.keepSynced(true)
        
        ref.child("profilePicture").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if self.uid == uid {
                
                if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                    
                    self.profileOutlet.sd_setImage(with: url)
                    
                }
            }
        })
        
        ref.child("firstName").observeSingleEvent(of: .value, with: { (firstSnapshot) in
            
            if let firstName = firstSnapshot.value as? String {
                
                ref.child("lastName").observeSingleEvent(of: .value, with: { (secondSnapshot) in
                    
                    if let lastName = secondSnapshot.value as? String {
                        
                        if self.uid == uid {
                            
                            self.nameOutlet.text = firstName + " " + lastName
                            
                        }
                    }
                })
            }
        })
        
        ref.child("online").observe(.value, with: { (snapshot) in
            
            if let online = snapshot.value as? Bool {
                
                if self.uid == uid {
                    
                    if online {
                        
                        self.onlineIndicatorOutlet.backgroundColor = UIColor.green
                        
                    }  else {
                        
                        self.onlineIndicatorOutlet.backgroundColor = UIColor.red
                        
                    }
                }
            }
        })
        
        
        ref.child("city").observeSingleEvent(of: .value, with: { (firstSnapshot) in
            
            if let city = firstSnapshot.value as? String {
                
                ref.child("state").observeSingleEvent(of: .value, with: { (secondSnapshot) in
                    
                    if let state = secondSnapshot.value as? String {
                        
                        if self.uid == uid {
                            
                            self.cityOutlet.text = city + ", " + state
                            
                        }
                    }
                })
            }
        })
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
