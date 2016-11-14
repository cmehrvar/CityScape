//
//  ViewModeCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-11-09.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ViewModeCell: UICollectionViewCell {
    
    weak var profileController: ProfileController?
    
    @IBOutlet weak var gridViewOutlet: UIImageView!
    @IBOutlet weak var listViewOutlet: UIImageView!
    
    
    func setViewMode(){
        
        if let gridView = profileController?.gridView {
            
            if gridView {
                
                gridViewOutlet.image = UIImage(named: "enabledGridView")
                listViewOutlet.image = UIImage(named: "disabledListView")
                
            } else {
                
                gridViewOutlet.image = UIImage(named: "disabledGridView")
                listViewOutlet.image = UIImage(named: "enabledListView")
                
            }
        }
    }
    
    
    
    @IBAction func toggleGridView(_ sender: AnyObject) {

        profileController?.gridView = true
        profileController?.globCollectionCell.reloadData()

    }
    
    @IBAction func toggleListView(_ sender: AnyObject) {

        profileController?.gridView = false
        profileController?.globCollectionCell.reloadData()
        
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    } 
}
