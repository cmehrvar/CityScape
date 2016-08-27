//
//  MatchProfileViews.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-27.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class MatchProfileViews: UIImageView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        print("profile width: \(self.frame.width)")
        print("profile height: \(self.frame.height)")
        
        self.clipsToBounds = true
        
    }

}
