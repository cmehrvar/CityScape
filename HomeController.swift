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
    
    //Variables
    var postData = [[NSObject:AnyObject]]()
    var globHasLiked = [Bool]()
    
    @IBAction func chatAction(sender: AnyObject) {
        
        //getFirebaseData()
        
    }
    
    //Outlets
    @IBOutlet weak var closeMenuOutlet: UIView!
    @IBOutlet weak var transitionToFusumaOutlet: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeViewOutlet: UIView!
    @IBOutlet weak var dislikeViewOutlet: UIView!
    
    
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
    
    
    //Functions
    func getFirebaseData() {

        let ref = FIRDatabase.database().reference()
        
        ref.child("posts").observeEventType(.Value, withBlock: { (snapshot) in
            
            if let rest = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in rest {
                    
                    if let value = snap.value as? [NSObject : AnyObject] {
                        
                        if let hasLiked = value["hasLiked"] as? [String:Bool] {
                            
                            var liked = false
                            
                            for (key, _) in hasLiked {
                                
                                if key == FIRAuth.auth()?.currentUser?.uid {
                                    
                                    liked = true
                                    
                                    
                                }
                                
                            }
                            
                            self.globHasLiked.insert(liked, atIndex: 0)
                            
                        } else {
                            
                            self.globHasLiked.insert(false, atIndex: 0)
                            
                        }
                        
                        self.postData.insert(value, atIndex: 0)
                        
                    }

                    
                    
                }
                
                
                
            self.tableView.reloadData()
            }
            
        })
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
            self.transitionToFusumaOutlet.alpha = 1
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
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        if postData[indexPath.row]["isImage"] as? Bool == true {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("imageCell") as! ImageContentCell

            cell.globHasLiked = globHasLiked[indexPath.row]
            cell.data = postData[indexPath.row]
            cell.loadData()

            cell.homeController = self
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("imageCell") as! ImageContentCell
            
            cell.globHasLiked = globHasLiked[indexPath.row]
            cell.data = postData[indexPath.row]
            cell.loadData()
            
            cell.homeController = self
            return cell
            
        }
        
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postData.count
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
