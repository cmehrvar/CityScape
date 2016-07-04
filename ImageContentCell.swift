//
//  ImageContentCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-02.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ImageContentCell: UITableViewCell {
    
    //Variables
    var data: [NSObject : AnyObject]!
    var homeController: HomeController!
    var hasLiked = false
    
    //Outlets
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var likeDisplayOutlet: UILabel!
    @IBOutlet weak var dislikeDisplayOutlet: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityOutlet: UILabel!
    @IBOutlet weak var captionOutlet: UILabel!
    @IBOutlet weak var commentName1Outlet: UILabel!
    @IBOutlet weak var comment1Outlet: UILabel!
    @IBOutlet weak var commentName2Outlet: UILabel!
    @IBOutlet weak var comment2Outlet: UILabel!
    @IBOutlet weak var viewHowManyCommentsOutlet: UIButton!
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var dislikeButtonOutlet: UIButton!
    @IBOutlet weak var thumbsDownImageOutlet: UIImageView!
    @IBOutlet weak var thumbsUpImageOutlet: UIImageView!

    
    //Actions
    @IBAction func dislike(sender: AnyObject) {
        
        likeDislike("dislike")
        
        
        
            }
    
    
    
    
    
    @IBAction func like(sender: AnyObject) {
        
        likeDislike("like")

            }

    
    @IBAction func viewCommentsAction(sender: AnyObject) {
        
        print("view comments tapped")
        
    }
    
    
    @IBAction func viewAllCommentsAction(sender: AnyObject) {
        
        print("view all comments tapped")
        
    }
    
    
    func loadData() {
        
        if hasLiked {
            
            thumbsUpImageOutlet.image = nil
            thumbsDownImageOutlet.image = nil
            viewHowManyCommentsOutlet.enabled = false

        } else {
            
            thumbsUpImageOutlet.image = UIImage(named: "thumbsUp")
            thumbsDownImageOutlet.image = UIImage(named: "thumbsDown")
            viewHowManyCommentsOutlet.enabled = false
            
        }
        
        if let actualLike = data["like"] as? Int, actualDislike = data["dislike"] as? Int, actualFirstName = data["firstName"] as? String, actualLastName = data["lastName"] as? String, actualCaption = data["caption"] as? String ,actualContent = data["contentURL"] as? String, actualProfile = data["profilePicture"] as? String, actualCity = data["city"] as? String {
            
            captionOutlet.text = actualCaption
            nameOutlet.text = actualFirstName + " " + actualLastName
            dislikeDisplayOutlet.text = "Dislikes: " + String(actualDislike)
            likeDisplayOutlet.text = "Likes: " + String(actualLike)
            cityOutlet.text = actualCity
            
            if let actualURL = NSURL(string: actualContent), actualProfileURL = NSURL(string: actualProfile) {
                
                imageOutlet.sd_setImageWithURL(actualURL, placeholderImage: nil)
                profilePictureOutlet.sd_setImageWithURL(actualProfileURL, placeholderImage: nil)
                
            }
        }
    }
    
    func likeDislike(key: String) {
        
        if key == "like" {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.homeController.likeViewOutlet.alpha = 1
                    
                }) { (complete) in
                    
                    UIView.animateWithDuration(0.3, animations: {
                        
                        self.homeController.likeViewOutlet.alpha = 0
                        
                        })
                }
            }
            
        } else {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.homeController.dislikeViewOutlet.alpha = 1
                    
                }) { (complete) in
                    
                    UIView.animateWithDuration(0.3, animations: {
                        
                        self.homeController.dislikeViewOutlet.alpha = 0
                        
                        })
                    
                }
            }
        }
        

        let ref = FIRDatabase.database().reference()
        
        if let postUID = data["postChildKey"] as? String {
            
            ref.child("posts").child(postUID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let value = snapshot.value {
                    
                    if let actualNumber = value[key] as? Int {
                        
                        if let actualUserPostUID = self.data["userPostChildKey"] as? String {
                            
                            if let userUID = FIRAuth.auth()?.currentUser?.uid {
                                
                                ref.child("posts").child(postUID).updateChildValues([key : (actualNumber + 1)])
                                ref.child("users").child(userUID).child("posts").child(actualUserPostUID).updateChildValues([key : (actualNumber + 1)])
                                ref.child("posts").child(postUID).child("hasLiked").child(userUID).setValue(true)
 
                                
                            }
                        }
                    }
                }
            })
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if data != nil {
            print(data)
        } else {
            print("no data on start")
        }
        
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
