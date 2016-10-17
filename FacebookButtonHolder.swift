//
//  FacebookButtonHolder.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-09.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class FacebookButtonHolder: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        self.clipsToBounds = true
    }


}
