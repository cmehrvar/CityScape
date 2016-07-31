//
//  homeCommentProfile.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-18.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class homeCommentProfile: UIImageView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 10
        self.clipsToBounds = true
    }

}
