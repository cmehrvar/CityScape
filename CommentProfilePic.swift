//
//  CommentProfilePic.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-08.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class CommentProfilePic: UIImageView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 7
        self.clipsToBounds = true
    }

}
