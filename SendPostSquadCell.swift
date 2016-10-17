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
    var userData = [AnyHashable: Any]()
    var uid = ""
    
    @IBOutlet weak var profileOutlet: TableViewProfilePicView!
    @IBOutlet weak var onlineIndicatorOutlet: TableViewOnlineIndicatorView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var rankOutlet: UILabel!
    @IBOutlet weak var selectedImageOutlet: UIImageView!
    
    
    @IBAction func addToChat(_ sender: AnyObject) {
        
        if let selectedUsers = handleController?.selectedSquad {
            
            if selectedUsers[uid] != nil {
                
                //Remove
                self.handleController?.selectedSquad.removeValue(forKey: self.uid as NSObject)
                self.handleController?.globTableViewOutlet.reloadData()


            } else {
                
                print(uid, terminator: "")
                self.handleController?.selectedSquad.updateValue(self.userData as AnyObject, forKey: self.uid as NSObject)
                self.handleController?.globTableViewOutlet.reloadData()

            }
            
        } else {
            
            //Add
            self.handleController?.selectedSquad.updateValue(self.userData as AnyObject, forKey: self.uid as NSObject)
            self.handleController?.globTableViewOutlet.reloadData()

        }
        
        
        if let vc = handleController {
            
            if vc.selectedSquad.count == 0 {
                
                if vc.postToFeedSelected || vc.postToFacebookSelected {

                    vc.shareOutlet.isEnabled = true
                    
                } else {
                    
                    vc.shareOutlet.isEnabled = false
                    
                }
                
            } else {
                
                vc.shareOutlet.isEnabled = true
                
                
            }
        }
    }
    
    func loadData(_ data: [AnyHashable: Any]) {
        
        self.userData = data
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .alignCenters
        
        if let firstName = data["firstName"] as? String, let lastName = data["lastName"] as? String {
            
            self.nameOutlet.text = firstName + " " + lastName
            
        }
        
        if let uid = data["uid"] as? String {
            
            self.uid = uid
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            if (handleController?.selectedSquad[uid]) != nil {
                
                self.selectedImageOutlet.backgroundColor = UIColor.red
                
            } else {
                
                self.selectedImageOutlet.backgroundColor = UIColor.clear
            }
            
            ref.child("profilePicture").observe(.value, with: { (snapshot) in
                
                if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                    
                    if self.uid == uid {
                        
                        self.profileOutlet.sd_setImage(with: url, placeholderImage: nil)
                        
                    }
                }
            })
            
            ref.child("online").observe(.value, with: { (snapshot) in
                
                if let online = snapshot.value as? Bool {
                    
                    if self.uid == uid {
                        
                        if online {
                            
                            self.onlineIndicatorOutlet.backgroundColor = UIColor.green
                            
                        } else {
                            
                            self.onlineIndicatorOutlet.backgroundColor = UIColor.red
                            
                        }
                    }
                }
            })
            
            
            ref.child("cityRank").observeSingleEvent(of: .value, with: { (snapshot) in
                
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
