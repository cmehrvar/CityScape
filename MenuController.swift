//
//  MenuController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-30.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SDWebImage
import AWSS3

class MenuController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate {
    
    //Variables
    weak var rootController: MainRootController?
    var profileUID = ""
    
    var tempCaptured: UIImage! = nil
    
    var keyboardShown = false
    
    //Outlets
    @IBOutlet weak var profilePicOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityOutlet: UILabel!
    @IBOutlet weak var worldwideViewOutlet: UIView!
    @IBOutlet weak var settingsViewOutlet: UIView!
    @IBOutlet weak var currentStatusTextViewOutlet: UITextView!
    @IBOutlet weak var charactersOutlet: UILabel!
    @IBOutlet weak var cityRankOutlet: UILabel!
    @IBOutlet weak var dismissKeyboardViewOutlet: UIView!
    
    
    @IBAction func leaderboard(sender: AnyObject) {
        
        rootController?.toggleMenu({ (bool) in
            
            self.rootController?.toggleLeaderboard({ (bool) in
                
                print("leaderboard toggled")
                
            })
            
        })
        
        
        
    }
    
    
    //Functions
    func setMenu(){
        
        if let status = rootController?.selfData["currentStatus"] as? String {
            
            currentStatusTextViewOutlet.text = status
            charactersOutlet.text = "\(status.characters.count)/30 Characters"

        } else {
            
            currentStatusTextViewOutlet.text = nil
            charactersOutlet.text = "0/30 Characters"
            
        }
        
        
        if let profilePicture = rootController?.selfData["profilePicture"] as? String, profileURL = NSURL(string: profilePicture) {
            
            if profileUID == "" {
                profileUID = profilePicture
                profilePicOutlet.sd_setImageWithURL(profileURL, placeholderImage: nil)
            } else if profileUID != profilePicture {
                profileUID = profilePicture
                profilePicOutlet.sd_setImageWithURL(profileURL, placeholderImage: tempCaptured)
                
            }
        }
        
        if let firstName = rootController?.selfData["firstName"] as? String {
            
            nameOutlet.text = firstName
            
        }
        
        if let city = rootController?.selfData["city"] as? String {
            
            var fullLocation = city
            
            if let state = rootController?.selfData["state"] as? String {
                fullLocation += ", " + state
            }
            
            cityOutlet.text = fullLocation
            
        } else if let state = rootController?.selfData["state"] as? String {
            
            cityOutlet.text = state
            
        }
        
        if let rank = rootController?.selfData["cityRank"] as? Int {
            
            cityRankOutlet.text = "#\(rank)"
            
        }
    }
    
    
    //ImagePicker Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        tempCaptured = image
        profilePicOutlet.image = image
        
        dismissViewControllerAnimated(true) {
            
            self.imageUploadRequest(image) { (url, uploadRequest) in
                
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                
                
                transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
                    
                    if task.error == nil {
                        
                        print("successful image upload")
                        let ref = FIRDatabase.database().reference()
                        
                        if let uid = FIRAuth.auth()?.currentUser?.uid {
                            ref.child("users").child(uid).updateChildValues(["profilePicture": url])
                        }
                        
                    } else {
                        print("error uploading: \(task.error)")
                        
                        let alertController = UIAlertController(title: "Sorry", message: "Error uploading profile picture, please try again later", preferredStyle:  UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                    }
                    return nil
                }
            }
        }
    }
    
    func imageUploadRequest(image: UIImage, completion: (url: String, uploadRequest: AWSS3TransferManagerUploadRequest) -> ()) {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        
        //SEGMENTATION BUG, IF FAULT 11 - COMMENT OUT AND REWRITE
        dispatch_async(dispatch_get_main_queue()) {
            imageData?.writeToFile(filePath, atomically: true)
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest.body = fileURL
            uploadRequest.key = fileName
            uploadRequest.bucket = "cityscapebucket"
            
            var imageUrl = ""
            
            if let key = uploadRequest.key {
                imageUrl = "https://s3.amazonaws.com/cityscapebucket/" + key
                
            }
            
            completion(url: imageUrl, uploadRequest: uploadRequest)
        }
    }
    
    
    func addUploadStuff(){
        
        let error = NSErrorPointer.init(nilLiteral: ())
        
        do{
            try NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating upload directory failed. Error: \(error)")
        }
    }
    
    func dismissKeyboard(){
        
        self.view.endEditing(true)
        
    }
    
    
    func addGestureRecognizers(){
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(closeMenu))
        leftSwipeGestureRecognizer.direction = .Left
        leftSwipeGestureRecognizer.delegate = self
        
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.delegate = self
        self.dismissKeyboardViewOutlet.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func closeMenu(){
        
        rootController?.toggleMenu({ (bool) in
            
            print("menu toggled")
            
        })
    }
    
    
    //TextView Delegates
    func textViewDidChange(textView: UITextView) {
        
        let textCount = textView.text.characters.count
        charactersOutlet.text = "\(textCount)/30 Characters"
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            textView.resignFirstResponder()
            return false
            
        }
        
        return textView.text.characters.count + (text.characters.count - range.length) <= 30
    }
    
    
    
    
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("users").child(selfUID)
            ref.child("currentStatus").setValue(textView.text)
            
        }
    }
    
    
    
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
    
    
    
    @IBAction func goToProfile(sender: AnyObject) {
        
        print("go to profile")
        
        rootController?.profileRevealed = true
        
        rootController?.toggleMenu({ (bool) in
            
            print("menu toggled")
            
            self.rootController?.toggleHome({ (bool) in
                
                if let uid = FIRAuth.auth()?.currentUser?.uid {
                    
                    self.rootController?.toggleProfile(uid, selfProfile: true, completion: { (bool) in
                        
                        print("self profile toggled")
                        
                    })
                }
            })
        })
    }
    
    @IBAction func logOut(sender: AnyObject) {
        
        var selfUID = ""
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            selfUID = uid
            
        }
        
        FBSDKLoginManager().logOut()
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
        }
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("initial") as! LogInController
        
        presentViewController(vc, animated: true) {
            
            let ref = FIRDatabase.database().reference().child("users").child(selfUID)
            ref.updateChildValues(["online" : false])
            
        }
    }
    
    func keyboardDidShow(){
        
        self.dismissKeyboardViewOutlet.alpha = 1
        keyboardShown = true
        
        
    }
    
    func keyboardDidHide(){
        
        self.dismissKeyboardViewOutlet.alpha = 0
        keyboardShown = false
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        let height = self.view.bounds.height
        let viewHeight = (height/2) - 62.5
        let cornerRadius = round((((viewHeight * 0.55)/2)))
        
        print("Corner Radius: \(cornerRadius)")
        print("Profile Picture Height: \(profilePicOutlet.bounds.height)")
        
        profilePicOutlet.layer.cornerRadius = cornerRadius - 5
        profilePicOutlet.clipsToBounds = true
        
        charactersOutlet.text = "\(currentStatusTextViewOutlet.text.characters.count)/30 Characters"
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .AlignCenters
        
        worldwideViewOutlet.layer.cornerRadius = 12
        settingsViewOutlet.layer.cornerRadius = 12
        
        currentStatusTextViewOutlet.layer.cornerRadius = 8
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidHide), name: UIKeyboardWillHideNotification, object: nil)
        
        addGestureRecognizers()
        addUploadStuff()
        
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
