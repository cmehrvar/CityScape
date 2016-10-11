//
//  NearbyCellView.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-07.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class NearbyCellView: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 8
        self.clipsToBounds = true
    }

}
