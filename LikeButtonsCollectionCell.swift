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
        
        if let usersLiked = data["liked"] as? [String : Bool] {
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if usersLiked[selfUID] == nil {
                    
                    button1Outlet.enabled = true
                    button2Outlet.enabled = true
                    button3Outlet.enabled = true
                    button4Outlet.enabled = true
                    button5Outlet.enabled = true
                    
                } else {
                    
                    button1Outlet.enabled = false
                    button2Outlet.enabled = false
                    button3Outlet.enabled = false
                    button4Outlet.enabled = false
                    button5Outlet.enabled = false
                    
                }
            }
            
        } else {
            
            button1Outlet.enabled = true
            button2Outlet.enabled = true
            button3Outlet.enabled = true
            button4Outlet.enabled = true
            button5Outlet.enabled = true
            
        }
        
        if let city = data["city"] as? String {
            
            self.city = city
            
        }
        
        if let key = data["postChildKey"] as? String {
            
            self.postKey = key
            
        }
        
        
        if let one = data["one"] as? Int {
            
            label1Outlet.text = String(one)
            
        } else {
            
            label1Outlet.text = "0"
            
        }
        
        if let two = data["two"] as? Int {
            
            label2Outlet.text = String(two)
            
        } else {
            
            label2Outlet.text = "0"
            
        }
        
        if let three = data["three"] as? Int {
            
            label3Outlet.text = String(three)
            
        } else {
            
            label3Outlet.text = "0"
            
        }
        
        if let four = data["four"] as? Int {
            
            label4Outlet.text = String(four)
            
        } else {
            
            label4Outlet.text = "0"
            
        }
        
        if let five = data["five"] as? Int {
            
            label5Outlet.text = String(five)
            
        } else {
            
            label5Outlet.text = "0"
            
        }
    }
    
    
    
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}



