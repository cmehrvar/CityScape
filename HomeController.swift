//
//  HomeController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-30.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Fusuma
import AVFoundation
import Firebase
import FirebaseAuth
import FirebaseDatabase


class HomeController: UIViewController, FusumaDelegate, AdobeUXImageEditorViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    weak var rootController: MainRootController?
    
    //Outlets
    @IBOutlet weak var closeMenuOutlet: UIView!
    @IBOutlet weak var transitionToFusumaOutlet: UIView!
    
    
    //Actions
    @IBAction func closeMenu(sender: AnyObject) {
        
        rootController?.toggleMenu({ (complete) in
            
            print("menu toggled")
            
        })
        
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        
        rootController?.toggleMenu({ (complete) in
            
            print("menu toggled")
            
        })
    }
    
    
    @IBAction func gotToCamera(sender: AnyObject) {
        
        presentFusumaCamera()
        
        
    }

    
    // DELEGATES //
    
    
    //Adobe Delegates
    func photoEditor(editor: AdobeUXImageEditorViewController, finishedWithImage image: UIImage?) {
        
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
        editor.presentViewController(navVc, animated: false, completion: nil)
        print("photo editor chosen")
        
    }
    
    func photoEditorCanceled(editor: AdobeUXImageEditorViewController) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        editor.view.window?.layer.addAnimation((transition), forKey: nil)

        editor.dismissViewControllerAnimated(false) {
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
        
        self.presentViewController(editorController, animated: false) { 
            self.transitionToFusumaOutlet.alpha = 0
        }
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: NSURL) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.addAnimation((transition), forKey: nil)
        let navVc = self.storyboard?.instantiateViewControllerWithIdentifier("handlePostController") as! UINavigationController
        let vc = navVc.viewControllers.first as! HandlePostController
        vc.videoURL = fileURL
        vc.isImage = false
        
        self.presentViewController(navVc, animated: false) {
            self.transitionToFusumaOutlet.alpha = 0
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
        
        transitionToFusumaOutlet.alpha = 0
        
    }
    
    
    func presentFusumaCamera(){
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true
        fusuma.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        presentViewController(fusuma, animated: true) { 
            self.transitionToFusumaOutlet.alpha = 1
        }
    }
    
    
    
    //TableView Delegates
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.allowsSelection = false
        
        let cell = tableView.dequeueReusableCellWithIdentifier("imageCell") as! ImageContentCell
        
        
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return 1
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
