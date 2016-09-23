//
//  StatusCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-21.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class StatusCell: UICollectionViewCell {

    @IBOutlet weak var statusOutlet: UILabel!
    
    func loadCell(data: [NSObject : AnyObject]){
        
        statusOutlet.adjustsFontSizeToFitWidth = true
        statusOutlet.baselineAdjustment = .AlignCenters
        
        if let status = data["currentStatus"] as? String {
            
            statusOutlet.text = status
            
        }
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
