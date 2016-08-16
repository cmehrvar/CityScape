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
import Player

class TopContentCell: UITableViewCell {
    
    //Variables
    //var postUID = ""
    //var postIndex = 0
    //var homeController: HomeController!
    //var hasLiked: Bool?
    
    weak var rootController: MainRootController?
    //var globPostUIDs = [String]()
    //var globPostData = [[NSObject : AnyObject]?]()
    //var messageData: [NSObject : AnyObject]?
    //var loadedMessages = [[String : AnyObject]]()
    //var hasLikedArray = [Bool?]()
    
    
    //Outlets
    @IBOutlet weak var cityRankOutlet: UILabel!
    //@IBOutlet weak var imageOutlet: UIImageView!
    //@IBOutlet weak var likeDisplayOutlet: UILabel!
    //@IBOutlet weak var dislikeDisplayOutlet: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityOutlet: UILabel!
    //@IBOutlet weak var captionOutlet: UILabel!
    //@IBOutlet weak var likeButtonOutlet: UIButton!
    //@IBOutlet weak var dislikeButtonOutlet: UIButton!
    //@IBOutlet weak var thumbsDownImageOutlet: UIImageView!
    //@IBOutlet weak var thumbsUpImageOutlet: UIImageView!
    //@IBOutlet weak var timeAgoOutlet: UILabel!
    //@IBOutlet weak var startConvoOutlet: UIButton!
    
    //Actions
    /*
    @IBAction func dislike(sender: AnyObject) {
        
        likeDislike("dislike")
        
        
        
    }
    */
    
    /*

    @IBAction func like(sender: AnyObject) {
        
        likeDislike("like")
        
    }*/
    
    /*
    
    @IBAction func viewCommentsAction(sender: AnyObject) {
        
        let mainRootController = rootController
        
        let ref = FIRDatabase.database().reference()
        
        let scopeLoadedMessage = loadedMessages
        
        let id = self.globPostUIDs
        let post = self.globPostData
        let liked = self.hasLikedArray
        let postUID = self.postUID
        let scopePostIndex = self.postIndex
        
        guard let selfUID = FIRAuth.auth()?.currentUser?.uid else {return}
        
        let refToPass = "posts/\(self.postUID)"
        
        let contentOffset = self.rootController?.homeController?.tableView.contentOffset
        
        let vc = rootController?.storyboard?.instantiateViewControllerWithIdentifier("rootChatController") as! ChatRootController
        
        self.rootController?.presentViewController(vc, animated: true) {

            for i in 0..<scopeLoadedMessage.count {
                
                var offlineImage: UIImage?
                
                if let actualImage = scopeLoadedMessage[i]["offlineImage"] as? UIImage {
                    offlineImage = actualImage
                }
                
                if let player = scopeLoadedMessage[i]["player"] as? Player, key = scopeLoadedMessage[i]["key"] as? String {
                    vc.chatController?.videoPlayers[key] = player
                }

                vc.chatController?.addMessage(scopeLoadedMessage[i]["senderId"] as! String, text: scopeLoadedMessage[i]["text"] as! String, name: scopeLoadedMessage[i]["senderDisplayName"] as! String, profileURL: scopeLoadedMessage[i]["profilePicture"] as! String, isMedia: scopeLoadedMessage[i]["isMedia"] as! Bool, media: scopeLoadedMessage[i]["media"] as! String, isImage: scopeLoadedMessage[i]["isImage"] as! Bool, date: scopeLoadedMessage[i]["date"] as! NSDate, key: scopeLoadedMessage[i]["key"] as! String, i: i, offlineImage: offlineImage)
                
            }

            vc.topChatController?.globPostUIDs = id
            vc.topChatController?.postData = post
            vc.topChatController?.hasLiked = liked
            vc.topChatController?.mainRootController = mainRootController
            vc.topChatController?.postIndex = scopePostIndex
            
            
            if let offset = contentOffset {
                vc.topChatController?.tableViewOffset = offset
            }
            
            
            vc.chatController?.senderId = selfUID
            vc.chatController?.postUID = postUID
            vc.chatController?.passedRef = refToPass
            
            ref.child("users").child(selfUID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let userData = snapshot.value as? [NSObject : AnyObject] {
                    
                    var name = ""
                    
                    if let firstName = userData["firstName"] as? String {
                        
                        name = firstName + " "
                        vc.chatController?.firstName = firstName
                        
                    }
                    
                    if let lastName = userData["lastName"] as? String {
                        
                        name += lastName
                        vc.chatController?.lastName = lastName
                        
                    }
                    
                    if let profile = userData["profilePicture"] as? String {
                        vc.chatController?.profileUrl = profile
                    }
                    
                    vc.chatController?.senderDisplayName = name
                    vc.chatController?.observeMessages()
                    vc.chatController?.observeTyping()
                    
                }
                
            })
    
        }
        
        print("view comments tapped")
 
    }
*/
    func loadData(data: [NSObject : AnyObject]) {

        if let actualFirstName = data["firstName"] as? String, actualLastName = data["lastName"] as? String, actualProfile = data["profilePicture"] as? String, actualCity = data["city"] as? String, userUID = data["userUID"] as? String {
                
                if let actualProfileURL = NSURL(string: actualProfile) {
                    profilePictureOutlet.sd_setImageWithURL(actualProfileURL, placeholderImage: nil)
                }

                let ref = FIRDatabase.database().reference()
                
                ref.child("users").child(userUID).child("cityRank").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                    if let rank = snapshot.value as? Int {
                        
                        self.cityRankOutlet.text = "City Rank: " + String(rank)
                        
                    }
                })

