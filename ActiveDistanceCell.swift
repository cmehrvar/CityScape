//
//  ActiveDistanceCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-17.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ActiveDistanceCell: UICollectionViewCell {
    
    weak var profileController: ProfileController?

    @IBOutlet weak var distanceOutlet: UILabel!
    @IBOutlet weak var activeOutlet: UILabel!
    
    func loadData(_ data: [AnyHashable: Any]){
        
        if let online = data["online"] as? Bool {
            
            if online {
                
                activeOutlet.text = "Active now"
                
            } else {
                
                if let active = data["lastActive"] as? TimeInterval {
                    
                    let date = Date(timeIntervalSince1970: active)
                    activeOutlet.text = "Active " + timeAgoSince(date: date as NSDate, showAccronym: true) + " ago"
                    
                }
            }
        }
        
        if let latitude = data["latitude"] as? CLLocationDegrees, let longitude = data["longitude"] as? CLLocationDegrees {
            
            guard let selfLatitude = profileController?.rootController?.selfData["latitude"] as? CLLocationDegrees, let selfLongitude = profileController?.rootController?.selfData["longitude"] as? CLLocationDegrees else {return}
            
            let selfCoordinate = CLLocation(latitude: selfLatitude, longitude: selfLongitude)
            let userCoordinate = CLLocation(latitude: latitude, longitude: longitude)
            
            let distance = selfCoordinate.distance(from: userCoordinate)
            
            if distance > 9999 {
                
                let kilometers: Int = Int(distance) / 1000
                distanceOutlet.text = "Now about " + String(kilometers) + "km away"
                
            } else if distance > 99 {
                
                let kilometers: Double = Double(distance) / 1000
                let rounded = round(kilometers*10) / 10
                distanceOutlet.text = "Now about " + String(rounded) + "km away"
                
            } else {
                
                distanceOutlet.text = "Now about " + String(Int(round(distance))) + "m away"
                
            }
        }
    }
    
    override func prepareForReuse() {
        
        distanceOutlet.text = nil
        activeOutlet.text = nil
        
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
