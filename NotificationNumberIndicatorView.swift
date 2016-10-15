//
//  NotificationNumberIndicatorView.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-21.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class NotificationNumberIndicatorView: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 10
        self.clipsToBounds = true
        
    }
}
