//
//  MessageProfileView.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-25.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class MessageProfileView: UIImageView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 39
        self.clipsToBounds = true
        
    }

}
