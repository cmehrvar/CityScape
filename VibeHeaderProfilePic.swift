//
//  VibeHeaderProfilePic.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-04.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class VibeHeaderProfilePic: UIImageView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 20
        self.clipsToBounds = true
        
    }


}
