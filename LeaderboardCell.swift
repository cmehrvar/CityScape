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
    
    func loadCell(uid: String) {
        
        self.uid = uid
        
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        
        ref.child("profilePicture").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if self.uid == uid {
                
                if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                    
                    self.profileOutlet.sd_setImageWithURL(url)
                    
                }
            }
        })
        
        ref.child("firstName").observeSingleEventOfType(.Value, withBlock: { (firstSnapshot) in
            
            if let firstName = firstSnapshot.value as? String {
                
                ref.child("lastName").observeSingleEventOfType(.Value, withBlock: { (secondSnapshot) in
                    
                    if let lastName = secondSnapshot.value as? String {
                        
                        if self.uid == uid {
                            
                            self.nameOutlet.text = firstName + " " + lastName
                            
                        }
                    }
                })
            }
        })
        
        ref.child("online").observeEventType(.Value, withBlock: { (snapshot) in
            
            if let online = snapshot.value as? Bool {
                
                if self.uid == uid {
                    
                    if online {
                        
                        self.onlineIndicatorOutlet.backgroundColor = UIColor.greenColor()
                        
                    }  else {
                        
                        self.onlineIndicatorOutlet.backgroundColor = UIColor.redColor()
                        
                    }
                }
            }
        })
        
        
        ref.child("city").observeSingleEventOfType(.Value, withBlock: { (firstSnapshot) in
            
            if let city = firstSnapshot.value as? String {
                
                ref.child("state").observeSingleEventOfType(.Value, withBlock: { (secondSnapshot) in
                    
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
