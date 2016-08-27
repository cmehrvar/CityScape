//
//  MatchButtons.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-27.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class MatchButtons: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 15
        layer.borderWidth = 2
        layer.borderColor = UIColor.whiteColor().CGColor
        self.clipsToBounds = true
        
    }


}
