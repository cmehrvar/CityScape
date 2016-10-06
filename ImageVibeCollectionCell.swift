//
//  ImageVibeCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-03.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ImageVibeCollectionCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageOutlet: UIImageView!
    
    let activityIndicator = NVActivityIndicatorView(frame: CGRectZero, type: .BallClipRotatePulse, color: UIColor.redColor(), padding: 0)
    
    func createIndicator(){
        
        let x = (self.bounds.width / 2) - 100
        let y = (self.bounds.height / 2) - 100
        
        
        let frame = CGRect(x: x, y: y, width: 200, height: 200)
        
        activityIndicator.frame = frame
        
        self.addSubview(activityIndicator)
        activityIndicator.startAnimation()
        
        
    }
    
    func addPinchRecognizer(){
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler))
        pinchRecognizer.delegate = self
        self.addGestureRecognizer(pinchRecognizer)
        
        
    }
    
    
    func pinchHandler(sender: UIPinchGestureRecognizer) {

        switch sender.state {
            
        case .Began:
            
            print("began")
            
        case .Changed:
            
            print("scale: \(sender.scale)")
            print("velocity: \(sender.velocity)")
   
        case .Ended:
            
            print("ended")
            
        default:
            break

        }
    }

    

    func loadImage(url: NSURL){
        
        let scopeIndicator = activityIndicator

        imageOutlet.sd_setImageWithURL(url, placeholderImage: nil, options: .ContinueInBackground, progress: { (currentSize, expectedSize) in
            
            
            
            
            }) { (image, error, cache, url) in
                
                scopeIndicator.removeFromSuperview()
                scopeIndicator.stopAnimation()
                
                
        }
        
    }
    
    override func prepareForReuse() {
        
        imageOutlet.image = nil
        
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
