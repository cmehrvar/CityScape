//
//  TopChatProfileView.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-14.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class TopChatProfileView: UIImageView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 17
        layer.borderWidth = 2
        layer.borderColor = UIColor.whiteColor().CGColor
        self.clipsToBounds = true
        
    }
}
