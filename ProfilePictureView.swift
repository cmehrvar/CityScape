//
//  ProfilePictureView.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-15.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ProfilePictureView: UIImageView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 60
        layer.borderWidth = 3
        layer.borderColor = UIColor.white.cgColor
        self.clipsToBounds = true
        
    }
}
