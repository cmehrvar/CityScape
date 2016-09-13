//
//  CityCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-12.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class CityCollectionCell: UICollectionViewCell {

    weak var searchController: SearchController?
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var cityNameOutlet: UILabel!
    
    var city = ""

    @IBAction func goToCity(sender: AnyObject) {
        
        searchController?.rootController?.vibesFeedController?.observingCity = city
        searchController?.rootController?.vibesFeedController?.observePosts()
        
        searchController?.rootController?.toggleVibes({ (bool) in
            
            print("vibes toggled")
            
        })
    }
    


    func updateUI(cityData: [NSObject : AnyObject]){

        cityNameOutlet.adjustsFontSizeToFitWidth = true
        
        if let cityName = cityData["city"] as? String {
            
            
            city = cityName
            cityNameOutlet.text = cityName
            
        }
        
        
        if let post = cityData["mostRecentPost"] as? [NSObject : AnyObject] {
            
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
