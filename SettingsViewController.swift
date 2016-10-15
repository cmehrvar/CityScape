//
//  SettingsViewController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-10-15.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import NYAlertViewController
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class SettingsViewController: UIViewController {
    
    weak var rootController: MainRootController?
    
    @IBOutlet weak var maleButtonView: NavButtonView!
    @IBOutlet weak var maleButtonOutlet: UIButton!
    @IBOutlet weak var femaleButtonView: NavButtonView!
    @IBOutlet weak var femaleButtonOutlet: UIButton!

    @IBOutlet weak var intoMenView: NavButtonView!
    @IBOutlet weak var intoMenOutlet: UIButton!
    @IBOutlet weak var intoWomenView: NavButtonView!
    @IBOutlet weak var intoWomenOutlet: UIButton!
    @IBOutlet weak var intoBothView: NavButtonView!
    @IBOutlet weak var intoBothOutlet: UIButton!
    
    
    @IBOutlet weak var logOutViewOutlet: UIView!
    
    @IBAction func deleteAccount(sender: AnyObject) {
        
        let alertController = NYAlertViewController()
        
        alertController.title = "Delete Account?"
        alertController.titleColor = UIColor.redColor()
        alertController.message = "This will delete your account along with all its contents. You will lose all made connections and no longer appear visible. Warning, your past account history will not be retrievable. You can always sign back in with Facebook, creating a new account."
        alertController.messageColor = UIColor.darkGrayColor()
        alertController.cancelButtonColor = UIColor.lightGrayColor()
        alertController.cancelButtonTitleColor = UIColor.whiteColor()
        alertController.buttonColor = UIColor.redColor()
        alertController.buttonTitleColor = UIColor.whiteColor()
        
        alertController.addAction(NYAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        alertController.addAction(NYAlertAction(title: "Delete", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: {
                
                if let currentUser = FIRAuth.auth()?.currentUser {
                    
                    let myUID = currentUser.uid
                    
                    let myRef = FIRDatabase.database().reference().child("users").child(myUID)
                    
                    myRef.child("")
                    
                    
                    currentUser.deleteWithCompletion({ (error) in
                        
                        if error == nil {
                            
                            
                            
                        } else {
                            
                            print(error)
                            
                        }
                    })
                }
            })
        }))
        
        self.presentViewController(alertController, animated: true) { 
            
            print("alert controller presented")
            
        }
    }
    
    @IBAction func logOut(sender: AnyObject) {

        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            FBSDKLoginManager().logOut()
            
            var scopeError: ErrorType?
            
            do {
                try FIRAuth.auth()?.signOut()
            } catch let error {
                
                scopeError = error
                
                print(error)
            }
            
            if scopeError == nil {
                
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("initial") as! LogInController
                
                presentViewController(vc, animated: true) {
                    
                    FIRDatabase.database().reference().child("users").child(uid).child("online").setValue(false)
                    
                }
            }
        }
    }
    
    @IBAction func contactUs(sender: AnyObject) {
        
        rootController?.toggleContactUs({ (bool) in
            
            print("contact us toggled")
            
        })
        
        
    }
    
    @IBAction func back(sender: AnyObject) {
        
        rootController?.toggleSettings({ (bool) in
            
            print("settings closed")
            
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logOutViewOutlet.layer.cornerRadius = 12

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
