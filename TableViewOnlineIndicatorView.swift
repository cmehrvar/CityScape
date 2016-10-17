//
//  TableViewOnlineIndicatorView.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-22.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class TableViewOnlineIndicatorView: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        self.clipsToBounds = true
        
    }
}
