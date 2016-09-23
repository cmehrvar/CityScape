//
//  UserVideoPostCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-20.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class UserVideoPostCell: UICollectionViewCell {
    
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var videoOutlet: UIView!
    
    var city = ""
    var postChildKey = ""
    var index = 0
    var posts = [[NSObject : AnyObject]]()
    
    weak var profileController: ProfileController?
    
    @IBAction func goToContent(sender: AnyObject) {
        
        self.profileController?.rootController?.toggleSnapchat(posts, startingi: index, completion: { (bool) in
            
            print("snapchat toggled")
            
        })
    }
    
    
    func createIndicator(){
        
        let x = (self.bounds.width / 2) - 20
        let y = (self.bounds.height / 2) - 20
        
        
        let frame = CGRect(x: x, y: y, width: 40, height: 40)
        
        let activityIndicator = NVActivityIndicatorView(frame: frame, type: .BallClipRotatePulse, color: UIColor.redColor(), padding: 0)
        self.imageOutlet.addSubview(activityIndicator)
        activityIndicator.startAnimation()
        
        
    }

    
    
    func loadCell(data: [NSObject:AnyObject]) {
        
        imageOutlet.layer.cornerRadius = 10
        videoOutlet.layer.cornerRadius = 10
        
        if let imageString = data["imageURL"] as? String, url = NSURL(string: imageString) {
            
            imageOutlet.sd_setImageWithURL(url, placeholderImage: nil)
            
        }
        
        if let city = data["city"] as? String {
            self.city = city
        }
        
        if let key = data["postChildKey"] as? String {
            self.postChildKey = key
            
        }
        
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
