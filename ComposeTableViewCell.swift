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


class ComposeTableViewCell: UITableViewCell {

    var userData = [AnyHashable: Any]()
    
    weak var composeController: ComposeChatController?
    
    var uid = ""

    @IBOutlet weak var profilePicOutlet: TableViewProfilePicView!
    @IBOutlet weak var onlineIndicatorOutlet: UIView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var rankOutlet: UILabel!
    @IBOutlet weak var selectedIndicator: UIImageView!

    @IBAction func addRemoveFromChat(_ sender: AnyObject) {

        if let selectedUsers = composeController?.userSelected {
            
            if selectedUsers[uid] != nil {
                
                //Remove
                if let last = composeController?.selectedSquad.last, let index = composeController?.userSelected[uid] {

                    self.composeController?.selectedSquad[index] = last
                    
                    if let uid = last["uid"] as? String {
                        
                        self.composeController?.userSelected[uid] = index
                        
                    }

                    self.composeController?.selectedSquad.removeLast()
                    composeController?.userSelected.removeValue(forKey: uid)
                    
                    self.composeController?.globCollectionViewOutlet.reloadData()
                    self.composeController?.globTableViewOutlet.reloadData()

                }

            } else {
                
                
                if let count = composeController?.selectedSquad.count {
                    
                    composeController?.userSelected[uid] = count
                    

                //Add
                composeController?.selectedSquad.append(userData as [NSObject : AnyObject])

                composeController?.globTableViewOutlet.reloadData()
                composeController?.globCollectionViewOutlet.reloadData()
                
                let indexPath = IndexPath(row: count, section: 0)
                
                composeController?.globCollectionViewOutlet.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
                
                }
            }

        } else {
            
            if let count = composeController?.selectedSquad.count {
                
                composeController?.userSelected[uid] = count
                
            }
            
            //Add
            composeController?.selectedSquad.append(userData as [NSObject : AnyObject])
            
            composeController?.globTableViewOutlet.reloadData()
            composeController?.globCollectionViewOutlet.reloadData()
        }

        
        if composeController?.selectedSquad.count > 0 {
            
            composeController?.getTalkinOutlet.isEnabled = true
            
        } else {
            
            composeController?.getTalkinOutlet.isEnabled = false
            
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

            if (composeController?.userSelected[uid]) != nil {
                
                self.selectedIndicator.backgroundColor = UIColor.red
                
            } else {
                
                self.selectedIndicator.backgroundColor = UIColor.clear
                
            }

            ref.child("profilePicture").observe(.value, with: { (snapshot) in
                
                if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                    
                    if self.uid == uid {
                        
                        self.profilePicOutlet.sd_setImage(with: url, placeholderImage: nil)
                        
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
