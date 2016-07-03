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

class VideoContentCell: UITableViewCell, PlayerDelegate {
    
    
    //Variables
    var data: [NSObject : AnyObject]!
    var vc: HomeController!
    

    //Outlets
    @IBOutlet weak var mediaViewOutlet: UIView!
    @IBOutlet weak var likeDisplayOutlet: UILabel!
    @IBOutlet weak var dislikeDisplayOutlet: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityOutlet: UILabel!
    @IBOutlet weak var captionOutlet: UILabel!
    @IBOutlet weak var cityRankOutlet: UILabel!
    @IBOutlet weak var viewsOutlet: UILabel!
    @IBOutlet weak var commentName1Outlet: UILabel!
    @IBOutlet weak var comment1Outlet: UILabel!
    @IBOutlet weak var commentName2Outlet: UILabel!
    @IBOutlet weak var comment2Outlet: UILabel!
    @IBOutlet weak var viewHowManyCommentsOutlet: UIButton!
    @IBOutlet weak var mediaOutletHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userInfoHeightConstraint: NSLayoutConstraint!
    
    
    //Player Delegates
    func playerReady(player: Player) {
        
        print("player ready")
        
    }
    func playerPlaybackStateDidChange(player: Player) {
        
        print("playback state did change")
        
    }
    func playerBufferingStateDidChange(player: Player) {
        
        print("buffer state did change")
        
    }
    func playerPlaybackWillStartFromBeginning(player: Player) {
        
        print("playback will start from beginning")
        
    }
    func playerPlaybackDidEnd(player: Player) {
        
        print("playback did end")
        
    }

    
    
    
    //Actions
    @IBAction func secondViewAllComments(sender: AnyObject) {
        
        
        
    }

    
    @IBAction func viewAllComments(sender: AnyObject) {
        
        
        
    }
    
    
    
    func loadData() {
        
        if let actualLike = data["like"] as? Int, actualDislike = data["dislike"] as? Int, actualFirstName = data["firstName"] as? String, actualLastName = data["lastName"] as? String, actualCaption = data["caption"] as? String ,actualContent = data["contentURL"] as? String, actualProfile = data["profilePicture"] as? String, actualCity = data["city"] as? String {
            
            captionOutlet.text = actualCaption
            
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
        }
    }

    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //print(data)
        
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
