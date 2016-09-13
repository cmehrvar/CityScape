//
//  ActionsViewController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-02.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Fusuma
import AVFoundation

class ActionsViewController: UIViewController, FusumaDelegate, AdobeUXImageEditorViewControllerDelegate {
    
    weak var rootController: MainRootController?

    //Actions
    @IBAction func home(sender: AnyObject) {
        
        rootController?.toggleHome({ (bool) in
            
            print("home toggled")
            
        })
    }
    
    
    @IBAction func search(sender: AnyObject) {

        rootController?.toggleSearch({ (bool) in
            
            print("search toggled")
            
        })
    }

    
    @IBAction func camera(sender: AnyObject) {
        
        print("camera")
        
        presentFusumaCamera()
        
    }
    
    
    
    @IBAction func globe(sender: AnyObject) {
        
        
        print("globe")
        
        rootController?.toggleSnapchat({ (bool) in
            
            print("snapchat toggled")
            
        })
        
    }
    
    
    @IBAction func profile(sender: AnyObject) {
        
        rootController?.profileRevealed = true
        
        rootController?.toggleHome({ (bool) in
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid, selfProfile = self.rootController?.selfData["profilePicture"] as? String {
                
                self.rootController?.toggleProfile(selfUID, selfProfile: true, profilePic: selfProfile, completion: { (bool) in
                    
                    print("profile toggled")
                    
                })
            }
        })

        print("profile")
        
    }
    
    
    //Functions
    func presentFusumaCamera(){
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true
        fusuma.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

        presentViewController(fusuma, animated: true) {
            
            self.rootController?.cameraTransitionOutlet.alpha = 1
            
            self.rootController?.view.layoutIfNeeded()

        }
    }
    
    
    //Adobe Delegates
    func photoEditor(editor: AdobeUXImageEditorViewController, finishedWithImage image: UIImage?) {
        
        /*
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        editor.view.window?.layer.addAnimation((transition), forKey: nil)
        
        
        
        
        let navVc = self.storyboard?.instantiateViewControllerWithIdentifier("handlePostController") as! UINavigationController
        let vc = navVc.viewControllers.first as! HandlePostController
        vc.isImage = true
        vc.image = image
        */

        //editor.presentViewController(navVc, animated: false, completion: nil)
        
        
        
        editor.dismissViewControllerAnimated(false) {
            
            UIApplication.sharedApplication().statusBarHidden = false
            
            self.rootController?.toggleHandlePost(image, videoURL: nil, isImage: true, completion: { (bool) in
                
                self.rootController?.cameraTransitionOutlet.alpha = 0
                print("handle post toggled")
                
            })

        }

        print("photo editor chosen")
        
    }
    func photoEditorCanceled(editor: AdobeUXImageEditorViewController) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        editor.view.window?.layer.addAnimation((transition), forKey: nil)
        
        let scopeRoot = rootController
        
        editor.dismissViewControllerAnimated(false) {
            
            scopeRoot?.cameraTransitionOutlet.alpha = 1

            self.presentFusumaCamera()
        }
        print("photo editor cancelled")
        
    }
    
    //Fusuma Delegates
    func fusumaImageSelected(image: UIImage) {
        
        print("image selected")
        
    }
    func fusumaDismissedWithImage(image: UIImage) {
        
        print("fusuma dismissed with image")
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.addAnimation((transition), forKey: nil)
        
        
        let editorController = AdobeUXImageEditorViewController(image: image)
        editorController.delegate = self
        
        self.presentViewController(editorController, animated: false, completion: nil)
        
    }
    func fusumaVideoCompleted(withFileURL fileURL: NSURL) {
        
        let scopeRoot = rootController
        
        UIApplication.sharedApplication().statusBarHidden = false

        let asset = AVURLAsset(URL: fileURL)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        
        do {

            let cgImage =  try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
            let uiImage = UIImage(CGImage: cgImage)
            
            scopeRoot?.toggleHandlePost(uiImage, videoURL: fileURL, isImage: false, completion: { (bool) in
                print("video handled")
                scopeRoot?.cameraTransitionOutlet.alpha = 0
            })
            
            
        } catch let error {
            print(error)
        }

        print("fusuma video completed")
        
        
    }
    func fusumaCameraRollUnauthorized() {
        
        let alertController = UIAlertController(title: "Sorry", message: "Camera not authorized", preferredStyle:  UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        
        print("camera unauthorized")
        
    }
    func fusumaClosed() {
        
        UIApplication.sharedApplication().statusBarHidden = false
        
        rootController?.cameraTransitionOutlet.alpha = 0
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()

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
