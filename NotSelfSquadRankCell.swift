//
//  NotSelfSquadRankCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-17.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class NotSelfSquadRankCell: UICollectionViewCell {
    
    weak var profileController: ProfileController?
    
    var userData = [NSObject : AnyObject]()
    
    //Outlets
    @IBOutlet weak var squadCountOutlet: UILabel!
    @IBOutlet weak var rankOutlet: UILabel!
    
    
    
    @IBAction func revealSquad(sender: AnyObject) {
        
        profileController?.rootController?.openSquadCount(userData, completion: { (bool) in
            
            print("squad count revealed", terminator: "")
            
        })
    }

    
    func loadData(data: [NSObject : AnyObject]){
        
        userData = data
        
        if let rank = data["cityRank"] as? Int {
            
            rankOutlet.text = "#" + String(rank)
            
        }
        
        if let squad = data["squad"] as? [String : AnyObject] {
            
            squadCountOutlet.text = String(squad.count)
            
        } else {
            squadCountOutlet.text = "0"
        }
        
    }
    
    override func prepareForReuse() {
        
        squadCountOutlet.text = nil
        rankOutlet.text = nil
        
    }

    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
