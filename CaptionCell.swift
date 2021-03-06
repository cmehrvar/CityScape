//
//  CaptionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-29.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class CaptionCell: UICollectionViewCell {

    @IBOutlet weak var captionOutlet: UILabel!
    
    func loadData(_ data: [AnyHashable: Any]) {
        
        captionOutlet.adjustsFontSizeToFitWidth = true
        captionOutlet.baselineAdjustment = .alignCenters
        
        if let caption = data["caption"] as? String {
            
            self.captionOutlet.text = caption
            
        }
    }
    
    override func prepareForReuse() {
        
        captionOutlet.text = nil
        
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
