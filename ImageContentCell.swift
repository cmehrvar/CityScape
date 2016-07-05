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
    var data = [NSObject : AnyObject]()
    var homeController: HomeController!
    var globHasLiked = false
    var mostRecentTimeStamp: NSTimeInterval!
    
    //Outlets
    @IBOutlet weak var cityRankOutlet: UILabel!
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
    @IBOutlet weak var timeAgoOutlet: UILabel!
    
    //Actions
    @IBAction func dislike(sender: AnyObject) {
        
        likeDislike("dislike")
        
        
        
    }
    
    
    
    
    
    @IBAction func like(sender: AnyObject) {
        
        likeDislike("like")
        
    }
    
    
    @IBAction func viewCommentsAction(sender: AnyObject) {
        
        let vc = homeController.storyboard?.instantiateViewControllerWithIdentifier("rootChatController") as! ChatRootController

        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        homeController.view.window?.layer.addAnimation((transition), forKey: nil)
        
        guard let selfUID = FIRAuth.auth()?.currentUser?.uid else {return}
        
        vc.chatController?.senderId = selfUID
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(selfUID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let userData = snapshot.value as? [NSObject : AnyObject] {
                
                var name = ""
                
                if let firstName = userData["firstName"] as? String {
                    
                    name = firstName + " "
                    
                }
                
                if let lastName = userData["lastName"] as? String {
                    
                    name += lastName
                    
                }
                
                vc.chatController?.senderDisplayName = name

            }
        })
        
        let time = self.mostRecentTimeStamp
        
        homeController.presentViewController(vc, animated: false) {
            
            vc.topChatController?.mostRecentTimeInterval = time

            
        }
        
        print("view comments tapped")
        
    }
    
    
    @IBAction func viewAllCommentsAction(sender: AnyObject) {
        
        print("view all comments tapped")
        
        let vc = homeController.storyboard?.instantiateViewControllerWithIdentifier("commentController") as! CommentController
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        homeController.view.window?.layer.addAnimation((transition), forKey: nil)
        
        homeController.presentViewController(vc, animated: false, completion: nil)

        
    }
    
    
    
    func loadData() {
        
        if globHasLiked {
            
            thumbsUpImageOutlet.image = nil
            thumbsDownImageOutlet.image = nil
            viewHowManyCommentsOutlet.enabled = false
            
        } else {
            
            thumbsUpImageOutlet.image = UIImage(named: "thumbsUp")
            thumbsDownImageOutlet.image = UIImage(named: "thumbsDown")
            viewHowManyCommentsOutlet.enabled = false
            
        }
        
        if let actualLike = data["like"] as? Int, actualDislike = data["dislike"] as? Int, actualFirstName = data["firstName"] as? String, actualLastName = data["lastName"] as? String, actualCaption = data["caption"] as? String ,actualContent = data["contentURL"] as? String, actualProfile = data["profilePicture"] as? String, actualCity = data["city"] as? String, actualTimeStamp = data["timeStamp"] as? NSTimeInterval, userUID = data["userUID"] as? String {
            
            let postData = NSDate(timeIntervalSince1970: actualTimeStamp)
            
            timeAgoOutlet.text = timeAgoSince(postData)
            
            if actualCaption == "\"\"" {
                captionOutlet.text = nil
            } else {
                captionOutlet.text = actualCaption
            }
            
            nameOutlet.text = actualFirstName + " " + actualLastName
            dislikeDisplayOutlet.text = "Dislikes: " + String(actualDislike)
            likeDisplayOutlet.text = "Likes: " + String(actualLike)
            cityOutlet.text = actualCity
            
            if let actualURL = NSURL(string: actualContent), actualProfileURL = NSURL(string: actualProfile) {
                
                imageOutlet.sd_setImageWithURL(actualURL, placeholderImage: nil)
                profilePictureOutlet.sd_setImageWithURL(actualProfileURL, placeholderImage: nil)
                
            }
            
            let ref = FIRDatabase.database().reference()
            
            ref.child("users").child(userUID).child("cityRank").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let rank = snapshot.value as? Int {
                    
                    self.cityRankOutlet.text = "City Rank: " + String(rank)
                    
                }
            })
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
                        
                        if let userUID = FIRAuth.auth()?.currentUser?.uid {
                            
                            ref.child("posts").child(postUID).updateChildValues([key : (actualNumber + 1)])
                            ref.child("users").child(userUID).child("posts").child(postUID).updateChildValues([key : (actualNumber + 1)])
                            ref.child("posts").child(postUID).child("hasLiked").child(userUID).setValue(true)
                            
                            ref.child("users").child(userUID).child("totalScore").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                
                                if let actualScore = snapshot.value as? Int {
                                    
                                    if key == "like" {
                                        
                                        ref.child("users").child(userUID).updateChildValues(["totalScore" : actualScore + 2])
                                        ref.child("userScores").child(userUID).setValue(actualScore + 2)
                                        
                                    } else if key == "dislike" {
                                        
                                        if actualScore > 0 {
                                            
                                            ref.child("users").child(userUID).updateChildValues(["totalScore" : actualScore - 1])
                                            ref.child("userScores").child(userUID).setValue(actualScore - 1)
                                            
                                        }
                                    }
                                }
                            })
                        }
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
