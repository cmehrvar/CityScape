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
    
    var postKey = ""
    var playerTitle = ""
    
    @IBOutlet weak var videoThumbnailOutlet: UIImageView!
    @IBOutlet weak var videoOutlet: UIView!
    
    
    
    @IBAction func tapForSound(sender: AnyObject) {

        vibesController?.videoWithSound = postKey
        vibesController?.globCollectionView.reloadData()
        
    }
    
    
    func createIndicator(){
        
        let x = (self.bounds.width / 2) - 100
        let y = (self.bounds.height / 2) - 100
        
        
        let frame = CGRect(x: x, y: y, width: 200, height: 200)
        
        let activityIndicator = NVActivityIndicatorView(frame: frame, type: .BallClipRotatePulse, color: UIColor.redColor(), padding: 0)
        self.videoThumbnailOutlet.addSubview(activityIndicator)
        activityIndicator.startAnimation()
        
        
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
    override func prepareForReuse() {

        if let vibes = vibesController {
            
            if playerTitle == "player1" {

                if vibes.player1Observing {
                    
                    vibesController?.player1?.removeObserver(vibes, forKeyPath: "rate")
                    vibesController?.player1Observing = false

                }

            } else if playerTitle == "player2" {
                
                if vibes.player2Observing {
                    
                    vibesController?.player2?.removeObserver(vibes, forKeyPath: "rate")
                    vibesController?.player2Observing = false
                    
                }
                
            } else if playerTitle == "player3" {
                
                if vibes.player3Observing {
                    
                    vibesController?.player3?.removeObserver(vibes, forKeyPath: "rate")
                    vibesController?.player3Observing = false
                    
                }
            }
        }

        print(playerTitle)
 
        for view in videoThumbnailOutlet.subviews {
            
            view.removeFromSuperview()
            
        }
    }
}
