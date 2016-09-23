//
//  HeaderCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-12.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class HeaderCollectionCell: UICollectionViewCell {
    
    weak var userController: UserController?
    weak var cityController: CityController?
    
    @IBOutlet weak var exploreOutlet: UILabel!
    
    @IBAction func showSnapchat(sender: AnyObject) {
        
        if let user = userController {
            
            user.searchController?.rootController?.toggleSnapchat(nil, startingi: nil, completion: { (bool) in
                
                print("snapchat toggled")
                
            })

        } else if let city = cityController {
            
            city.searchController?.rootController?.toggleSnapchat(nil, startingi: nil, completion: { (bool) in
                
                print("snapchat toggled")
                
            })
        }
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
