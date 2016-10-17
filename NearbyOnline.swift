//
//  NearbyOnline.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-07.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class NearbyOnline: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.layer.cornerRadius = 6
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.5
        self.clipsToBounds = true
        
    }
}
