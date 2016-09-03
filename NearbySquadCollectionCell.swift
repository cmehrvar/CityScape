//
//  NearbyCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-07.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import THLabel

class NearbySquadCollectionCell: UICollectionViewCell {
    
    //Variables
    weak var nearbyController: NearbyController?
    var index = 0
    var uid = ""
    var profilePic = ""
    
    //Outlets
    @IBOutlet weak var nameOutlet: THLabel!
    @IBOutlet weak var occupationOutlet: UILabel!
    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var onlineOutlet: NearbyOnline!

    
    //Actions
    @IBAction func squadRequest(sender: AnyObject) {

        print("squad request sent")
        
    }
    
    
    @IBAction func goToProfile(sender: AnyObject) {
        
        nearbyController?.rootController?.toggleProfile(uid, selfProfile: false, profilePic: profilePic, completion: { (bool) in
            
            print("profile toggled")
            
        })

    }

    
    @IBAction func dismiss(sender: AnyObject) {

        if let last = nearbyController?.nearbyUsers.last {
            
            nearbyController?.dismissedCells[uid] = true
            
            if let lastUID = last["uid"] as? String {
                nearbyController?.addedCells[lastUID] = index
            }
            
            nearbyController?.addedIndex -= 1

            nearbyController?.nearbyUsers[index] = last
            nearbyController?.nearbyUsers.removeLast()
            nearbyController?.globCollectionView.reloadData()
            
        }

        print("cell dismissed")
    }
    
    
    //Functions
    func loadUser(data: [NSObject : AnyObject]){
        
        if let firstName = data["firstName"] as? String {
            
            var name = firstName
            var occupation = ""
            
            if let age = data["age"] as? NSTimeInterval {
                
                let date = NSDate(timeIntervalSince1970: age)
                name += ", " + timeAgoSince(date, showAccronym: false)
                
            }
            
            if let actualOccupation = data["occupation"] as? String {
                
                occupation = actualOccupation
                
            }
            
            if let profile = data["profilePicture"] as? String, profileURL = NSURL(string: profile) {
                self.profilePic = profile
                profileOutlet.sd_setImageWithURL(profileURL, placeholderImage: nil)
                
            }
            
            if let online = data["online"] as? Bool {
                
                if online {
                    onlineOutlet.backgroundColor = UIColor.greenColor()
                } else {
                    onlineOutlet.backgroundColor = UIColor.redColor()
                }
            }
            

            nameOutlet.text = name
            nameOutlet.strokeSize = 0.25
            nameOutlet.strokeColor = UIColor.blackColor()
            nameOutlet.lineBreakMode = .ByWordWrapping

            occupationOutlet.text = occupation
            occupationOutlet.adjustsFontSizeToFitWidth = true
        }
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    } 
}