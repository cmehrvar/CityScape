//
//  SquadTableViewCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-21.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class SquadTableViewCell: UITableViewCell {
    
    var uid = ""
    var selfSquad = false

    weak var squadCountController: SquadCountController?
    
    //Outlets
    @IBOutlet weak var profilePicOutlet: TableViewProfilePicView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var rankOutlet: UILabel!
    @IBOutlet weak var onlineIndicator: TableViewOnlineIndicatorView!
    @IBOutlet weak var buttonIconOutlet: UIImageView!
    
    
    
    //Actions
    @IBAction func messageSquad(sender: AnyObject) {
        
        
    
    }
    
    
    @IBAction func toProfile(sender: AnyObject) {
        
        var selfProfile = false
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if self.uid == selfUID {
                
                selfProfile = true
                
            }
        }

        squadCountController?.rootController?.toggleProfile(uid, selfProfile: selfProfile, completion: { (bool) in
            
            print("profile toggled")
            
            self.squadCountController?.rootController?.toggleHome({ (bool) in
                
                print("home toggled")
                
            })
        })
    }

    
    //Functions
    func loadCell(data: [NSObject : AnyObject]) {
 

        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {
            
            let name = firstName + " " + lastName
            nameOutlet.text = name

        }
        
        if let uid = data["uid"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {
  
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            self.uid = uid
            
            if selfSquad {
                
                buttonIconOutlet.image = UIImage(named: "message")
                
            } else {
                
                if uid == selfUID {
                    
                    buttonIconOutlet.image = nil
                    
                } else {
                    
                    buttonIconOutlet.image = UIImage(named: "RedX")
                    
                }
            }


            ref.child("profilePicture").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                
                if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {

                        self.profilePicOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                    }
                    
                }
            })
            
            
            ref.child("cityRank").observeEventType(.Value, withBlock: { (snapshot) in

                if self.uid == uid {
                    
                    if let rank = snapshot.value as? Int {
                        
                        self.rankOutlet.text = "#\(rank)"
                        
                    }
                }
            })
            
            
            ref.child("online").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let online = snapshot.value as? Bool {

                        if selfUID == uid {
                            
                            self.onlineIndicator.alpha = 0
                            
                        } else {
                            
                            self.onlineIndicator.alpha = 1
                            
                            if online {
                                
                                self.onlineIndicator.backgroundColor = UIColor.greenColor()
                                
                            } else {
                                
                                self.onlineIndicator.backgroundColor = UIColor.redColor()
                                
                            }
                        }
                    }
                }
            })
        }
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
