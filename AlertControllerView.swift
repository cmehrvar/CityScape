//
//  AlertControllerView.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-08.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class AlertControllerView: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 25
        self.clipsToBounds = true
    }

}
