//
//  AddToChatCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-28.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class AddToChatCell: UITableViewCell {
    
    var userData = [NSObject : AnyObject]()
    var uid = ""
    
    weak var addToChatController: AddToChatController?

    @IBOutlet weak var profilePictureOutlet: TableViewProfilePicView!
    @IBOutlet weak var onlineIndicatorOutlet: TableViewOnlineIndicatorView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var rankOutlet: UILabel!
    @IBOutlet weak var selectedIndicatorImageOutlet: UIImageView!

    @IBAction func selectUser(sender: AnyObject) {
        
        if let selectedUsers = addToChatController?.userSelected {
            
            if selectedUsers[uid] != nil {
                
                //Remove
                if let last = addToChatController?.selectedSquad.last, index = addToChatController?.userSelected[uid] {
                    
                    self.addToChatController?.selectedSquad[index] = last
                    
                    if let uid = last["uid"] as? String {
                        
                        self.addToChatController?.userSelected[uid] = index
                        
                    }
                    
                    self.addToChatController?.selectedSquad.removeLast()
                    addToChatController?.userSelected.removeValueForKey(uid)
                    
                    self.addToChatController?.globCollectionViewOutlet.reloadData()
                    self.addToChatController?.globTableViewOutlet.reloadData()
                    
                }
                
            } else {
                
                
                if let count = addToChatController?.selectedSquad.count {
                    
                    addToChatController?.userSelected[uid] = count
                    
                    
                    //Add
                    addToChatController?.selectedSquad.append(userData)
                    
                    addToChatController?.globTableViewOutlet.reloadData()
                    addToChatController?.globCollectionViewOutlet.reloadData()
                    
                    let indexPath = NSIndexPath(forRow: count, inSection: 0)
                    
                    addToChatController?.globCollectionViewOutlet.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: true)
                    
                }
            }
            
        } else {
            
            if let count = addToChatController?.selectedSquad.count {
                
                addToChatController?.userSelected[uid] = count
                
            }
            
            //Add
            addToChatController?.selectedSquad.append(userData)
            
            addToChatController?.globTableViewOutlet.reloadData()
            addToChatController?.globCollectionViewOutlet.reloadData()
        }
        
        
        if addToChatController?.selectedSquad.count > 0 {
            
            //Enable Button
            addToChatController?.addButtonOutlet.enabled = true
            
            
        } else {
            
            //Disable Button
            addToChatController?.addButtonOutlet.enabled = false
            
        }
    }

    func loadCell(data: [NSObject : AnyObject]) {
        
        self.userData = data
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .AlignCenters
        
        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {
            
            self.nameOutlet.text = firstName + " " + lastName
            
        }
        
        
        if let uid = data["uid"] as? String {
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            self.uid = uid

            if (addToChatController?.userSelected[uid]) != nil {
                
                self.selectedIndicatorImageOutlet.image = UIImage(named: "Checkmark")
                
            } else {
                
                self.selectedIndicatorImageOutlet.image = nil
                
            }

            ref.child("profilePicture").observeEventType(.Value, withBlock: { (snapshot) in
                
                if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                    
                    if self.uid == uid {
                        
                        self.profilePictureOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                        
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
