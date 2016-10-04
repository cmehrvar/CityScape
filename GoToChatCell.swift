//
//  GoToChatCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-29.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class GoToChatCell: UICollectionViewCell {
    
    weak var vibesController: NewVibesController?
    var city = ""
    var postKey = ""
    
    
    @IBOutlet weak var buttonOutlet: UIButton!
    
    
    @IBAction func revealChat(sender: AnyObject) {
        
        vibesController?.rootController?.toggleChat("posts", key: postKey, city: city, firstName: nil, lastName: nil, profile: nil, completion: { (bool) in
            
            print("chat toggled")
            
        })

    }
    
    
    
    func loadData(data: [NSObject : AnyObject]) {
        
        if let scopeCity = data["city"] as? String {
            
            self.city = scopeCity
            
        }
        
        if let key = data["postChildKey"] as? String {
            
            self.postKey = key
            
        }
        
        if data["messages"] != nil {
            
            buttonOutlet.setTitle("Reveal chat", forState: .Normal)
            
        } else {
            
            buttonOutlet.setTitle("Start the conversation!", forState: .Normal)
            
        }
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }

}
