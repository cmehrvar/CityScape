//
//  LikeButtonsCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-29.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class LikeButtonsCollectionCell: UICollectionViewCell {
    
    weak var vibesController: NewVibesController?
    
    var uid = ""
    var image = ""
    var city = ""
    var postKey = ""
    
    @IBOutlet weak var label1Outlet: UILabel!
    @IBOutlet weak var label2Outlet: UILabel!
    @IBOutlet weak var label3Outlet: UILabel!
    @IBOutlet weak var label4Outlet: UILabel!
    @IBOutlet weak var label5Outlet: UILabel!
    
    @IBOutlet weak var button1Outlet: UIButton!
    @IBOutlet weak var button2Outlet: UIButton!
    @IBOutlet weak var button3Outlet: UIButton!
    @IBOutlet weak var button4Outlet: UIButton!
    @IBOutlet weak var button5Outlet: UIButton!
    
    
    func add(button: String){
        
        let scopePostKey = postKey
        
        let ref = FIRDatabase.database().reference().child("posts").child(city).child(postKey)
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            ref.child("liked").child(selfUID).setValue(true)
        }
        
        ref.child(button).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.exists(){
                
                if scopePostKey == self.postKey {
                    
                    if let number = snapshot.value as? Int {
                        
                        ref.child(button).setValue(number + 1)
                        
                    }
                }
                
            } else {
                
                ref.child(button).setValue(1)
                
            }
        })
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if selfUID != uid {
                
                let timeStamp = NSDate().timeIntervalSince1970
                
                let notificationItem = [
                    
                    "postChildKey" : postKey,
                    "read" : false,
                    "timeStamp" : timeStamp,
                    "type" : "post",
                    "city" : city,
                    "button" : button,
                    "senderUid" : selfUID,
                    "image" : image
                    
                ]
                
                
                let userRef = FIRDatabase.database().reference().child("users").child(uid)
                userRef.child("notifications").child("posts").child(postKey).setValue(notificationItem)
                
            }
        }
    }
    
    
    
    @IBAction func one(sender: AnyObject) {
        
        add("one")
    }
    
    
    @IBAction func two(sender: AnyObject) {
        
        add("two")
        
    }
    
    
    @IBAction func three(sender: AnyObject) {
        
        add("three")
        
        
        
    }
    
    
    @IBAction func four(sender: AnyObject) {
        
        add("four")
        
        
    }
    
    @IBAction func five(sender: AnyObject) {
        
        add("five")
    }
    
    
    func loadData(data: [NSObject : AnyObject]) {
        
        if let uid = data["userUID"] as? String {
            
            self.uid = uid
            
        }
        
        if let imageString = data["imageURL"] as? String {
            
            self.image = imageString
            
        }
        
        button1Outlet.enabled = false
        button2Outlet.enabled = false
        button3Outlet.enabled = false
        button4Outlet.enabled = false
        button5Outlet.enabled = false
        
        if let city = data["city"] as? String,  key = data["postChildKey"] as? String {
            
            self.city = city
            self.postKey = key
            
            let ref = FIRDatabase.database().reference().child("posts").child(city).child(postKey)

            ref.child("liked").observeEventType(.Value, withBlock: { (snapshot) in
                
                if key == self.postKey {
                    
                    if snapshot.exists() {
                        
                        if let usersLiked = snapshot.value as? [String : Bool], selfUID = FIRAuth.auth()?.currentUser?.uid {
                            
                            if usersLiked[selfUID] == nil {
                                
                                self.button1Outlet.enabled = true
                                self.button2Outlet.enabled = true
                                self.button3Outlet.enabled = true
                                self.button4Outlet.enabled = true
                                self.button5Outlet.enabled = true
                                
                            } else {
                                
                                self.button1Outlet.enabled = false
                                self.button2Outlet.enabled = false
                                self.button3Outlet.enabled = false
                                self.button4Outlet.enabled = false
                                self.button5Outlet.enabled = false

                            }
                        }
                        
                    } else {
                        
                        self.button1Outlet.enabled = true
                        self.button2Outlet.enabled = true
                        self.button3Outlet.enabled = true
                        self.button4Outlet.enabled = true
                        self.button5Outlet.enabled = true
                        
                    }
                }
            })

            ref.child("one").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.postKey == key {
                    
                    if snapshot.exists() {
                        
                        if let one = snapshot.value as? Int {
                            
                            self.label1Outlet.text = "\(one)"
                            
                        }
                        
                    } else {
                        
                        self.label1Outlet.text = "0"
                        
                    }
                }
            })

            ref.child("two").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.postKey == key {
                    
                    if snapshot.exists() {
                        
                        if let two = snapshot.value as? Int {
                            
                            self.label2Outlet.text = "\(two)"
                            
                        }
                        
                    } else {
                        
                        self.label2Outlet.text = "0"
                        
                    }
                }
            })
            
            ref.child("three").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.postKey == key {
                    
                    if snapshot.exists() {
                        
                        if let three = snapshot.value as? Int {
                            
                            self.label3Outlet.text = "\(three)"
                            
                        }
                        
                    } else {
                        
                        self.label3Outlet.text = "0"
                        
                    }
                }
            })

            ref.child("four").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.postKey == key {
                    
                    if snapshot.exists() {
                        
                        if let four = snapshot.value as? Int {
                            
                            self.label4Outlet.text = "\(four)"
                            
                        }
                        
                    } else {
                        
                        self.label4Outlet.text = "0"
                        
                    }
                }
            })
            
            
            ref.child("five").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.postKey == key {
                    
                    if snapshot.exists() {
                        
                        if let five = snapshot.value as? Int {
                            
                            self.label5Outlet.text = "\(five)"
                            
                        }
                        
                    } else {
                        
                        self.label5Outlet.text = "0"
                        
                    }
                }
            })
        }
    }
    
    
    override func prepareForReuse() {
        
        label1Outlet.text = nil
        label2Outlet.text = nil
        label3Outlet.text = nil
        label4Outlet.text = nil
        label5Outlet.text = nil
        
    }
    
    
    
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}



