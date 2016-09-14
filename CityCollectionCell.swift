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

    weak var searchController: SearchController?
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var cityNameOutlet: UILabel!
    @IBOutlet weak var squadRequestButtonOutlet: UIButton!
    
    
    var userUID = ""
    var city = ""
    

    @IBAction func goToCity(sender: AnyObject) {
        
        if let isCity = searchController?.searchIsCity {
            
            if isCity {
                
                searchController?.rootController?.vibesFeedController?.observingCity = city
                searchController?.rootController?.vibesFeedController?.observePosts()
                
                searchController?.rootController?.toggleVibes({ (bool) in
                    
                    self.searchController?.rootController?.vibesFeedController?.globCollectionView.setContentOffset(CGPointZero, animated: true)
                    print("vibes toggled")
                    
                })
                
            } else {
                
                if let uid = FIRAuth.auth()?.currentUser?.uid {
                    
                    var selfProfile = false
                    
                    if uid == userUID {
                        
                        selfProfile = true
                        
                    }
                    
                    searchController?.rootController?.toggleProfile(userUID, selfProfile: selfProfile, completion: { (bool) in
                        
                        print("profile toggled")
                        
                    })
                }
            }
        }
    }
    


    func updateUI(data: [NSObject : AnyObject]){

        cityNameOutlet.adjustsFontSizeToFitWidth = true
        cityNameOutlet.baselineAdjustment = .AlignCenters

        if let isCity = searchController?.searchIsCity {
            
            if isCity {
                
                if let cityName = data["city"] as? String {
                    
                    city = cityName
                    cityNameOutlet.text = cityName
                    
                }
                
                if let post = data["mostRecentPost"] as? [NSObject : AnyObject] {
                    
                    if let imageString = post["imageURL"] as? String, imageUrl = NSURL(string: imageString) {
                        
                        imageOutlet.sd_setImageWithURL(imageUrl, completed: { (image, error, cache, url) in
                            
                            print("image loaded")
                            
                        })
                    }
                }

            } else {
                
                if let uid = data["uid"] as? String {
                    
                    userUID = uid
                    
                }
                
                
                if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {
                    
                    let name = firstName + " " + lastName
                    
                    cityNameOutlet.text = name
                    
                }
                
                if let profileString = data["profilePicture"] as? String, url = NSURL(string: profileString){
                    
                    imageOutlet.sd_setImageWithURL(url)
                    
                }
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
