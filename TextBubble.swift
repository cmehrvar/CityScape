//
//  TextBubble.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-17.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class TextBubble: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 6
        self.clipsToBounds = true
    }
}
