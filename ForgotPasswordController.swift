//
//  ForgotPasswordController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-23.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import FLAnimatedImage
import Firebase
import FirebaseAuth

class ForgotPasswordController: UIViewController, UITextFieldDelegate {
    
    //GlobalVariables
    var emailValid = false
    var email = String()
    
    
    //Outlets
    @IBOutlet weak var gifImage: FLAnimatedImageView!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var resetPasswordOutlet: UIButton!
    @IBOutlet weak var emailChecker: UIImageView!
    
    
    
    
    //Actions
    @IBAction func resetPassword(_ sender: AnyObject) {
        
        if let email = emailOutlet.text {
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
                
                if error == nil {
                    
                    let alertController = UIAlertController(title: "Password Reset", message: "A password reset email has been sent", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "initial") as! LogInController
                        self.present(vc, animated: true, completion: nil)
                        
                        
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Sorry", message: error?.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)

                    
                }
            })
        }
    }
    
    
    //Functions
    func loadGif() {
        
        guard let filePath: String = Bundle.main.path(forResource: "background", ofType: "gif") else {return}
        
    
        if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
        
            let image: FLAnimatedImage = FLAnimatedImage.init(gifData: data)
            gifImage.animatedImage = image
            
        
        }
    }
    
    func isValidEmail(_ testStr: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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
        
        if emailValid {
            
            resetPasswordOutlet.isEnabled = true
            
        } else {
            
            resetPasswordOutlet.isEnabled = false
            
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
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
                    
                    let alertController = UIAlertController(title: "Hey", message: "Please Enter a Valid Email", preferredStyle:  UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) -> Void in
                        
                        self.emailOutlet.becomeFirstResponder()
                        
                        
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    emailValid = false
                    
                    print("Bad Email")
                    
                }
            }
            
        }
        
        if emailValid {
            
            resetPasswordOutlet.isEnabled = true
            
        } else {
            
            resetPasswordOutlet.isEnabled = false
            
        }
        
    }
    
    func addDismissKeyboard() {
        
        let dismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ForgotPasswordController.dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboard)
        
    }
    
    func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    func handleOutlets(){
        
        emailOutlet.text = email
        emailOutlet.delegate = self
        resetPasswordOutlet.isEnabled = emailValid
        resetPasswordOutlet.setTitleColor(UIColor.blue, for: UIControlState())
        resetPasswordOutlet.setTitleColor(UIColor.gray, for: .disabled)
        
    }
    
    
    //Launch Calls
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDismissKeyboard()
        handleOutlets()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
