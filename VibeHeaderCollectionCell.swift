//
//  VibeHeaderCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-03.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class VibeHeaderCollectionCell: UICollectionViewCell {
    
    //Outlets
    @IBOutlet weak var profilePicOutlet: VibeHeaderProfilePic!
    @IBOutlet weak var cityRankOutlet: UILabel!
    @IBOutlet weak var nameOutlet: UILabel!
    
    
    func loadCell(data: [NSObject : AnyObject]) {
        
        if let profileString = data["profilePicture"] as? String, url = NSURL(string: profileString) {
            
            profilePicOutlet.sd_setImageWithURL(url, placeholderImage: nil)
            
        }
        
        if let firstName = data["firstName"] as? String, lastName = data["lastName"] as? String {
            
            let name = firstName + " " + lastName
            nameOutlet.text = name
            
        }
        
        if let rank = data["cityRank"] as? Int {
            
            cityRankOutlet.text = "#\(String(rank))"
            
        }

    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
