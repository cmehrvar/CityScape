//
//  VideoVibeCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-03.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class VideoVibeCollectionCell: UICollectionViewCell {
    
    weak var vibesController: NewVibesController?
    weak var profileController: ProfileController?
    
    var postKey = ""
    var player = 0
    var index = 0
    
    @IBOutlet weak var videoThumbnailOutlet: UIImageView!
    @IBOutlet weak var videoOutlet: UIView!
    @IBOutlet weak var soundOutlet: UIView!
    @IBOutlet weak var soundImageOutlet: UIImageView!
    @IBOutlet weak var soundLabelOutlet: UILabel!
    
    
    
    @IBAction func tapForSound(_ sender: AnyObject) {
        
        if let vibes = vibesController {
            
            if vibes.videoWithSound == postKey {
                
                vibes.videoWithSound = ""
                vibes.videoPlayers[player]?.isMuted = true
                soundImageOutlet.image = UIImage(named: "mute")
                soundLabelOutlet.text = "Tap for sound"
                
            } else {
                
                vibes.videoWithSound = postKey
                vibes.videoPlayers[player]?.isMuted = false
                soundImageOutlet.image = UIImage(named: "unmute")
                soundLabelOutlet.text = "Tap to mute"
                
            }

        } else if let profile = profileController {
            
            if profile.videoWithSound == postKey {
                
                profile.videoWithSound = ""
                profile.videoPlayers[player]?.isMuted = true
                soundImageOutlet.image = UIImage(named: "mute")
                soundLabelOutlet.text = "Tap for sound"
                
            } else {
                
                profile.videoWithSound = postKey
                profile.videoPlayers[player]?.isMuted = false
                soundImageOutlet.image = UIImage(named: "unmute")
                soundLabelOutlet.text = "Tap to mute"
                
            }
        }
    }
    
    
    func createIndicator(){
        
        let x = (self.bounds.width / 2) - 100
        let y = (self.bounds.height / 2) - 100
        
        for view in videoThumbnailOutlet.subviews {
            
            view.removeFromSuperview()
            
        }

        
        
        let frame = CGRect(x: x, y: y, width: 200, height: 200)
        
        let activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotatePulse, color: UIColor.red, padding: 0)
        self.videoThumbnailOutlet.addSubview(activityIndicator)
        activityIndicator.startAnimation()
        
        
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
    override func prepareForReuse() {

        videoThumbnailOutlet.image = nil
        
        if let vibes = vibesController {
            
            if vibes.videoPlayersObserved[player] {
                
                if let playerPlayer = vibes.videoPlayers[player] {
                    
                    vibes.videoPlayersObserved[player] = false
                    playerPlayer.removeObserver(vibes, forKeyPath: "rate")
                    
                }
            }
            
        } else if let profile = profileController {
            
            if profile.videoPlayersObserved[player] {
                
                if let playerPlayer = profile.videoPlayers[player] {
                    
                    profile.videoPlayersObserved[player] = false
                    playerPlayer.removeObserver(profile, forKeyPath: "rate")
                    
                }
            }
        }

        for view in videoThumbnailOutlet.subviews {
            
            view.removeFromSuperview()
            
        }
    }
}
