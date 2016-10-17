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

    func loadData(_ data: [AnyHashable: Any]) {
        
        if let timeStamp = data["timeStamp"] as? TimeInterval {
            
            let timeAgo = timeAgoSince(date: Date(timeIntervalSince1970: timeStamp) as NSDate, showAccronym: true)
            
            timeAgoOutlet.text = timeAgo
            
            
        }
    }
    
    override func prepareForReuse() {
        
        timeAgoOutlet.text = nil
        
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }

    
}
