//
//  HeaderCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-12.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class HeaderCollectionCell: UICollectionViewCell {
    
    weak var searchController: SearchController?
    
    @IBOutlet weak var exploreOutlet: UILabel!
    
    @IBAction func showSnapchat(sender: AnyObject) {
        
        searchController?.rootController?.toggleSnapchat({ (bool) in
            
            print("snapchat toggled")
            
        })
        
        
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
