//
//  ProfilePictureView.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-23.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ProfilePictureView: UIImageView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.blackColor().CGColor
        self.clipsToBounds = true
    }


}
