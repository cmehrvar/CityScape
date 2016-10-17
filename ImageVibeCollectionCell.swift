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
    
    let activityIndicator = NVActivityIndicatorView(frame: CGRect.zero, type: .ballClipRotatePulse, color: UIColor.red, padding: 0)
    
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
    
    
    func pinchHandler(_ sender: UIPinchGestureRecognizer) {

        switch sender.state {
            
        case .began:
            
            print("began", terminator: "")
            
        case .changed:
            
            print("scale: \(sender.scale)", terminator: "")
            print("velocity: \(sender.velocity)", terminator: "")
   
        case .ended:
            
            print("ended", terminator: "")
            
        default:
            break

        }
    }

    

    func loadImage(_ url: URL){
        
        let scopeIndicator = activityIndicator

        imageOutlet.sd_setImage(with: url, placeholderImage: nil, options: .continueInBackground, progress: { (currentSize, expectedSize) in
            
            
            
            
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
