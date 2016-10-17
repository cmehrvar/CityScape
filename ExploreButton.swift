//
//  ExploreButton.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-16.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ExploreButton: UIView {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = true
        
    }
    
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
