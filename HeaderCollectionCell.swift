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
    
    @IBAction func showSnapchat(_ sender: AnyObject) {
        
        if let user = userController {
            
            userController?.searchController?.rootController?.vibesFeedController?.observeCurrentCityPosts()
            
            userController?.searchController?.rootController?.searchRevealed = false
            
            userController?.searchController?.rootController?.toggleVibes({ (bool) in
                
                self.cityController?.searchController?.rootController?.vibesFeedController?.globCollectionView.setContentOffset(CGPoint.zero, animated: true)
                
            })
            
        } else if let city = cityController {

            cityController?.searchController?.rootController?.vibesFeedController?.observeCurrentCityPosts()
            
            cityController?.searchController?.rootController?.searchRevealed = false
            
            cityController?.searchController?.rootController?.toggleVibes({ (bool) in
                
                self.cityController?.searchController?.rootController?.vibesFeedController?.globCollectionView.setContentOffset(CGPoint.zero, animated: true)
                
            })

        }
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
