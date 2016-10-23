//
//  UserPostCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-17.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class UserImagePostCell: UICollectionViewCell {
    
    @IBOutlet weak var imageOutlet: UIImageView!

    var uid = ""
    
    var city = ""
    var postChildKey = ""
    var index = 0
    var posts = [[AnyHashable: Any]]()

    weak var profileController: ProfileController?
    
    @IBAction func goToContent(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        
        let scopePosts = posts
        let scopeIndex = index
        
        alertController.addAction(UIAlertAction(title: "Enlarge", style: .default, handler: { (action) in
            
            self.profileController?.rootController?.toggleSnapchat(scopePosts, startingi: scopeIndex, completion: { (bool) in
                
                print("snapchat toggled", terminator: "")
                
            })
        }))
        
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let scopeCity = city
            let scopeChildKey = postChildKey
            
            if uid == selfUID {
                
                alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    
                    print("delete post")
                    
                    FIRDatabase.database().reference().child("posts").child(scopeCity).child(scopeChildKey).removeValue()
                    FIRDatabase.database().reference().child("users").child(selfUID).child("posts").child(scopeChildKey).removeValue()
                    FIRDatabase.database().reference().child("allPosts").child(scopeChildKey).removeValue()
                    
                    FIRDatabase.database().reference().child("posts").child(scopeCity).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if !snapshot.exists() {
                            
                            FIRDatabase.database().reference().child("cityLocations").child(scopeCity).removeValue()
                            
                        }
                        
                    })
                    
                    self.profileController?.rootController?.vibesFeedController?.observeCurrentCityPosts()

                }))
            }
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            print("cancel post", terminator: "")
            
        }))

        let popover = alertController.popoverPresentationController
        popover?.sourceView = self
        popover?.sourceRect = self.bounds
        popover?.permittedArrowDirections = UIPopoverArrowDirection.any

        profileController?.present(alertController, animated: true, completion: {
            
            print("alert controller presented", terminator: "")
            
        })
    }
    
    
    
    func loadCell(_ data: [AnyHashable: Any]) {
        
        imageOutlet.layer.cornerRadius = 10

        if let userUID = data["userUID"] as? String {
            
            self.uid = userUID
            
        }
        
        if let imageString = data["imageURL"] as? String, let url = URL(string: imageString) {
            
            imageOutlet.sd_setImage(with: url, placeholderImage: nil)
            
        }
        
        if let city = data["city"] as? String {
            self.city = city
        }
        
        if let key = data["postChildKey"] as? String {
            self.postChildKey = key
            
        }
        
    }
    
    override func prepareForReuse() {
        
        imageOutlet.image = nil
        
    }

    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
