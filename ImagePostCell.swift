//
//  UserPostCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-17.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class UserImagePostCell: UICollectionViewCell {
    
    @IBOutlet weak var imageOutlet: UIImageView!

    var city = ""
    var postChildKey = ""
    var index = 0
    var posts = [[NSObject : AnyObject]]()

    weak var profileController: ProfileController?
    
    @IBAction func goToContent(sender: AnyObject) {
        
        self.profileController?.rootController?.toggleSnapchat(posts, startingi: index, completion: { (bool) in
            
            print("user snapchat toggled")
            
        })
    }
    
    
    
    func loadCell(data: [NSObject:AnyObject]) {
        
        imageOutlet.layer.cornerRadius = 10
        
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
