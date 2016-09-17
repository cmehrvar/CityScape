//
//  ProfileCurrentPictureIndicatorVIew.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-17.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ProfileCurrentPictureIndicatorVIew: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor.whiteColor().CGColor
        self.clipsToBounds = true
        
    }


}
