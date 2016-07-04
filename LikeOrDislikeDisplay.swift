//
//  LikeOrDislikeDisplay.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-04.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class LikeOrDislikeDisplay: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 15
        layer.borderWidth = 1
        layer.borderColor = UIColor.blackColor().CGColor
        self.clipsToBounds = true
    }

}
