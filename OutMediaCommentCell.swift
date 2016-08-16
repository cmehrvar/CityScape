//
//  OutMediaCommentCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-31.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import AVFoundation
import Player
import SDWebImage

class OutMediaCommentCell: UITableViewCell, PlayerDelegate {
    
    weak var vibesController: VibesFeedController?
    
    var postIndex = Int()
    var messageIndex = Int()
    
    @IBOutlet weak var imageComment: UIImageView!
    @IBOutlet weak var commentProfile: homeCommentProfile!
    @IBOutlet weak var bubbleView: TextBubble!
    
    
    //Player Delegates
    //Player Delegates
    func playerReady(player: Player){
        
    }
    func playerPlaybackStateDidChange(player: Player){
        
    }
    func playerBufferingStateDidChange(player: Player){
        
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player){
        
    }
    func playerPlaybackDidEnd(player: Player){
        
    }

    
    
    
    
    
    
    func setMediaComment(data: [String : AnyObject?]){
 
        if let isImage = data["isImage"] as? Bool {
            
            if isImage {
                
                if let offlineImage = data["offlineImage"] as? UIImage {
                    
                    setPostedImage(offlineImage)
                    
                } else if let imageURLString = data["media"] as? String, imageURL = NSURL(string: imageURLString) {
                    
                    SDWebImageManager.sharedManager().downloadImageWithURL(imageURL, options: .ContinueInBackground, progress: nil, completed: { (image, error, cache, bool, url) in
                        
                        if error == nil {
                           self.setPostedImage(image)
                        }
                    })
                }

            }  else {
                
                if let offlineVideo = data["offlinePlayer"] as? Player {
                    
                    print("offlineData")
                    
                } else if vibesController?.mainCommentVideos["post:\(postIndex)_message:\(messageIndex)"] == nil {
                    
                    if let mediaURLString = data["media"] as? String, mediaURL = NSURL(string: mediaURLString) {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            self.vibesController?.mainCommentVideos["post:\(self.postIndex)_message:\(self.messageIndex)"] = Player()
                            self.vibesController?.mainCommentVideos["post:\(self.postIndex)_message:\(self.messageIndex)"]?.delegate = self.vibesController
                            
                            if let player = self.vibesController?.mainCommentVideos["post:\(self.postIndex)_message:\(self.messageIndex)"] {
                                
                                if let videoPlayerView = player.view {

                                    self.vibesController?.addChildViewController(player)
                                    player.view.frame = self.bubbleView.bounds
                                    player.didMoveToParentViewController(self.vibesController)
                                    player.setUrl(mediaURL)
                                    
                                    player.fillMode = AVLayerVideoGravityResizeAspectFill
                                    player.playbackLoops = true
                                    player.muted = true
                                    player.playFromBeginning()
                                    self.bubbleView.addSubview(videoPlayerView)
                                    
                                }
                            }
                        }
                    }
                    
                    print("postIndex: \(postIndex)")
                    print("messageIndex: \(messageIndex)")
                    
                } else {
                    
                    print("player already set")
                    
                    if let player = vibesController?.mainCommentVideos["post:\(postIndex)_message:\(messageIndex)"] {
                        
                        if let videoPlayerView = player.view {
                            
                            self.vibesController?.addChildViewController(player)
                            self.bubbleView.addSubview(videoPlayerView)
                            player.muted = true
                            player.playFromBeginning()
                            
                        }
                    }
                }
            }
        }
        
        if let profileURLString = data["profilePic"] as? String, profileURL = NSURL(string: profileURLString) {
            
            commentProfile.sd_setImageWithURL(profileURL, placeholderImage: nil)
            
        }
    }
    
    //UIImageView Resize
    internal var aspectConstraint: NSLayoutConstraint? {
        
        didSet {
            
            if let actualValue = oldValue {
                imageComment.removeConstraint(actualValue)
            }
            
            if let actualValue = aspectConstraint {
                imageComment.addConstraint(actualValue)
            }
        }
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        aspectConstraint = nil
        
    }
    
    func setPostedImage(image: UIImage){
        
        
        let aspect = image.size.width / image.size.height
        aspectConstraint = NSLayoutConstraint(item: imageComment, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: imageComment, attribute: NSLayoutAttribute.Height, multiplier: aspect, constant: 0.0)
        imageComment.image = image
        
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
