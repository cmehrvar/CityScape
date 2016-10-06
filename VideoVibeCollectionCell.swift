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
    var player = 0
    
    @IBOutlet weak var videoThumbnailOutlet: UIImageView!
    @IBOutlet weak var videoOutlet: UIView!
    @IBOutlet weak var soundOutlet: UIView!
    @IBOutlet weak var soundImageOutlet: UIImageView!
    @IBOutlet weak var soundLabelOutlet: UILabel!
    
    
    
    @IBAction func tapForSound(sender: AnyObject) {

        if vibesController?.videoWithSound == postKey {
            
            vibesController?.videoWithSound = ""
            
        } else {
            
            vibesController?.videoWithSound = postKey
            
        }

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

        videoThumbnailOutlet.image = nil
        
        
        for view in videoThumbnailOutlet.subviews {
            
            view.removeFromSuperview()
            
        }
    }
}
