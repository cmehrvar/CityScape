//
//  MediaCommentCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-18.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Player
import SDWebImage
import AVFoundation

class InMediaCommentCell: UITableViewCell {
    
    weak var homeController: HomeController?
    
    var postIndex = Int()
    var messageIndex = Int()
    
    
    @IBOutlet weak var imageComment: UIImageView!
    @IBOutlet weak var commentProfile: homeCommentProfile!
    @IBOutlet weak var commentName: UILabel!
    @IBOutlet weak var bubbleView: TextBubble!
    

    func setMediaComment(isImage: Bool, data: [String : AnyObject?]){
        
        if isImage {
            
            if let imageURLString = data["media"] as? String, imageURL = NSURL(string: imageURLString) {
                
                imageComment.sd_setImageWithURL(imageURL, placeholderImage: nil)

            }
            
            if let name = data["inName"] as? String {
                
                commentName.text = name
                
            }
            
            if let profileURLString = data["inProfilePic"] as? String, profileURL = NSURL(string: profileURLString) {
                
                commentProfile.sd_setImageWithURL(profileURL, placeholderImage: nil)
                
            }
        }  else {
            
            if homeController?.mainCommentVideos["post:\(postIndex)_message:\(messageIndex)"] == nil {

                if let mediaURLString = data["media"] as? String, mediaURL = NSURL(string: mediaURLString) {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.homeController?.mainCommentVideos["post:\(self.postIndex)_message:\(self.messageIndex)"] = Player()
                        self.homeController?.mainCommentVideos["post:\(self.postIndex)_message:\(self.messageIndex)"]?.delegate = self.homeController
                        
                        if let player = self.homeController?.mainCommentVideos["post:\(self.postIndex)_message:\(self.messageIndex)"] {
                            
                            if let videoPlayerView = player.view {
                                
                                self.homeController?.addChildViewController(player)
                                player.view.frame = self.bubbleView.bounds
                                player.didMoveToParentViewController(self.homeController)
                                
                                player.setUrl(mediaURL)
                                
                                player.fillMode = AVLayerVideoGravityResizeAspectFill
                                player.playbackLoops = true
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
                
                if let player = homeController?.mainCommentVideos["post:\(postIndex)_message:\(messageIndex)"] {
                    
                    if let videoPlayerView = player.view {
                        
                        self.homeController?.addChildViewController(player)
                        self.bubbleView.addSubview(videoPlayerView)
                        player.playFromBeginning()
                        
                    }
                }
                
            }
            
            

            if let name = data["inName"] as? String {
                
                commentName.text = name
                
            }
            
            if let profileURLString = data["inProfilePic"] as? String, profileURL = NSURL(string: profileURLString) {
                
                commentProfile.sd_setImageWithURL(profileURL, placeholderImage: nil)
                
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
