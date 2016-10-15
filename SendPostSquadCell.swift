//
//  SendPostSquadCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-10-06.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class SendPostSquadCell: UITableViewCell {

    weak var handleController: HandlePostController?
    var userData = [NSObject : AnyObject]()
    var uid = ""
    
    @IBOutlet weak var profileOutlet: TableViewProfilePicView!
    @IBOutlet weak var onlineIndicatorOutlet: TableViewOnlineIndicatorView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var rankOutlet: UILabel!
    @IBOutlet weak var selectedImageOutlet: UIImageView!
    
    
    @IBAction func addToChat(sender: AnyObject) {
        
        if let selectedUsers = handleController?.selectedSquad {
            
            if selectedUsers[uid] != nil {
                
                //Remove
                self.handleController?.selectedSquad.removeValueForKey(self.uid)
                self.handleController?.globTableViewOutlet.reloadData()


            } else {
                
                print(uid, terminator: "")
                self.handleController?.selectedSquad.updateValue(self.userData, forKey: self.uid)
                self.handleController?.globTableViewOutlet.reloadData()

            }
            
        } else {
            
            //Add
            self.handleController?.selectedSquad.updateValue(self.userData, forKey: self.uid)
            self.handleController?.globTableViewOutlet.reloadData()

        }
        
        
        if let vc = handleController {
            
            if vc.selectedSquad.count == 0 {
                
                if vc.postToFeedSelected {

                    vc.shareOutlet.enabled = true
                    
                } else {
                    
                    vc.shareOutlet.enabled = false
                    
                }
                
            } else {
                
                vc.shareOutlet.enabled = true
                
                
            }
        }
    }
    
    func loadData(data: [NSObject : AnyObject]) {
        
        self.userData = data
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .AlignCenters
        
        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {
            
            self.nameOutlet.text = firstName + " " + lastName
            
        }
        
        if let uid = data["uid"] as? String {
            
            self.uid = uid
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            if (handleController?.selectedSquad[uid]) != nil {
                
                self.selectedImageOutlet.backgroundColor = UIColor.redColor()
                
            } else {
                
                self.selectedImageOutlet.backgroundColor = UIColor.clearColor()
            }
            
            ref.child("profilePicture").observeEventType(.Value, withBlock: { (snapshot) in
                
                if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                    
                    if self.uid == uid {
                        
                        self.profileOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                        
                    }
                }
            })
            
            ref.child("online").observeEventType(.Value, withBlock: { (snapshot) in
                
                if let online = snapshot.value as? Bool {
                    
                    if self.uid == uid {
                        
                        if online {
                            
                            self.onlineIndicatorOutlet.backgroundColor = UIColor.greenColor()
                            
                        } else {
                            
                            self.onlineIndicatorOutlet.backgroundColor = UIColor.redColor()
                            
                        }
                    }
                }
            })
            
            
            ref.child("cityRank").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let rank = snapshot.value as? Int {
                        
                        self.rankOutlet.text = "#\(String(rank))"
                        
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
