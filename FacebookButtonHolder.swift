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
        layer.cornerRadius = 20
        layer.borderWidth = 5
        layer.borderColor = UIColor.whiteColor().CGColor
        self.clipsToBounds = true
    }


}
