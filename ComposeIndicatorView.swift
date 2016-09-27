//
//  ComposeIndicatorView.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-26.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ComposeIndicatorView: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 15
        layer.borderWidth = 3
        layer.borderColor = UIColor.darkGrayColor().CGColor
        self.clipsToBounds = true
        
    }

}
