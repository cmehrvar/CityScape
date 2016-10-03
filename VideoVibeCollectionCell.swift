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
        
        if let subLayers = videoOutlet.layer.sublayers {
            
            for layer in subLayers {
                
                layer.removeFromSuperlayer()
                
            }
        }

        for view in videoThumbnailOutlet.subviews {
            
            view.removeFromSuperview()
            
        }
        
        /*

        if playerTitle == "player1" {
            
            if let vibes = vibesController {
                
                vibesController?.player1?.removeObserver(vibes, forKeyPath: "rate")

            }
            
            vibesController?.player1Key = ""
            vibesController?.player1?.pause()
            vibesController?.player1 = nil
            vibesController?.playerItem1 = nil
            
        } else if playerTitle == "player2" {
            
            if let vibes = vibesController {
                
                vibesController?.player2?.removeObserver(vibes, forKeyPath: "rate")
                
            }
            
            vibesController?.player2Key = ""
            vibesController?.player2?.pause()
            vibesController?.player2 = nil
            vibesController?.playerItem2 = nil

        } else if playerTitle == "player3" {
            
            if let vibes = vibesController {
                
                vibesController?.player3?.removeObserver(vibes, forKeyPath: "rate")
                
            }
            
            vibesController?.player3Key = ""
            vibesController?.player3?.pause()
            vibesController?.player3 = nil
            vibesController?.playerItem3 = nil
            
        }
 */
    }
    
    deinit {
        
        if playerTitle == "player1" {
            
            if let vibes = vibesController {
                
                vibesController?.player1?.removeObserver(vibes, forKeyPath: "rate")
                
            }
            
            vibesController?.player1Key = ""
            vibesController?.player1?.pause()
            vibesController?.player1 = nil
            vibesController?.playerItem1 = nil
            
        } else if playerTitle == "player2" {
            
            if let vibes = vibesController {
                
                vibesController?.player2?.removeObserver(vibes, forKeyPath: "rate")
                
            }
            
            vibesController?.player2Key = ""
            vibesController?.player2?.pause()
            vibesController?.player2 = nil
            vibesController?.playerItem2 = nil
            
        } else if playerTitle == "player3" {
            
            if let vibes = vibesController {
                
                vibesController?.player3?.removeObserver(vibes, forKeyPath: "rate")
                
            }
            
            vibesController?.player3Key = ""
            vibesController?.player3?.pause()
            vibesController?.player3 = nil
            vibesController?.playerItem3 = nil
            
        }
    }
}
