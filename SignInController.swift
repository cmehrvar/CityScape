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
    
    
    //Global Variables
    var passwordValid = false
    var emailValid = false
    
    
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
        
        
        if checkPasswordValid(passwordOutlet) {
            
            guard let email = emailOutlet.text, password = passwordOutlet.text else {return}
            
            FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
                
                if error == nil {
                    
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
                    vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                    
                    self.presentViewController(vc, animated: true, completion: {
                        
                        vc.homeController?.getFirebaseData()
                        
                    })
                    
                } else {
                    print(error)
                    
                    if error?.code == 17011 {
                        
                        let alertController = UIAlertController(title: "Sorry", message: "No user with this e-mail", preferredStyle:  UIAlertControllerStyle.Alert)
                        
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: {
                            
                            self.emailValid = false
                            self.emailChecker.image = UIImage(named: "RedX")
                            self.passwordChecker.image = UIImage(named: "RedX")
                            
                        })
                        
                        
                    } else if error?.code == 17009 {
                        
                        let alertController = UIAlertController(title: "Sorry", message: "Incorrect password", preferredStyle:  UIAlertControllerStyle.Alert)
                        
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: {
                            
                            self.emailValid = true
                            self.emailChecker.image = UIImage(named: "Checkmark")
                            self.passwordChecker.image = UIImage(named: "RedX")
                            
                        })
                        
                    } else {
                        
                        let alertController = UIAlertController(title: "Sorry", message: "Incorrect e-mail or password", preferredStyle:  UIAlertControllerStyle.Alert)
                        
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: {
                            
                            self.emailChecker.image = nil
                            self.passwordChecker.image = UIImage(named: "RedX")
                            
                        })
                        
                    }
                }
            })
            
            
        } else {
            
            let alertController = UIAlertController(title: "Sorry", message: "Password must be minimum 6 characters", preferredStyle:  UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                
                self.passwordOutlet.becomeFirstResponder()
                
                
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            passwordChecker.image = UIImage(named: "RedX")
            passwordValid = false
            
        }

    }
    
    
    @IBAction func forgotPassword(sender: AnyObject) {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("forgotPassword") as! ForgotPasswordController
        
        if emailValid {
            
            if let actualEmail = emailOutlet.text {
                
                vc.emailValid = true
                vc.email = actualEmail
                
            }
        }
        
        
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
                        
                        self.presentViewController(vc, animated: true, completion: {
                            
                            vc.homeController?.getFirebaseData()
                            
                        })
                        
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
    
    
    func checkEmailValid(textField: UITextField) -> Bool {
        
        var funcEmailValid = false
        
        if let emailToCheck = textField.text {
            
            if isValidEmail(emailToCheck) {
                
                //IF IS VALID EMAIL, CHECK TO SEE IF TAKEN, ELSE GOOD EMAIL
                
                self.emailChecker.image = UIImage(named: "Checkmark")
                
                funcEmailValid = true
                
                
                
                
                
            } else {
                
                emailChecker.image = UIImage(named: "RedX")
                
                let alertController = UIAlertController(title: "Hey", message: "Please Enter a Valid Email", preferredStyle:  UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                    
                    self.emailOutlet.becomeFirstResponder()
                    
                    
                }))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                funcEmailValid = false
                
                print("Bad Email")
                
            }
        }
        
        return funcEmailValid
    }
    func isValidEmail(testStr: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
        
    }
    func checkPasswordValid(textField: UITextField) -> Bool {
        
        var funcPasswordValid = false
        
        if textField.text == "" {
            
            return false
            
        }
        
        
        if let passwordToCheck = textField.text {
            
            if passwordToCheck.characters.count < 6 {
                
                passwordChecker.image = UIImage(named: "RedX")
                
                let alertController = UIAlertController(title: "Hey", message: "Password must be at least 6 characters", preferredStyle:  UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                    
                    self.passwordOutlet.becomeFirstResponder()
                    
                    
                }))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                funcPasswordValid = false
                
            } else {
                
                funcPasswordValid = true
                
            }
        }
        
        return funcPasswordValid
        
    }
    
    
    
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        
        
        if textField == passwordOutlet {
            
            passwordValid = checkPasswordValid(textField)
            
        }
        
        if textField == emailOutlet {
            
            emailValid = checkEmailValid(textField)
            
        }
        
        if emailValid && passwordValid {
            
            doneOutlet.enabled = true
            
        } else {
            
            doneOutlet.enabled = false
            
        }
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == emailOutlet {
            
            if let emailToCheck = textField.text {
                
                if isValidEmail(emailToCheck) {
                    
                    self.emailChecker.image = UIImage(named: "Checkmark")
                    
                    emailValid = true
                    
                } else {
                    
                    emailChecker.image = UIImage(named: "RedX")
                    
                    emailValid = false
                    
                    print("Bad Email")
                    
                }
            }
            
        }
        
        if textField == passwordOutlet {
            
            if emailValid {
                
                if textField.text?.characters.count >= 5 {
                    passwordValid = true
                    doneOutlet.enabled = true
                } else {
                    doneOutlet.enabled = false
                    passwordValid = false
                    passwordChecker.image = nil
                }
            }
            
        }
        
        return true
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
        
    }
    
    
    func addDismissKeyboard() {
        
        let dismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismissKeyboard)
        
    }
    func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    func handleOutlets() {
        
        facebookButton.delegate = self
        emailOutlet.delegate = self
        passwordOutlet.delegate = self
        doneOutlet.enabled = false
        
        
    }
    
    
    //Launch Calls
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleOutlets()
        addDismissKeyboard()
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
