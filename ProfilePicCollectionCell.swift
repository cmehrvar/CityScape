//
//  ProfilePicCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-02.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import AWSS3
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ProfilePicCollectionCell: UICollectionViewCell, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var profileController: ProfileController?
    
    var editedPhoto = ""
    
    @IBOutlet weak var profilePicOutlet: UIImageView!
    @IBOutlet weak var profilePic2Outlet: UIImageView!
    @IBOutlet weak var profilePicCenterConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var editButton1: UIView!
    @IBOutlet weak var editButton2: UIView!
    
    //Actions
    @IBAction func firstPic(sender: AnyObject) {
        
        print("first pic")
        editedPhoto = "profilePicture"
        
        let cameraProfile = UIImagePickerController()
        
        cameraProfile.delegate = self
        cameraProfile.allowsEditing = false
        
        let alertController = UIAlertController(title: "Smile!", message: "Take a pic or choose from gallery?", preferredStyle:  UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                cameraProfile.sourceType = UIImagePickerControllerSourceType.Camera
            }
            
            self.profileController?.presentViewController(cameraProfile, animated: true, completion: nil)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            
            cameraProfile.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.profileController?.presentViewController(cameraProfile, animated: true, completion: nil)
            
        }))
        
        self.profileController?.presentViewController(alertController, animated: true, completion: nil)

        
        
        
        
        
    }
    
    
    
    
    
    
    @IBAction func secondPic(sender: AnyObject) {
        
        print("second pic")
        editedPhoto = "profilePicture2"
        
        let cameraProfile = UIImagePickerController()
        
        cameraProfile.delegate = self
        cameraProfile.allowsEditing = false
        
        let alertController = UIAlertController(title: "Smile!", message: "Take a pic or choose from gallery?", preferredStyle:  UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                cameraProfile.sourceType = UIImagePickerControllerSourceType.Camera
            }
            
            self.profileController?.presentViewController(cameraProfile, animated: true, completion: nil)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            
            cameraProfile.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.profileController?.presentViewController(cameraProfile, animated: true, completion: nil)
            
        }))
        
        self.profileController?.presentViewController(alertController, animated: true, completion: nil)
 
    }
    
    
    
    //Image Picker Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {

        let scopeEditedPhoto = editedPhoto
        let scopeProfileController = profileController
        
        
        scopeProfileController?.rootController?.chatController?.senderId = "none"
        scopeProfileController?.rootController?.chatController?.senderDisplayName = "none"

        scopeProfileController?.dismissViewControllerAnimated(true, completion: {
            
            
            if scopeEditedPhoto == "profilePicture" {
                
                let scale = image.size.height / image.size.width
                
                scopeProfileController?.tempImage1Scale = scale
                scopeProfileController?.tempImage1 = image
                
                
            }
            
            
            
            if scopeEditedPhoto == "profilePicture2" {

                let scale = image.size.height / image.size.width
                
                scopeProfileController?.tempImage2Scale = scale
                scopeProfileController?.tempImage2 = image
 
            }

            print("dismissed")
            
            self.imageUploadRequest(image) { (url, uploadRequest) in
                
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                
                
                transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
                    
                    if task.error == nil {
                        
                        print("successful image upload")
                        let ref = FIRDatabase.database().reference()
                        
                        if let uid = FIRAuth.auth()?.currentUser?.uid {
                            
                            if scopeEditedPhoto == "profilePicture" {
                                
                                self.profileController?.tempImage1 = nil
                                
                                
                            } else if scopeEditedPhoto == "profilePicture2" {
                                
                                self.profileController?.tempImage2 = nil
                                
                                
                            }
                            

                            ref.child("users").child(uid).updateChildValues([scopeEditedPhoto: url])
                        }
                        
                    } else {
                        print("error uploading: \(task.error)")
                        
                        let alertController = UIAlertController(title: "Sorry", message: "Error uploading profile picture, please try again later", preferredStyle:  UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                        self.profileController?.presentViewController(alertController, animated: true, completion: nil)
                        
                    }
                    return nil
                }
            }
            
        })
    }
    
    //Image Uploads
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


    
    //Functions
    func addSwipeGesture(){
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        leftSwipe.direction = .Left
        leftSwipe.delegate = self
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        rightSwipe.direction = .Right
        rightSwipe.delegate = self
        
        self.addGestureRecognizer(rightSwipe)
        self.addGestureRecognizer(leftSwipe)
        
        
    }
    
    func swipeLeft(){
        
        print("pictures: \(profileController?.pictures)")
        print("current picture: \(profileController?.currentPicture)")
        
        if profileController?.currentPicture < profileController?.pictures && profileController?.pictures != 1 {
            
            profileController?.currentPicture += 1
            
            let screenWidth = self.bounds.width
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.profilePicCenterConstOutlet.constant -= screenWidth
                
                self.layoutIfNeeded()
                
            }) { (complete) in
                
                self.profileController?.globCollectionCell.reloadData()
                print("completed")
                
            }
            
            print("left swipe")
            
        }
    }
    
    func swipeRight(){
        
        print("pictures: \(profileController?.pictures)")
        print("current picture: \(profileController?.currentPicture)")
        
        if (profileController?.currentPicture == profileController?.pictures || profileController?.currentPicture > 1) && profileController?.pictures != 1 {
            
            profileController?.currentPicture -= 1
            
            let screenWidth = self.bounds.width
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.profilePicCenterConstOutlet.constant += screenWidth
                self.layoutIfNeeded()
                
            }) { (complete) in
                
                self.profileController?.globCollectionCell.reloadData()
                print("completed")
                
            }
        }
        
        
        print("right swipe")
        
    }

    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
