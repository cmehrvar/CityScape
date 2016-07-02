//
//  ImageContentCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-02.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ImageContentCell: UITableViewCell {
    
    
    //Outlets
    @IBOutlet weak var imageOutlet: UIImageView!
    
    
    
    
    

    @IBAction func viewCommentsAction(sender: AnyObject) {
        
        print("view comments tapped")
        
    }
    
    
    @IBAction func viewAllCommentsAction(sender: AnyObject) {
        
        print("view all comments tapped")
        
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
