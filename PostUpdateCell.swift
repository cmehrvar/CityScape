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
    

    @IBAction func goToPost(sender: AnyObject) {

        if let selfData = notificationController?.rootController?.selfData, myPosts = selfData["posts"] as? [NSObject : AnyObject] {
            
            if let post = myPosts[postKey] as? [NSObject : AnyObject] {
                
                let postArray = [post]
                notificationController?.rootController?.toggleSnapchat(postArray, startingi: 0, completion: { (bool) in
                    
                    print("snapchat toggled")
                    
                })
            }
        }
    }
    
    
    
    func loadCell(data: [NSObject : AnyObject]) {
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .AlignCenters
        
        if let uid = data["senderUid"] as? String {
            
            self.uid = uid
            
            let userRef = FIRDatabase.database().reference().child("users").child(uid)
            
            userRef.child("firstName").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let firstName = snapshot.value as? String {
                    
                    userRef.child("lastName").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        
                        if let lastName = snapshot.value as? String {
                            
                            let name = firstName + " " + lastName
                            
                            if self.uid == uid {
                                
                                self.nameOutlet.text = name
                                
                            }
                        }
                    })
                }
            })
            
            userRef.child("profilePicture").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                    
                    if self.uid == uid {
                        
                        self.profileOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                        
                    }
                }
            })
            
            
            if let buttonType = data["button"] as? String {
                
                likeIconOutlet.image = UIImage(named: buttonType)
                
            }
            
            if let imageString = data["image"] as? String, url = NSURL(string: imageString) {
                
                postOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                
            }
            
            if let scopeKey = data["postChildKey"] as? String {
                
                self.postKey = scopeKey
                
            }
            
            if let read = data["read"] as? Bool {
                
                if !read {
                    
                    self.backgroundColor = UIColor.yellowColor()
                    
                } else {
                    
                    self.backgroundColor = UIColor.whiteColor()
                    
                }
            }
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
