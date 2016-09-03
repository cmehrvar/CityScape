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

class MenuController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    //Variables
    weak var rootController: MainRootController?
    var profileUID = ""
    
    var tempCaptured: UIImage! = nil
    
    
    //Outlets
    @IBOutlet weak var profilePicOutlet: MenuProfileView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityOutlet: UILabel!
    
    
    //Functions
    func setMenu(){
        
        if let profilePicture = rootController?.selfData["profilePicture"] as? String, profileURL = NSURL(string: profilePicture) {
            
            if profileUID == "" {
                profileUID = profilePicture
                profilePicOutlet.sd_setImageWithURL(profileURL, placeholderImage: nil)
            } else if profileUID != profilePicture {
                profileUID = profilePicture
                profilePicOutlet.sd_setImageWithURL(profileURL, placeholderImage: tempCaptured)
                
            }
        }
        
        if let firstName = rootController?.selfData["firstName"] as? String, lastName = rootController?.selfData["lastName"] as? String {
            
            let name = firstName + " " + lastName
            nameOutlet.text = name
            
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
    
    
    func addGestureRecognizers(){
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(closeMenu))
        leftSwipeGestureRecognizer.direction = .Left
        leftSwipeGestureRecognizer.delegate = self
        
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        
        
    }
    
    func closeMenu(){
        
        rootController?.toggleMenu({ (bool) in
            
            print("menu toggled")
            
        })
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
                
                if let uid = FIRAuth.auth()?.currentUser?.uid, profile = self.rootController?.selfData["profilePicture"] as? String {
                    
                    self.rootController?.toggleProfile(uid, selfProfile: true, profilePic: profile, completion: { (bool) in
                        
                        print("self profile toggled")
                        
                    })
                }
            })
        })
    }

    @IBAction func logOut(sender: AnyObject) {
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            ref.updateChildValues(["online" : false])

        }

        FBSDKLoginManager().logOut()
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
        }
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("initial") as! LogInController
        presentViewController(vc, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
