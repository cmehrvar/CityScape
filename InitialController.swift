//
//  InitialController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-30.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class InitialController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            
            if user != nil {
                
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
                
                self.presentViewController(vc, animated: true, completion: {
                    
                    vc.homeController?.getFirebaseData()
                    
                })
                
                
            } else {
                
                FBSDKLoginManager().logOut()
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("initial") as! LogInController
                self.presentViewController(vc, animated: true, completion: nil)

            }
        })

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