            /*
             if let actualLiked = hasLiked {
             
             if actualLiked {
             
             thumbsUpImageOutlet.image = nil
             thumbsDownImageOutlet.image = nil
             
             } else {
             
             thumbsUpImageOutlet.image = UIImage(named: "thumbsUp")
             thumbsDownImageOutlet.image = UIImage(named: "thumbsDown")
             
             }
             */

                
                //let postDate = NSDate(timeIntervalSince1970: actualTimeStamp)
                
                //timeAgoOutlet.text = timeAgoSince(postData)
                
                /*
                if actualCaption == "\"\"" {
                    captionOutlet.text = nil
                } else {
                    captionOutlet.text = actualCaption
                }
                */
                
                
                nameOutlet.text = actualFirstName + " " + actualLastName
                //dislikeDisplayOutlet.text = "Dislikes: " + String(actualDislike)
                //likeDisplayOutlet.text = "Likes: " + String(actualLike)
                cityOutlet.text = actualCity
                
                /*
                if let actualURL = NSURL(string: actualContent), actualProfileURL = NSURL(string: actualProfile) {

                    SDWebImageManager.sharedManager().downloadImageWithURL(actualURL, options: .ContinueInBackground, progress: nil, completed: { (image, error, cache, bool, url) in
                        
                        if error == nil {
                            
                            let size = image.size
                            let scale = self.bounds.size.width / size.width
                            let scaledHeight = size.height * scale
                            let newSize = CGSize(width: self.bounds.size.width, height: scaledHeight)
                            
                            self.imageOutlet.image = image
                            self.imageOutlet.sizeThatFits(newSize)
                            
                            //self.setPostedImage(image)
                            
                        }
                    })
                    
                 
                    
                }
 
            }
 
 */
        }
    }

/*
    func likeDislike(key: String) {
        
        print("liked")
        
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
        ref.child("posts").child(postUID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let value = snapshot.value {
                
                if let actualNumber = value[key] as? Int {
                    
                    if let userUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        ref.child("posts").child(self.postUID).updateChildValues([key : (actualNumber + 1)])
                        ref.child("users").child(userUID).child("posts").child(self.postUID).updateChildValues([key : (actualNumber + 1)])
                        ref.child("posts").child(self.postUID).child("hasLiked").updateChildValues([userUID : true])
                        ref.child("users").child(userUID).child("totalScore").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            
                            if let actualScore = snapshot.value as? Int {
                                
                                if key == "like" {
                                    
                                    ref.child("users").child(userUID).updateChildValues(["totalScore" : actualScore + 2])
                                    ref.child("userScores").updateChildValues([userUID : actualScore + 2])
                                    
                                } else if key == "dislike" {
                                    
                                    if actualScore > 0 {
                                        
                                        ref.child("users").child(userUID).updateChildValues(["totalScore" : actualScore - 1])
                                        ref.child("userScores").child(userUID).updateChildValues([userUID : actualScore - 1])
                                        
                                        
                                    }
                                }
                            }
                        })
                    }
                }
            }
        })
        
    }
    */

    //UIImageViewResize
/*
    internal var aspectConstraint: NSLayoutConstraint? {
        
        didSet {
            
            if let actualValue = oldValue {
                imageOutlet.removeConstraint(actualValue)
            }
            
            if let actualValue = aspectConstraint {
                imageOutlet.addConstraint(actualValue)
            }
        }
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        aspectConstraint = nil
        
    }
    
    func setPostedImage(image: UIImage){
        
            let aspect = image.size.width / image.size.height
            self.aspectConstraint = NSLayoutConstraint(item: self.imageOutlet, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.imageOutlet, attribute: NSLayoutAttribute.Height, multiplier: aspect, constant: 0.0)
            self.imageOutlet.image = image
        
    }
    */
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
