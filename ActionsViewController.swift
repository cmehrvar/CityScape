//
//  ActionsViewController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-02.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ActionsViewController: UIViewController {
    
    weak var rootController: MainRootController?
    
    
    //Actions
    @IBAction func home(sender: AnyObject) {
        
        rootController?.toggleHome({ (bool) in
            
            print("home toggled")
            
            self.rootController?.toggleNearby({ (bool) in
                
                print("nearby toggled")
                
            })
        })
    }
    
    
    @IBAction func search(sender: AnyObject) {
        
        print("search")
        
    }
    
    
    
    @IBAction func camera(sender: AnyObject) {
        
        print("camera")
        
    }
    
    
    
    @IBAction func globe(sender: AnyObject) {
        
        
        print("globe")
        
    }
    
    
    @IBAction func profile(sender: AnyObject) {
        
        rootController?.profileRevealed = true
        
        rootController?.toggleHome({ (bool) in
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid, selfProfile = self.rootController?.selfData["profilePicture"] as? String {
                
                self.rootController?.toggleProfile(selfUID, selfProfile: true, profilePic: selfProfile, completion: { (bool) in
                    
                    print("profile toggled")
                    
                })
            }
        })

        print("profile")
        
    }
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
