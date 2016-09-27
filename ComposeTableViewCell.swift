//
//  ComposeTableViewCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-26.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ComposeTableViewCell: UITableViewCell {

    var userData = [NSObject : AnyObject]()
    
    weak var composeController: ComposeChatController?
    
    var uid = ""

    @IBOutlet weak var profilePicOutlet: TableViewProfilePicView!
    @IBOutlet weak var onlineIndicatorOutlet: UIView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var rankOutlet: UILabel!
    @IBOutlet weak var selectedIndicator: UIImageView!

    @IBAction func addRemoveFromChat(sender: AnyObject) {

        if let selectedUsers = composeController?.userSelected {
            
            if selectedUsers[uid] != nil {
                
                //Remove
                if let last = composeController?.selectedSquad.last, index = composeController?.userSelected[uid] {

                    self.composeController?.selectedSquad[index] = last
                    
                    if let uid = last["uid"] as? String {
                        
                        self.composeController?.userSelected[uid] = index
                        
                    }

                    self.composeController?.selectedSquad.removeLast()
                    composeController?.userSelected.removeValueForKey(uid)
                    
                    self.composeController?.globCollectionViewOutlet.reloadData()
                    self.composeController?.globTableViewOutlet.reloadData()

                }

            } else {
                
                
                if let count = composeController?.selectedSquad.count {
                    
                    composeController?.userSelected[uid] = count
                    
                }

                //Add
                composeController?.selectedSquad.append(userData)

                composeController?.globTableViewOutlet.reloadData()
                composeController?.globCollectionViewOutlet.reloadData()
                
            }

        } else {
            
            if let count = composeController?.selectedSquad.count {
                
                composeController?.userSelected[uid] = count
                
            }
            
            //Add
            composeController?.selectedSquad.append(userData)
            
            composeController?.globTableViewOutlet.reloadData()
            composeController?.globCollectionViewOutlet.reloadData()
        }

        
        if composeController?.selectedSquad.count > 0 {
            
            composeController?.getTalkinOutlet.enabled = true
            
        } else {
            
            composeController?.getTalkinOutlet.enabled = false
            
        }
    }
    

    func loadData(data: [NSObject : AnyObject]) {
        
        self.userData = data
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .AlignCenters

        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {
            
            self.nameOutlet.text = firstName + " " + lastName
            
        }

        if (composeController?.userSelected[uid]) != nil {
            
            self.selectedIndicator.image = UIImage(named: "Checkmark")
  
        } else {
            
            self.selectedIndicator.image = nil
            
        }

        
        if let uid = data["uid"] as? String {
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            self.uid = uid
            
            ref.child("profilePicture").observeEventType(.Value, withBlock: { (snapshot) in
                
                if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                    
                    if self.uid == uid {
                        
                        self.profilePicOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                        
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
