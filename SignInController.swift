//
//  SignInController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-23.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import FLAnimatedImage
import FBSDKLoginKit
import Firebase
import FirebaseAuth

class SignInController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var doneOutlet: UIBarButtonItem!
    @IBOutlet weak var gifImage: FLAnimatedImageView!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var emailChecker: UIImageView!
    @IBOutlet weak var passwordChecker: UIImageView!
    
    
    
    //Actions
    @IBAction func cancelAction(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        
        
        guard let email = emailOutlet.text, password = passwordOutlet.text else {return}
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            
            if error == nil {
                
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
                vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                self.presentViewController(vc, animated: true, completion: nil)
                
            } else {
                print(error)
            }
        })
    }
    
    
    @IBAction func forgotPassword(sender: AnyObject) {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("forgotPassword") as! ForgotPasswordController
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error == nil {
            
            if FBSDKAccessToken.currentAccessToken() != nil {
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    
                    if error == nil {
                        
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
                        vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                        self.presentViewController(vc, animated: true, completion: nil)
                        
                    } else {
                        print(error)
                    }
                })
                
                
            } else {
                
                FBSDKLoginManager().logOut()
                
            }

        } else {
            print(error)
        }
        
        
        
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    
    
    
    //Functions
    func loadGif() {
        
        guard let filePath: String = NSBundle.mainBundle().pathForResource("background", ofType: "gif") else {return}
        let gifData: NSData = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
        let image: FLAnimatedImage = FLAnimatedImage.init(GIFData: gifData)
        gifImage.animatedImage = image
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        var passwordValid = false
        var emailValid = false
        
        if textField == passwordOutlet {
            
            if textField.text == "" {
                
                return
                
            }
            
            
            if let passwordToCheck = textField.text {
                
                if passwordToCheck.characters.count < 6 {
                    
                    passwordChecker.image = UIImage(named: "RedX")
                    
                    let alertController = UIAlertController(title: "Hey", message: "Password must be at least 6 characters", preferredStyle:  UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                        
                        self.passwordOutlet.becomeFirstResponder()
                        
                        
                    }))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    passwordValid = false
                    
                } else {
                    
                    passwordValid = true
                    
                    passwordChecker.image = UIImage(named: "Checkmark")
                    
                }
            }
        }
        
        if textField == emailOutlet {
            
            if textField.text == "" {
                
                return
                
            }
            
            
            if let emailToCheck = textField.text {
                
                if isValidEmail(emailToCheck) {
                    
                    self.emailChecker.image = UIImage(named: "Checkmark")
                    
                    emailValid = true
                    
                } else {
                    
                    emailChecker.image = UIImage(named: "RedX")
                    
                    let alertController = UIAlertController(title: "Hey", message: "Please Enter a Valid Email", preferredStyle:  UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                        
                        self.emailOutlet.becomeFirstResponder()
                        
                        
                    }))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    emailValid = false
                    
                    print("Bad Email")
                    
                }
            }
            
        }
        
        if emailValid && passwordValid {
            
            doneOutlet.enabled = true
            
        } else {
            
            doneOutlet.enabled = false
            
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
        
    }
    
    func isValidEmail(testStr: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
        
    }
    
    //Launch Calls
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookButton.delegate = self
        emailOutlet.delegate = self
        passwordOutlet.delegate = self
        doneOutlet.enabled = false
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {

        loadGif()
        
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
