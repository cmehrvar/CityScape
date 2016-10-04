//
//  TimeAgoCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-29.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class TimeAgoCollectionCell: UICollectionViewCell {

    @IBOutlet weak var timeAgoOutlet: UILabel!

    func loadData(data: [NSObject : AnyObject]) {
        
        if let timeStamp = data["timeStamp"] as? NSTimeInterval {
            
            let timeAgo = timeAgoSince(NSDate(timeIntervalSince1970: timeStamp), showAccronym: true)
            
            timeAgoOutlet.text = timeAgo
            
            
        }
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }

    
}
