//
//  ProfileSignUpController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-22.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import FLAnimatedImage
import DownPicker
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import AWSS3

class ProfileSignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //Global Variables
    var nextButton: UIBarButtonItem!
    let cities = ["Vancouver", "Edmonton", "Toronto", "Montreal", "Halifax", "St. Johns"]
    var result: [String:String]!
    
    var email: String!
    var mobileNumberVar: String!
    var password: String!
    
    var imageUrl: String!
    var uid: String!
    
    var textFieldAlpha: CGFloat!
    var realDownPicker: DownPicker = DownPicker()
    
    var dontFillFormFromFacebook = false
    var didFillFormFromFacebook = false
    
    var firstNameValid = false
    var lastNameValid = false
    var cityValid = false
    var mobileValid = false
    
    
    
    //Outlets
    @IBOutlet weak var gif: FLAnimatedImageView!
    @IBOutlet weak var downPicker: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var mobileField: TextFields!
    @IBOutlet weak var mobileCheckerImage: UIImageView!
    
    
    //Actions
    @IBAction func editProfile(sender: AnyObject) {
        
        let cameraProfile = UIImagePickerController()
        
        cameraProfile.delegate = self
        cameraProfile.allowsEditing = false
        
        let alertController = UIAlertController(title: "Smile!", message: "Take a pic or choose from gallery?", preferredStyle:  UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                cameraProfile.sourceType = UIImagePickerControllerSourceType.Camera
            }
            
            self.presentViewController(cameraProfile, animated: true, completion: nil)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            
            cameraProfile.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.presentViewController(cameraProfile, animated: true, completion: nil)
            
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    
    //ACTION - done
    func done(sender: UIBarButtonItem) {
        
        if dontFillFormFromFacebook {
            
            //Sign up using email
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
                
                if error == nil {
                    
                    if let actualUser = user {
                        
                        if let actualFirstName = self.firstName.text, actualLastName = self.lastName.text, actualCity = self.downPicker.text {
                            
                            let ref = FIRDatabase.database().reference()
                            
                            ref.child("users").child(actualUser.uid).setValue(["mobile":self.mobileNumberVar, "email" : self.email, "firstName":actualFirstName, "lastName":actualLastName, "city":actualCity, "actualScore":0])
                            
                            ref.child("takenEmails").childByAutoId().setValue(self.email)
                            ref.child("takenNumbers").childByAutoId().setValue(self.mobileNumberVar)
                            
                            
                            //AWS PROFILE
                            if let actualProfile = self.profilePicture.image {
                                self.uid = actualUser.uid
                                self.uploadToAWS(actualProfile)
                            }
                        }
                    }
                    
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
            
            //Sign up using facebook
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) -> Void in
                
                if error == nil {
                    
                    if let actualUser = user {
                        
                        if let actualFirstName = self.firstName.text, actualLastName = self.lastName.text, actualCity = self.downPicker.text {
                            
                            let ref = FIRDatabase.database().reference()
                            
                            if let actualEmail = self.result["email"], actualNumber = self.mobileNumber.text {
                                
                                ref.child("users").child(actualUser.uid).setValue(["mobile":actualNumber, "email" : actualEmail, "firstName":actualFirstName, "lastName":actualLastName, "city":actualCity, "totalScore":0])
                                
                                ref.child("takenEmails").childByAutoId().setValue(actualEmail)
                                ref.child("takenNumbers").childByAutoId().setValue(actualNumber)
                                
                                if let email = self.result["email"] {
                                    
                                    user?.updateEmail(email, completion: { (error) in
                                        
                                        if error == nil {
                                            
                                            //email updated
                                            print("email updated")
                                            
                                        } else {
                                            
                                            print(error)
                                            
                                        }
                                        
                                    })
                                    
                                }
                            }
                            
                            //AWS PROFILE
                            if let actualProfile = self.profilePicture.image {
                                self.uid = actualUser.uid
                                self.uploadToAWS(actualProfile)
                            }
                        }
                    }
                    
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
                    vc.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                    
                    self.presentViewController(vc, animated: true, completion: {
                        vc.homeController?.getFirebaseData()
                    })
                    
                    
                } else {
                    
                    print(error)
                    
                }
                
            })
        }
    }
    
    //Functions
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
    
    func uploadToAWS(image: UIImage) {
        
        let uploadRequest = imageUploadRequest(image)
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
            
            if task.error == nil {
                
                print("successful image upload")
                let ref = FIRDatabase.database().reference()
                ref.child("users").child(self.uid).updateChildValues(["profilePicture":self.imageUrl])
                
                
            } else {
                print("error uploading: \(task.error)")
                
                let alertController = UIAlertController(title: "Sorry", message: "Error uploading profile picture, please try again later", preferredStyle:  UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
            return nil
        }
    }
    
    func imageUploadRequest(image: UIImage) -> AWSS3TransferManagerUploadRequest {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        
        imageData?.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = fileURL
        uploadRequest.key = fileName
        uploadRequest.bucket = "cityscapebucket"
        
        if let key = uploadRequest.key {
            imageUrl = "https://s3.amazonaws.com/cityscapebucket/" + key
        }
        
        return uploadRequest
        
    }
    
    func addUploadStuff(){
        
        let error = NSErrorPointer()
        
        
        do{
            try NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating upload directory failed. Error: \(error)")
        }
        
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == firstName {
            
            if firstName != "" {
                firstNameValid = true
            } else {
                firstNameValid = false
            }
            
        }
        
        if textField == lastName {
            
            if lastName != "" {
                lastNameValid = true
            } else {
                lastNameValid = false
            }
        }
        
        if textField == mobileNumber {
            
            if let numberToCheck = textField.text {
                
                if textField.text == "" {
                    
                    return
                    
                }
                
                
                if numberToCheck.characters.count < 14 {
                    
                    mobileCheckerImage.image = UIImage(named: "RedX")
                    
                    let alertController = UIAlertController(title: "Hey", message: "Please enter a valid number", preferredStyle:  UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                        
                        self.mobileCheckerImage.becomeFirstResponder()
                        
                        
                    }))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    mobileValid = false
                    
                    print("bad number")
                    
                } else {
                    
                    checkIfTaken("takenNumbers", credential: numberToCheck, completion: { (taken) in
                        
                        if taken {
                            
                            self.mobileCheckerImage.image = UIImage(named: "RedX")
                            
                            let alertController = UIAlertController(title: "Sorry", message: "Number already taken", preferredStyle:  UIAlertControllerStyle.Alert)
                            
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
                                
                                self.mobileCheckerImage.becomeFirstResponder()
                                
                                
                            }))
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                            
                            self.mobileValid = false
                            
                        } else {
                            
                            self.mobileCheckerImage.image = UIImage(named: "Checkmark")
                            
                            self.mobileValid = true
                            
                        }
                    })
                }
            }
        }
        
        
        if firstNameValid && lastNameValid && cityValid && mobileValid {
            
            nextButton.enabled = true
            
        }
    }
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let temp: UIImage = image
        profilePicture.image = temp
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
        
    }
    
    
    func loadGif() {
        
        guard let filePath: String = NSBundle.mainBundle().pathForResource("background", ofType: "gif") else {return}
        let gifData: NSData = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
        let image: FLAnimatedImage = FLAnimatedImage.init(GIFData: gifData)
        gif.animatedImage = image
        
    }
    
    func handleDownPicker() {
        
        realDownPicker = DownPicker(textField: downPicker, withData: cities)
        realDownPicker.setPlaceholder("Tap to choose your city")
        realDownPicker.shouldDisplayCancelButton = false
        realDownPicker.addTarget(self, action: "downPickerSelected:", forControlEvents: .ValueChanged)
        
    }
    
    func downPickerSelected(sender: DownPicker){
        
        cityValid = true
        
        if cityValid && firstNameValid && lastNameValid && mobileValid {
            
            nextButton.enabled = true
            
        }
    }
    
    func fillFormFromFacebook() {
        
        if result["first_name"] != nil {
            
            firstNameValid = true
            firstName.text = result["first_name"]
            
        }
        
        if result["last_name"] != nil {
            
            lastNameValid = true
            lastName.text = result["last_name"]
            
        }
        
        if result["id"] != nil {
            
            print(result["id"])
            
            if let id = result["id"] {
                
                print(id)
                let profileUrl = "https://graph.facebook.com/" + id + "/picture?type=large"
                profilePicture.sd_setImageWithURL(NSURL(string: profileUrl))
                
            }
            
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if (textField == mobileNumber)
        {
            
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString = components.joinWithSeparator("") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                mobileCheckerImage.image = UIImage(named: "Checkmark")
                
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
            
            return false
        }
        else
        {
            return true
        }
    }
    
    func addDismissKeyboard() {
        
        let dismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismissKeyboard)
        
    }
    
    func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    func addNextButton(){
        
        nextButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "done:")
        self.navigationItem.rightBarButtonItem = nextButton
        nextButton.enabled = false
        
        
    }
    
    func textFieldDelegates() {
        
        firstName.delegate = self
        lastName.delegate = self
        downPicker.delegate = self
        mobileNumber.delegate = self
        
    }
    
    
    //Launch Calls
    override func viewDidLoad() {
        super.viewDidLoad()
        mobileField.alpha = textFieldAlpha
        addNextButton()
        textFieldDelegates()
        addDismissKeyboard()
        addUploadStuff()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if !dontFillFormFromFacebook {
            
            if !didFillFormFromFacebook {
                
                didFillFormFromFacebook = true
                fillFormFromFacebook()
            }
            
        }
        
        
        handleDownPicker()
        loadGif()
        
    }
    
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        
        if parent == nil {
            
            FBSDKLoginManager().logOut()
            
            print("back button hit")
            
        }
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
