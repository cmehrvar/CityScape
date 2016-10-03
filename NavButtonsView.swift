//
//  NavButtonsView.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-06.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class NavButtonsView: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = UIColor.whiteColor().CGColor
        self.clipsToBounds = true
    }

}
