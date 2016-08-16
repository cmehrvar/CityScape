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
import SDWebImage
import Firebase
import FirebaseAuth
import FirebaseDatabase


class SignUpController: UIViewController, UITextFieldDelegate /*, FBSDKLoginButtonDelegate */{
    
    /*
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
        
        checkPasswordValid(passwordOutlet)
    
        if passwordValid {
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("createProfile") as! ProfileSignUpController
            
            vc.dontFillFormFromFacebook = true
            vc.email = self.emailOutlet.text
            vc.mobileNumberVar = self.mobileOutlet.text
            vc.password = self.passwordOutlet.text
            
            vc.mobileValid = true
            
            self.navigationController?.showViewController(vc, sender: self)
            
           
            
        } else {
            
            let alertController = UIAlertController(title: "Sorry", message: "Password must be minimum 6 characters", preferredStyle:  UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                
                self.passwordOutlet.becomeFirstResponder()
                
                
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            passwordValid = false

            
            
        }

        print("next button hit")
    }
    
    
    
    
    //Functions
    func checkEmailValid(textField: UITextField) {

        if let emailToCheck = textField.text {
            
            if isValidEmail(emailToCheck) {
                
                //IF IS VALID EMAIL, CHECK TO SEE IF TAKEN, ELSE GOOD EMAIL
                
                checkIfTaken("takenEmails", credential: emailToCheck, completion: { (taken) in
                    
                    if taken {
                        
                        self.emailChecker.image = UIImage(named: "RedX")
                        
                        let alertController = UIAlertController(title: "Whoops", message: "Email is already taken", preferredStyle:  UIAlertControllerStyle.Alert)
                        
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                            
                            self.emailOutlet.becomeFirstResponder()
                            
                            
                        }))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        self.emailValid = false

                    } else {
                        
                        self.emailChecker.image = UIImage(named: "Checkmark")
                        
                        self.emailValid = true
                        
                    }
                })
                
                
            } else {
                
                emailChecker.image = UIImage(named: "RedX")
                
                let alertController = UIAlertController(title: "Hey", message: "Please Enter a Valid Email", preferredStyle:  UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                    
                    self.emailOutlet.becomeFirstResponder()
                    
                    
                }))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                self.emailValid = false
                
                print("Bad Email")
                
            }
        }
    }
    func isValidEmail(testStr: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
        
    }
    func checkPasswordValid(textField: UITextField) {
        
        if textField.text == "" {
            
            passwordValid = false
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
     
    func checkIfTaken(key: String, credential: String, completion: (taken: Bool) -> ()) {
        
        var taken = false
        
        let ref = FIRDatabase.database().reference()
        
        ref.child(key).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let values = snapshot.value {
                
                for (_, value) in values as! [NSObject : String] {
                    
                    if credential == value {
                        
                        taken = true
                        
                    }
                }
            }
            
            completion(taken: taken)
            print("is taken: " + String(taken))
            
        })
        
    }
    func checkNumberValid(textField: UITextField) {

        if let numberToCheck = textField.text {
            
            if textField.text == "" {
                
                mobileValid = false
                return
                
            }
            
            if numberToCheck.characters.count < 14 {
                
                mobileChecker.image = UIImage(named: "RedX")
                
                let alertController = UIAlertController(title: "Hey", message: "Please enter a valid number", preferredStyle:  UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                    
                    self.mobileOutlet.becomeFirstResponder()
                    
                    
                }))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                mobileValid = false
                
                print("bad number")
                
            } else {
                
                checkIfTaken("takenNumbers", credential: numberToCheck, completion: { (taken) in
                    
                    if taken {
                        
                        self.mobileChecker.image = UIImage(named: "RedX")
                        
                        let alertController = UIAlertController(title: "Sorry", message: "Number already taken", preferredStyle:  UIAlertControllerStyle.Alert)
                        
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                            
                            self.mobileOutlet.becomeFirstResponder()
                            
                            
                        }))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        self.mobileValid = false
                        
                        
                        
                    } else {
                        
                        self.mobileChecker.image = UIImage(named: "Checkmark")
                        
                        self.mobileValid = true
                        
                        
                    }
                })
            }
        }
        
    }

    
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error == nil {
            
            print("good sign in")
            
            if FBSDKAccessToken.currentAccessToken() != nil {
                
                //CHECK TO SEE IF EMAIL TAKEN. IF SO, USER MUST HAVE AN ACCOUNT. SKIP NEXT STEP, LOG USER IN WITH FIREBASE AND GO STRAIGHT TO MAIN APP.
                
                let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name"], tokenString: result.token.tokenString, version: nil, HTTPMethod: "GET")
                
                req.startWithCompletionHandler({ (connection, result, error) -> Void in
                    
                    if error == nil {
                        
                        if let email = result["email"] {
                            
                            self.checkIfTaken("takenEmails", credential: email as! String, completion: { (taken) in
                                
                                if taken {
                                    
                                    print("facebook account already signed up!")
                                    
                                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
                                    vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                                    self.presentViewController(vc, animated: true, completion: nil)
                                    
                                    
                                } else {
                                    
                                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("createProfile") as! ProfileSignUpController
                                    vc.result = result as! [String:String]
                                    self.navigationController?.showViewController(vc, sender: self)
                                    
                                }
                            })
                        } else {
                            print("error")
                        }
                        
                        
                    } else {
                        print(error)
                    }
                    
                })
                
            } else {
                
                FBSDKLoginManager().logOut()
                
            }

        } else {
            
            print("bad sign in")
            print(error)
            
        }
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        
        
        
    }
    
    
    func loadGif() {
        
        if let filePath = NSBundle.mainBundle().pathForResource("background", ofType: "gif"), gifData = NSData(contentsOfFile: filePath) {
            
            let image: FLAnimatedImage = FLAnimatedImage.init(GIFData: gifData)
            gifImage.animatedImage = image
            
        }
    }
    
    //Text Field Calls
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == mobileOutlet {
            
       checkNumberValid(textField)
            
         }
        
        if textField == passwordOutlet {
            
            checkPasswordValid(textField)
        
        }
        
        if textField == emailOutlet {
            
            checkEmailValid(textField)
        }
        
        if mobileValid && emailValid && passwordValid {
            
            nextButtonOutlet.enabled = true
            
        } else {
            
            nextButtonOutlet.enabled = false
            
        }
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        
        if mobileValid && passwordValid && emailValid {
            
            nextButtonOutlet.enabled = true
            
        } else {
            
            nextButtonOutlet.enabled = false

        }
        
        
        
        if textField == passwordOutlet {
            
            if mobileValid && emailValid {
                
                if textField.text?.characters.count >= 5 {
                    passwordValid = true
                    passwordChecker.image = UIImage(named: "Checkmark")
                    nextButtonOutlet.enabled = true
                } else {
                    nextButtonOutlet.enabled = false
                    passwordValid = false
                    passwordChecker.image = nil
                }
            }
            
        }
        
        
        if textField == emailOutlet {
            
            if let emailToCheck = textField.text {
                
                if isValidEmail(emailToCheck) {
                    
                    self.emailChecker.image = UIImage(named: "Checkmark")
                    
                    emailValid = true
                    
                    if passwordValid == true && mobileValid == true {
                        
                        nextButtonOutlet.enabled = true

                    }
                    
                    print("good email")
                    
                } else {
                    
                    emailChecker.image = UIImage(named: "RedX")
                    
                    emailValid = false
                    
                    print("Bad Email")
                    
                }
            }

        }
        
        
        
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
                mobileValid = true
                
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

            mobileValid = false
            return false
        }
        else
        {
            return true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
        
    }
    
    func textFieldDelegates() {
        
        facebookLogInOutlet.delegate = self
        facebookLogInOutlet.readPermissions = ["email"]
        emailOutlet.delegate = self
        mobileOutlet.delegate = self
        passwordOutlet.delegate = self
        
    }
    
    
    //Keyboard Calls
    func addDismissKeyboard() {
        
        let dismissKeyboardVar: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboardVar)
        
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
    
   */
}

