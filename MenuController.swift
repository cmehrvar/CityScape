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
    @IBOutlet weak var addFromFacebookViewOutlet: UIView!
    
    
    @IBAction func leaderboard(_ sender: AnyObject) {
        
        rootController?.toggleMenu({ (bool) in
            
            self.rootController?.toggleLeaderboard({ (bool) in
                
                print("leaderboard toggled")
                
            })
            
        })
    }
    
    
    
    //Functions
    func setMenu(){
        
        if !keyboardShown {
            
            if let status = rootController?.selfData["currentStatus"] as? String {
                
                currentStatusTextViewOutlet.text = status
                charactersOutlet.text = "\(status.characters.count)/30 Characters"
                
            } else {
                
                currentStatusTextViewOutlet.text = nil
                charactersOutlet.text = "0/30 Characters"
                
            }
        }
        

        if let profilePicture = rootController?.selfData["profilePicture"] as? String, let profileURL = URL(string: profilePicture) {
            
            if profileUID == "" {
                profileUID = profilePicture
                profilePicOutlet.sd_setImage(with: profileURL, placeholderImage: nil)
            } else if profileUID != profilePicture {
                profileUID = profilePicture
                profilePicOutlet.sd_setImage(with: profileURL, placeholderImage: tempCaptured)
                
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        tempCaptured = image
        profilePicOutlet.image = image
        
        dismiss(animated: true) {
            
            self.imageUploadRequest(image) { (url, uploadRequest) in
                
                let transferManager = AWSS3TransferManager.default()
                
                transferManager?.upload(uploadRequest).continue({ (task) -> Any? in
                    
                    if task.error == nil {
                        
                        print("successful image upload")
                        let ref = FIRDatabase.database().reference()
                        
                        if let uid = FIRAuth.auth()?.currentUser?.uid {
                            ref.child("users").child(uid).updateChildValues(["profilePicture": url])
                        }
                        
                    } else {
                        print("error uploading: \(task.error)")
                        
                        let alertController = UIAlertController(title: "Sorry", message: "Error uploading profile picture, please try again later", preferredStyle:  UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                    }

                    return nil
                })
            }
        }
    }
    
    func imageUploadRequest(_ image: UIImage, completion: @escaping (_ url: String, _ uploadRequest: AWSS3TransferManagerUploadRequest) -> ()) {
        
        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".jpeg"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload").appendingPathComponent(fileName)
        let filePath = fileURL.path
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        
        //SEGMENTATION BUG, IF FAULT 11 - COMMENT OUT AND REWRITE
        DispatchQueue.main.async {
            try? imageData?.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest?.body = fileURL
            uploadRequest?.key = fileName
            uploadRequest?.bucket = "cityscapebucket"
            
            var imageUrl = ""
            
            if let key = uploadRequest?.key {
                imageUrl = "https://s3.amazonaws.com/cityscapebucket/" + key
                
            }
            
            completion(imageUrl, uploadRequest!)
        }
    }
    
    
    func addUploadStuff(){
        
        let error = NSErrorPointer.init(nilLiteral: ())
        
        do{
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error?.pointee = error1
            print("Creating upload directory failed. Error: \(error)")
        }
    }
    
    func dismissKeyboard(){
        
        self.view.endEditing(true)
        
    }
    
    
    func addGestureRecognizers(){
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(closeMenu))
        leftSwipeGestureRecognizer.direction = .left
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
    func textViewDidChange(_ textView: UITextView) {
        
        let textCount = textView.text.characters.count
        charactersOutlet.text = "\(textCount)/30 Characters"
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            textView.resignFirstResponder()
            return false
            
        }
        
        return textView.text.characters.count + (text.characters.count - range.length) <= 30
    }
    
    
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("users").child(selfUID)
            ref.child("currentStatus").setValue(textView.text)
            
        }
    }
    
    
    
    //Actions
    @IBAction func goToFacebook(_ sender: AnyObject) {
        
        rootController?.toggleMenu({ (bool) in
            
            self.rootController?.toggleAddFromFacebook(completion: { (bool) in
                
                print("add from facebook shown")
                
            })
        })
    }
    
    
    
    @IBAction func editProfile(_ sender: AnyObject) {
        
        let cameraProfile = UIImagePickerController()
        
        cameraProfile.delegate = self
        cameraProfile.allowsEditing = false
        
        let alertController = UIAlertController(title: "Smile!", message: "Take a pic or choose from gallery?", preferredStyle:  UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                cameraProfile.sourceType = UIImagePickerControllerSourceType.camera
            }
            
            self.present(cameraProfile, animated: true, completion: nil)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
            
            cameraProfile.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            self.present(cameraProfile, animated: true, completion: nil)
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    
    @IBAction func goToProfile(_ sender: AnyObject) {
        
        print("go to profile")
        
        rootController?.profileRevealed = true
        
        rootController?.toggleMenu({ (bool) in
            
            print("menu toggled")
            
            self.rootController?.clearVibesPlayers()
            
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                
                self.rootController?.toggleProfile(uid, selfProfile: true, completion: { (bool) in
                    
                    print("self profile toggled")
                    
                })
            }
        })
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        
        
        rootController?.toggleMenu({ (bool) in
            
            self.rootController?.toggleSettings({ (bool) in
                
                print("settings toggled")
                
            })
        })
    }
    
    func keyboardDidShow(){
        
        self.dismissKeyboardViewOutlet.alpha = 1
        keyboardShown = true
        
        
    }
    
    func keyboardDidHide(){
        
        self.dismissKeyboardViewOutlet.alpha = 0
        keyboardShown = false
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
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
        nameOutlet.baselineAdjustment = .alignCenters
        
        worldwideViewOutlet.layer.cornerRadius = 12
        settingsViewOutlet.layer.cornerRadius = 12
        addFromFacebookViewOutlet.layer.cornerRadius = 12
        
        currentStatusTextViewOutlet.layer.cornerRadius = 8
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
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
