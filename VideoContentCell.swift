//
//  VideoContentCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-02.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation
import Player
import Firebase
import FirebaseDatabase
import FirebaseAuth

class VideoContentCell: UITableViewCell, PlayerDelegate {
    
    
    //Variables
    var data: [NSObject : AnyObject]!
    var vc: HomeController!
    var hasLiked = false
    

    //Outlets
    @IBOutlet weak var mediaViewOutlet: UIView!
    @IBOutlet weak var likeDisplayOutlet: UILabel!
    @IBOutlet weak var dislikeDisplayOutlet: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityOutlet: UILabel!
    @IBOutlet weak var captionOutlet: UILabel!
    @IBOutlet weak var cityRankOutlet: UILabel!
    @IBOutlet weak var commentName1Outlet: UILabel!
    @IBOutlet weak var comment1Outlet: UILabel!
    @IBOutlet weak var commentName2Outlet: UILabel!
    @IBOutlet weak var comment2Outlet: UILabel!
    @IBOutlet weak var viewHowManyCommentsOutlet: UIButton!
    @IBOutlet weak var thumbsUpImageOutlet: UIImageView!
    @IBOutlet weak var thumbsDownImageOutlet: UIImageView!
    @IBOutlet weak var timeAgo: UILabel!

    
    
    //Player Delegates
    func playerReady(player: Player) {
        
        //print("player ready")
        
    }
    func playerPlaybackStateDidChange(player: Player) {
        
        //print("playback state did change")
        
    }
    func playerBufferingStateDidChange(player: Player) {
        
        //print("buffer state did change")
        
    }
    func playerPlaybackWillStartFromBeginning(player: Player) {
        
        //print("playback will start from beginning")
        
    }
    func playerPlaybackDidEnd(player: Player) {
        
        //print("playback did end")
        
    }

    
    
    
    //Actions
    @IBAction func like(sender: AnyObject) {
        
        likeDislike("like")
    }
    
    
    
    @IBAction func dislike(sender: AnyObject) {
        
        likeDislike("dislike")
    }
    
    
    
    @IBAction func secondViewAllComments(sender: AnyObject) {
        
        
        
    }

    
    @IBAction func viewAllComments(sender: AnyObject) {
        
        
        
    }
    
    
    //Functions
    func likeDislike(key: String) {
        
        if key == "like" {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.vc.likeViewOutlet.alpha = 1
                    
                }) { (complete) in
                    
                    UIView.animateWithDuration(0.3, animations: {
                        
                        self.vc.likeViewOutlet.alpha = 0
                        
                    })
                }
            }
            
        } else {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.vc.dislikeViewOutlet.alpha = 1
                    
                }) { (complete) in
                    
                    UIView.animateWithDuration(0.3, animations: {
                        
                        self.vc.dislikeViewOutlet.alpha = 0
                        
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
                }
            })
        }
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

        
        if let actualLike = data["like"] as? Int, actualDislike = data["dislike"] as? Int, actualFirstName = data["firstName"] as? String, actualLastName = data["lastName"] as? String, actualCaption = data["caption"] as? String ,actualContent = data["contentURL"] as? String, actualProfile = data["profilePicture"] as? String, actualCity = data["city"] as? String, actualTimeStamp = data["timeStamp"] as? NSTimeInterval, userUID = data["userUID"] as? String {
            
            
            timeAgo.text = timeAgoSince(NSDate(timeIntervalSince1970: actualTimeStamp))
            
            if actualCaption == "\"\"" {
                captionOutlet.text = nil
            } else {
                captionOutlet.text = actualCaption
            }
            
            nameOutlet.text = actualFirstName + " " + actualLastName
            dislikeDisplayOutlet.text = "Likes: " + String(actualDislike)
            likeDisplayOutlet.text = "Likes: " + String(actualLike)
            cityOutlet.text = actualCity
            
            if let actualURL = NSURL(string: actualContent), actualProfileURL = NSURL(string: actualProfile) {
 
                let player = Player()
                player.delegate = self
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.vc.addChildViewController(player)
                    self.mediaViewOutlet.addSubview(player.view)
                    player.view.frame = self.mediaViewOutlet.bounds
                    player.didMoveToParentViewController(self.vc)
                    player.setUrl(actualURL)
                    player.fillMode = AVLayerVideoGravityResizeAspectFill
                    player.playbackLoops = true
                    player.playFromBeginning()
                    
                    
                })

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

    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //print(data)
        
        self.mediaViewOutlet.layoutSubviews()
        
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
