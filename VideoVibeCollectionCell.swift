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

    var postKey = ""
    
    

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
    
    
}
