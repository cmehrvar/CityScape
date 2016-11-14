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
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in

            
            if user != nil && FBSDKAccessToken.current() != nil {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainRootController") as! MainRootController
                
                self.present(vc, animated: true, completion: {
                    
                    vc.setStage()
                    
                    vc.loadSelfData({ (value) in
                        
                        print("self data loaded")
                        
                    })
                    
                    vc.toggleNearby({ (bool) in
                        
                        print("nearby toggled")
                        
                    })
                    
                })
                
            } else {
                
                FBSDKLoginManager().logOut()
                
                do {
                    try FIRAuth.auth()?.signOut()
                } catch let error {
                    print(error)
                }
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "initial") as! LogInController
                self.present(vc, animated: true, completion: nil)
                
            }

                
            
            
            
            /*
            if user != nil && FBSDKAccessToken.current() != nil {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainRootController") as! MainRootController
                
                self.present(vc, animated: true, completion: {

                    vc.setStage()
                    
                    vc.loadSelfData({ (value) in
                        
                        print("self data loaded")
                        
                    })
                    
                    vc.toggleNearby({ (bool) in
                        
                        print("nearby toggled")
                        
                    })
                    
                })

            } else {
                
                FBSDKLoginManager().logOut()
                
                do {
                    try FIRAuth.auth()?.signOut()
                } catch let error {
                    print(error)
                }
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "initial") as! LogInController
                self.present(vc, animated: true, completion: nil)
                
            }
 */
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
