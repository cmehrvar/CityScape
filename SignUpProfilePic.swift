//
//  ProfilePicActualView.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-02.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class SignUpProfilePic: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 45
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        self.clipsToBounds = true
    }
}
