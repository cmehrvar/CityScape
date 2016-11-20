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
import AVFoundation

class ActionsViewController: UIViewController {
    
    weak var rootController: MainRootController?

    //Actions
    @IBAction func home(_ sender: AnyObject) {
        
        UIApplication.shared.isStatusBarHidden = false
        
        if let currentTab = rootController?.currentTab {
            
            if currentTab == 1 {
                
                rootController?.nearbyController?.globCollectionView.setContentOffset(CGPoint.zero, animated: true)
                
                if let lastLocation = rootController?.nearbyController?.globLocation {
                    
                    rootController?.nearbyController?.queryNearby(lastLocation)
                    
                }
                
            } else if currentTab == 2 {
                
                rootController?.vibesFeedController?.globCollectionView.setContentOffset(CGPoint.zero, animated: true)
                rootController?.vibesFeedController?.globCollectionView.reloadData()
                
            } else if currentTab == 3 {
                
                rootController?.messagesController?.globTableView.setContentOffset(CGPoint.zero, animated: true)
                rootController?.messagesController?.globTableView.reloadData()
                
            }
        }

        rootController?.toggleHome({ (bool) in
            
            print("home toggled")
            
        })
    }
    
    
    @IBAction func search(_ sender: AnyObject) {

        if let searchRevealed = rootController?.searchRevealed {
            
            if !searchRevealed {
                
                self.rootController?.toggleSearch({ (bool) in
                    
                    print("search revealed")
                    
                })

            } else {
                
                rootController?.toggleHome({ (bool) in
                    
                    print("close purple")
                    
                })
            }
        }
    }



    
    @IBAction func globe(_ sender: AnyObject) {

        print("globe")
        
        rootController?.toggleSnapchat(nil, startingi: nil, completion: { (bool) in
            
            print("snapchat toggled")
            
        })
    }
    
    
    @IBAction func profile(_ sender: AnyObject) {

        UIView.animate(withDuration: 0.3, animations: {
            
            if let screenHeight = self.rootController?.view.bounds.height {
                
                self.rootController?.squadTopConstOutlet.constant = -screenHeight
                self.rootController?.squadBottomConstOutlet.constant = screenHeight
                
                self.rootController?.requestsTopConstOutlet.constant = -screenHeight
                self.rootController?.requestsBottomConstOutlet.constant = screenHeight
                
                self.rootController?.view.layoutIfNeeded()

            }

            }, completion: { (bool) in
                
                self.rootController?.squadCountRevealed = false
                self.rootController?.requestsRevealed = false
                
        }) 
        
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
        
            self.rootController?.toggleProfile(selfUID, selfProfile: true, completion: { (bool) in
                
                self.rootController?.profileRevealed = true
                
                
            })
        }
        
        print("profile")
        
    }
    
    
    //Functions
    /*
    func presentFusumaCamera(){
        
        UIApplication.shared.isStatusBarHidden = true
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true
        fusuma.modalTransitionStyle = UIModalTransitionStyle.crossDissolve

        present(fusuma, animated: true) {
            
            self.rootController?.cameraTransitionOutlet.alpha = 1
            
            self.rootController?.view.layoutIfNeeded()

        }
    }
    
    
    //Adobe Delegates
    func photoEditor(_ editor: AdobeUXImageEditorViewController, finishedWith image: UIImage?) {
        
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
        
        
        
        editor.dismiss(animated: false) {
            
            UIApplication.shared.isStatusBarHidden = false
            
            self.rootController?.toggleHandlePost(image, videoURL: nil, isImage: true, completion: { (bool) in
                
                self.rootController?.cameraTransitionOutlet.alpha = 0
                print("handle post toggled")
                
            })

        }

        print("photo editor chosen")
        
    }
    func photoEditorCanceled(_ editor: AdobeUXImageEditorViewController) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        editor.view.window?.layer.add((transition), forKey: nil)
        
        let scopeRoot = rootController
        
        editor.dismiss(animated: false) {
            
            scopeRoot?.cameraTransitionOutlet.alpha = 1

            self.presentFusumaCamera()
        }
        print("photo editor cancelled")
        
    }
    
    //Fusuma Delegates
    func fusumaImageSelected(_ image: UIImage) {
        
        print("image selected")
        
    }
    func fusumaDismissedWithImage(_ image: UIImage) {
        
        print("fusuma dismissed with image")
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.add((transition), forKey: nil)
        
        
        let editorController = AdobeUXImageEditorViewController(image: image)
        editorController.delegate = self
        
        self.present(editorController, animated: false, completion: nil)
        
    }
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        let scopeRoot = rootController
        
        UIApplication.shared.isStatusBarHidden = false

        let asset = AVURLAsset(url: fileURL)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        
        do {

            let cgImage =  try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            
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
        
        let alertController = UIAlertController(title: "Sorry", message: "Camera not authorized", preferredStyle:  UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
        print("camera unauthorized")
        
    }
    func fusumaClosed() {
        
        UIApplication.shared.isStatusBarHidden = false
        
        rootController?.cameraTransitionOutlet.alpha = 0
        
    }
*/

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
