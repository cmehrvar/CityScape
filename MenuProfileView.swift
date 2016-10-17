//
//  MenuProfileView.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-20.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class MenuProfileView: UIImageView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 45
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        self.clipsToBounds = true
        
    }


}
