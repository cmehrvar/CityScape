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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class AddToChatCell: UITableViewCell {
    
    var userData = [AnyHashable: Any]()
    var uid = ""
    
    weak var addToChatController: AddToChatController?

    @IBOutlet weak var profilePictureOutlet: TableViewProfilePicView!
    @IBOutlet weak var onlineIndicatorOutlet: TableViewOnlineIndicatorView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var rankOutlet: UILabel!
    @IBOutlet weak var selectedIndicatorImageOutlet: UIImageView!

    @IBAction func selectUser(_ sender: AnyObject) {
        
        if let selectedUsers = addToChatController?.userSelected {
            
            if selectedUsers[uid] != nil {
                
                //Remove
                if let last = addToChatController?.selectedSquad.last, let index = addToChatController?.userSelected[uid] {
                    
                    self.addToChatController?.selectedSquad[index] = last
                    
                    if let uid = last["uid"] as? String {
                        
                        self.addToChatController?.userSelected[uid] = index
                        
                    }
                    
                    self.addToChatController?.selectedSquad.removeLast()
                    addToChatController?.userSelected.removeValue(forKey: uid)
                    
                    self.addToChatController?.globCollectionViewOutlet.reloadData()
                    self.addToChatController?.globTableViewOutlet.reloadData()
                    
                }
                
            } else {
                
                
                if let count = addToChatController?.selectedSquad.count {
                    
                    addToChatController?.userSelected[uid] = count
                    
                    
                    //Add
                    addToChatController?.selectedSquad.append(userData as [NSObject : AnyObject])
                    
                    addToChatController?.globTableViewOutlet.reloadData()
                    addToChatController?.globCollectionViewOutlet.reloadData()
                    
                    let indexPath = IndexPath(row: count, section: 0)
                    
                    addToChatController?.globCollectionViewOutlet.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
                    
                }
            }
            
        } else {
            
            if let count = addToChatController?.selectedSquad.count {
                
                addToChatController?.userSelected[uid] = count
                
            }
            
            //Add
            addToChatController?.selectedSquad.append(userData as [NSObject : AnyObject])
            
            addToChatController?.globTableViewOutlet.reloadData()
            addToChatController?.globCollectionViewOutlet.reloadData()
        }
        
        
        if addToChatController?.selectedSquad.count > 0 {
            
            //Enable Button
            addToChatController?.addButtonOutlet.isEnabled = true
            
            
        } else {
            
            //Disable Button
            addToChatController?.addButtonOutlet.isEnabled = false
            
        }
    }

    func loadCell(_ data: [AnyHashable: Any]) {
        
        self.userData = data
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .alignCenters
        
        if let firstName = data["firstName"] as? String, let lastName = data["lastName"] as? String {
            
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

            ref.child("profilePicture").observe(.value, with: { (snapshot) in
                
                if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                    
                    if self.uid == uid {
                        
                        self.profilePictureOutlet.sd_setImage(with: url, placeholderImage: nil)
                        
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
