//
//  ViewController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-15.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FLAnimatedImage
import Firebase
import FirebaseAuth


class SignUpController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    
    //Outlets
    @IBOutlet weak var gifImage: FLAnimatedImageView!
    @IBOutlet weak var nextButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var mobileOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var emailChecker: UIImageView!
    @IBOutlet weak var mobileChecker: UIImageView!
    @IBOutlet weak var passwordChecker: UIImageView!
    @IBOutlet weak var facebookLogInOutlet: FBSDKLoginButton!

    var mobileValid: Bool = false
    var emailValid: Bool = false
    var passwordValid: Bool = false
    
    
    
    
    //Actions
    @IBAction func Cancel(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    
    
    @IBAction func NextButton(sender: AnyObject) {
        
        if let actualEmail = emailOutlet.text, actualPassword = passwordOutlet.text {
            
            FIRAuth.auth()?.createUserWithEmail(actualEmail, password: actualPassword, completion: { (user, error) -> Void in
                
                if error == nil {
                    
                    print("good sign up")
                    
                    if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileSignUp") as? UINavigationController {
                        
                        vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                        
                        self.presentViewController(vc, animated: true, completion: { () -> Void in
                            print("View Controller Presented")
                        })
                    }
                    
                } else {
                    
                    print("bad sign up")
                    
                }
            })
        }
        
        print("next button hit")
        
    }
    
    
    
    
    //Functions
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        
        if error == nil {
            
            print("good sign in")
            
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) -> Void in
                
                if error == nil {
                    
                    if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileSignUp") as? UINavigationController {
                        
                        vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                        
                        self.presentViewController(vc, animated: true, completion: { () -> Void in
                            print("View Controller Presented")
                        })
                    }
                    
                    print("good sign up")
                    
                } else {
                    
                    print("bad sign up")
                    
                }

            })
            
        } else {
            
            print("bad sign in")
            
        }  
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        
        
        
    }
    
    
    
    func isValidEmail(testStr: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
        
    }
    
    
    func loadGif() {
        
        guard let filePath: String = NSBundle.mainBundle().pathForResource("background", ofType: "gif") else {return}
        let gifData: NSData = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
        let image: FLAnimatedImage = FLAnimatedImage.init(GIFData: gifData)
        gifImage.animatedImage = image
        
    }
    
    
    //Text Field Calls
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == mobileOutlet {
            
            if let numberToCheck = textField.text {
                
                if numberToCheck.characters.count == 14 {
                    
                    mobileChecker.image = UIImage(named: "Checkmark")
                    
                    mobileValid = true
                    
                    print("good number")
                    
                } else {
                    
                    mobileChecker.image = UIImage(named: "RedX")
                    
                    let alertController = UIAlertController(title: "Hey", message: "Please enter a valid number", preferredStyle:  UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                        
                        self.mobileOutlet.becomeFirstResponder()
                        
                        
                    }))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    mobileValid = false
                    
                    print("bad number")
                    
                }
            }
        }
        
        
        if textField == passwordOutlet {
            
            if let passwordToCheck = textField.text {
                
                if passwordToCheck.characters.count < 5 {
                    
                    passwordChecker.image = UIImage(named: "RedX")
                    
                    let alertController = UIAlertController(title: "Hey", message: "Password must be at least 5 characters", preferredStyle:  UIAlertControllerStyle.Alert)
                    
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
                    
                    emailChecker.image = UIImage(named: "Checkmark")
                    
                    emailValid = true
                    
                    print("Good Email")
                    
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
        
        if mobileValid && emailValid && passwordValid {
            
            nextButtonOutlet.enabled = true
            
        } else {
            
            nextButtonOutlet.enabled = false
            
        }
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if (textField == mobileOutlet)
        {
            
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString = components.joinWithSeparator("") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                mobileChecker.image = UIImage(named: "Checkmark")
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            
            print(false)
            
            return false
        }
        else
        {
            
            print(true)
            return true
        }
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField == emailOutlet {
            print("Email Began Editting")
        }
    }
    
    func textFieldDelegates() {
        
        facebookLogInOutlet.delegate = self
        emailOutlet.delegate = self
        mobileOutlet.delegate = self
        passwordOutlet.delegate = self
        
    }

    
    //Keyboard Calls
    func addDismissKeyboard() {
        
        let dismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismissKeyboard)
        
    }
    
    func dismissKeyboard() {
        
        view.endEditing(true)
        
    }

    
    
    //Launch Calls
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButtonOutlet.enabled = false
        
        
        textFieldDelegates()
        addDismissKeyboard()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        loadGif()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

