//
//  CityCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-12.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class CityCollectionCell: UICollectionViewCell {
    
    weak var cityController: CityController?
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var cityNameOutlet: UILabel!
    @IBOutlet weak var squadRequestButtonOutlet: UIButton!
    
    var city = ""
    
    @IBAction func goToCity(sender: AnyObject) {
        
        cityController?.searchController?.rootController?.vibesFeedController?.observingCity = city
        cityController?.searchController?.rootController?.vibesFeedController?.observePosts()

        cityController?.searchController?.rootController?.searchRevealed = false

        cityController?.searchController?.rootController?.toggleVibes({ (bool) in
            
            self.cityController?.searchController?.rootController?.vibesFeedController?.globCollectionView.setContentOffset(CGPointZero, animated: true)
            
        })

    }
    
    
    func updateUI(data: [NSObject : AnyObject]){
        
        cityNameOutlet.adjustsFontSizeToFitWidth = true
        cityNameOutlet.baselineAdjustment = .AlignCenters

        if let cityName = data["city"] as? String {
            
            var label = cityName
            
            city = cityName
            
            if let state = data["state"] as? String {
                
                label += ", \(state)"

            }
            
            cityNameOutlet.text = label
            
        }
        
        if let post = data["mostRecentPost"] as? [NSObject : AnyObject] {
            
            if let imageString = post["imageURL"] as? String, imageUrl = NSURL(string: imageString) {
                
                imageOutlet.sd_setImageWithURL(imageUrl, completed: { (image, error, cache, url) in
                    
                    print("image loaded")
                    
                })
            }
        }

        cellView.layer.cornerRadius = 15
        
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
