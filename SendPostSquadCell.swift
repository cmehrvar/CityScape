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
        
        if let selectedUsers = handleController?.userSelected {
            
            if selectedUsers[uid] != nil {
                
                //Remove
                if let last = handleController?.selectedSquad.last, index = handleController?.userSelected[uid] {
                    
                    handleController?.selectedSquad[index] = last
                    
                    if let uid = last["uid"] as? String {
                        
                        handleController?.userSelected[uid] = index
                        
                    }
                    
                    handleController?.selectedSquad.removeLast()
                    handleController?.userSelected.removeValueForKey(uid)

                    handleController?.globTableViewOutlet.reloadData()
                    
                }
                
            } else {
                
                
                if let count = handleController?.selectedSquad.count {
                    
                    handleController?.userSelected[uid] = count

                    //Add
                    handleController?.selectedSquad.append(userData)
                    handleController?.globTableViewOutlet.reloadData()
                    
                }
            }
            
        } else {
            
            if let count = handleController?.selectedSquad.count {
                
                handleController?.userSelected[uid] = count
                
            }
            
            //Add
            handleController?.selectedSquad.append(userData)
            
            handleController?.globTableViewOutlet.reloadData()

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
            
            if (handleController?.userSelected[uid]) != nil {
                
                self.selectedImageOutlet.image = UIImage(named: "Checkmark")
                
            } else {
                
                self.selectedImageOutlet.image = nil
                
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
