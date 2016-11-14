//
//  PostUpdateCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-16.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class PostUpdateCell: UITableViewCell {
    
    weak var notificationController: NotificationController?
    var postKey = ""
    var uid = ""

    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var likeIconOutlet: UIImageView!
    @IBOutlet weak var postOutlet: UIImageView!
    @IBOutlet weak var unreadViewOutlet: UIView!
    @IBOutlet weak var likeButtonWidthConst: NSLayoutConstraint!
    @IBOutlet weak var textOutlet: UILabel!
    
    

    @IBAction func goToPost(_ sender: AnyObject) {

        if let selfData = notificationController?.rootController?.selfData, let myPosts = selfData["posts"] as? [AnyHashable: Any] {
            
            if let post = myPosts[postKey] as? [AnyHashable: Any] {

                let postArray = [post]
                
                self.notificationController?.rootController?.snapchatController?.singlePost = true
                
                notificationController?.rootController?.toggleSnapchat(postArray, startingi: 0, completion: { (bool) in
                    
                    print("snapchat toggled", terminator: "")
                    
                })
            }
        }
    }
    
    
    
    func loadCell(_ data: [AnyHashable: Any]) {
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .alignCenters
        
        if let uid = data["senderUid"] as? String {
            
            self.uid = uid
            
            let userRef = FIRDatabase.database().reference().child("users").child(uid)
            
            userRef.child("firstName").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let firstName = snapshot.value as? String {
                    
                    self.nameOutlet.text = firstName
                    
                }
            })
            
            userRef.child("profilePicture").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                    
                    if self.uid == uid {
                        
                        self.profileOutlet.sd_setImage(with: url, placeholderImage: nil)
                        
                    }
                }
            })
            
            
            if let buttonType = data["button"] as? String {
                
                likeButtonWidthConst.constant = 20
                
                likeIconOutlet.image = UIImage(named: "grey" + buttonType)
                
            } else {
                
                if let text = data["text"] as? String {
                    
                    textOutlet.text = text
                    
                }
                
                likeButtonWidthConst.constant = 0
                
            }
            
            if let imageString = data["image"] as? String, let url = URL(string: imageString) {
                
                postOutlet.sd_setImage(with: url, placeholderImage: nil)
                
            }
            
            if let scopeKey = data["postChildKey"] as? String {
                
                self.postKey = scopeKey
                
            }
            
            if let read = data["read"] as? Bool {
                
                if !read {
                    
                    self.unreadViewOutlet.alpha = 1
                    
                } else {
                    
                    self.unreadViewOutlet.alpha = 0
                    
                }
            }
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
