//
//  ProfileCoverCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-15.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileInfoCollectionCell: UICollectionViewCell {

    //Variables
    weak var profileController: ProfileController?

    //Outlets
    @IBOutlet weak var profileOutlet: ProfilePictureView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityOutlet: UILabel!
    @IBOutlet weak var rankOutlet: UILabel!
    @IBOutlet weak var squadCountOutlet: UILabel!
    @IBOutlet weak var occupationOutlet: UILabel!
    @IBOutlet weak var activeOutlet: UILabel!
    @IBOutlet weak var distanceOutlet: UILabel!
    
    
    //Functions
    func loadData(data: [NSObject:AnyObject]){
        
        if let profile = data["profilePicture"] as? String, profileURL = NSURL(string: profile){
            
            profileOutlet.sd_setImageWithURL(profileURL, placeholderImage: nil)
            
        }
        
        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {

            nameOutlet.text = firstName + " " + lastName

        }
        
        if let city = data["city"] as? String {
            
            var fullCity = city
            
            if let state = data["state"] as? String {
                fullCity += ", " + state
            }
            
            cityOutlet.text = fullCity
            
        } else if let state = data["state"] as? String {

            cityOutlet.text = state
            
        }
        
        
        if let rank = data["cityRank"] as? Int {
            
            rankOutlet.text = "#" + String(rank)
            
        }
        
        if let squad = data["squad"] as? [String : AnyObject] {

            squadCountOutlet.text = String(squad.count)
            
        } else {
            squadCountOutlet.text = "add squad feature"
        }
        
        
        if let occupation = data["occupation"] as? String {
            
            var fullOccupation = occupation
            
            if let employer = data["employer"] as? String {
                fullOccupation += " at " + employer
            }

            occupationOutlet.text = fullOccupation
        }
        
        if let online = data["online"] as? Bool {
            
            if online {
                
                activeOutlet.text = "Active now"
                
            } else {
                
                if let active = data["lastActive"] as? NSTimeInterval {
                    
                    let date = NSDate(timeIntervalSince1970: active)
                    activeOutlet.text = "Active " + timeAgoSince(date, showAccronym: true) + " ago"

                }
            }
        }
        
        if let latitude = data["latitude"] as? CLLocationDegrees, longitude = data["longitude"] as? CLLocationDegrees {
            
            guard let selfLatitude = profileController?.rootController?.selfData["latitude"] as? CLLocationDegrees, selfLongitude = profileController?.rootController?.selfData["longitude"] as? CLLocationDegrees else {return}

            let selfCoordinate = CLLocation(latitude: selfLatitude, longitude: selfLongitude)
            let userCoordinate = CLLocation(latitude: latitude, longitude: longitude)
            
            let distance = selfCoordinate.distanceFromLocation(userCoordinate)

            if distance > 9999 {
                
                let kilometers: Int = Int(distance) / 1000
                
                distanceOutlet.text = "Now about " + String(kilometers) + "km away"
                
            } else {
                
                distanceOutlet.text = "Now about " + String(Int(round(distance))) + "m away"
                
            }
        }
    }
    
    //Actions
    @IBAction func squadRequest(sender: AnyObject) {
        print("squad request")
    }
    
    
    @IBAction func message(sender: AnyObject) {
        print("send message")
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
