//
//  UserVideoPostCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-20.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase
import FirebaseDatabase
import FirebaseAuth

class UserVideoPostCell: UICollectionViewCell {

    var player = 0

    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var videoOutlet: UIView!
    
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
                    let postRef = FIRDatabase.database().reference().child("posts").child(scopeCity).child(scopeChildKey)
                    let userRef = FIRDatabase.database().reference().child("users").child(selfUID).child("posts").child(scopeChildKey)
                    let allPostRef = FIRDatabase.database().reference().child("allPosts").child(scopeChildKey)
                    
                    DispatchQueue.main.async(execute: {
                        
                        postRef.removeValue()
                        userRef.removeValue()
                        allPostRef.removeValue()
                        
                        self.profileController?.rootController?.vibesFeedController?.observeCurrentCityPosts()
                        
                    })
                }))
            }
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            print("cancel post", terminator: "")
            
        }))
        
        
        profileController?.present(alertController, animated: true, completion: {
            
            print("alert controller presented", terminator: "")
            
        })
    }
    
    
    func createIndicator(){
        
        let x = (self.bounds.width / 2) - 20
        let y = (self.bounds.height / 2) - 20
        
        
        let frame = CGRect(x: x, y: y, width: 40, height: 40)
        
        let activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotatePulse, color: UIColor.red, padding: 0)
        self.imageOutlet.addSubview(activityIndicator)
        activityIndicator.startAnimation()
        
        
    }

    
    
    func loadCell(_ data: [AnyHashable: Any]) {
        
        imageOutlet.layer.cornerRadius = 10
        videoOutlet.layer.cornerRadius = 10

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
        
        if let profile = profileController {
            
            if profile.videoPlayersObserved[player] {
                
                if let playerPlayer = profile.videoPlayers[player] {
                    
                    profile.videoPlayersObserved[player] = false
                    playerPlayer.removeObserver(profile, forKeyPath: "rate")
                    
                }
            }
        }
        
        for view in imageOutlet.subviews {
            
            view.removeFromSuperview()
            
        }
    }

    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
