////
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
    var globPostUIDs = [String]()
    var postData = [[NSObject:AnyObject]?]()
    var messageData = [[NSObject : AnyObject]?]()
    var globHasLiked = [Bool?]()
    var refreshControl = UIRefreshControl()
    var dateFormatter = NSDateFormatter()
    var cellHeightsDictionary = [Int: CGFloat]()
    
    
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
    
    func observeMessageData(postUID: String, index: Int){
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("posts").child(postUID).child("messages").queryLimitedToLast(3).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let value = snapshot.value as? [NSObject:AnyObject] {
                
                self.messageData[index] = value
                self.tableView.reloadData()
            }
            
            
        })
        
        ref.child("posts").child(postUID).child("messages").queryLimitedToLast(3).observeEventType(.Value, withBlock: { (snapshot) in
            
            if let value = snapshot.value as? [NSObject:AnyObject] {
                
                self.messageData[index] = value
                self.tableView.reloadData()
            } 
        })
    }
    
    
    //Functions
    func observeData(postUIDs: [String], postData: [[NSObject : AnyObject]?]){
        
        for post in postUIDs {
            self.messageData.append([NSObject:AnyObject]())
        }
        
        
        //self.messageData.reserveCapacity(postUIDs.count)
        
        self.globPostUIDs = postUIDs
        self.postData = postData
        
        //self.tableView.reloadData()
        
        let ref = FIRDatabase.database().reference()
        
        for i in 0..<postUIDs.count {
            
            observeMessageData(postUIDs[i], index: i)
            
            ref.child("posts").child(postUIDs[i]).observeEventType(.Value, withBlock: { (snapshot) in
                
                if let actualValue = snapshot.value as? [NSObject : AnyObject] {
                    
                    if let hasLiked = actualValue["hasLiked"] as? [String:Bool] {
                        
                        var liked = false
                        
                        for (key, _) in hasLiked {
                            
                            if key == FIRAuth.auth()?.currentUser?.uid {
                                
                                liked = true
                                
                            }
                        }
                        
                        //globHasLiked = true
                        
                    } else {
                        
                        //self.globHasLiked[i] = false
                        
                    }
                    
                    self.postData[i] = actualValue
                    self.tableView.reloadData()
                    
                }
            })
        }
    }
    
    
    func getFirebaseData() {
        
        let ref = FIRDatabase.database().reference()
        
        self.globPostUIDs.removeAll()
        
        ref.child("postUIDs").observeSingleEventOfType(.Value, withBlock: { (snapshot) in

            var funcPostUIDs = [String : NSTimeInterval]()
            var stringArray = [String]()
            var funcPostData = [[NSObject : AnyObject]?]()
            var funcHasLiked = [Bool?]()
            
            if let actualSnap = snapshot.value as? [String:NSTimeInterval] {
                
                for (key, value) in actualSnap {
                    
                    funcPostUIDs[key] = value
                    funcPostData.append(nil)
                    funcHasLiked.append(nil)
                    
                    
                }
                
                let sortedSnap = funcPostUIDs.sort({ (a: (String, NSTimeInterval), b: (String, NSTimeInterval)) -> Bool in
                    
                    if a.1 > b.1 {
                        return true
                    } else {
                        return false
                    }
                    
                })

                
                
                for (key, _) in sortedSnap {
                    
                    stringArray.append(key)
                    
                }
                
                self.observeData(stringArray, postData: funcPostData)

            }
            
            
            let now = NSDate()

            let updateString = "Last updated: " + self.dateFormatter.stringFromDate(now)
            self.refreshControl.attributedTitle = NSAttributedString(string: updateString)
            
            if self.refreshControl.refreshing {
                
                self.refreshControl.endRefreshing()
                
            }
            
            self.tableView.reloadData()

        })
    }
    
    
    func createRefresh(){
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        self.dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        self.dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        self.tableView.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(HomeController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    func refresh(sender: AnyObject) {
        
        self.getFirebaseData()
        
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
        //tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        let defaultCell = UITableViewCell()

        if indexPath.row % 2 == 0 || indexPath.row == 0 {
            
            let realIndex = indexPath.row / 2
            
            if let actualData = postData[realIndex] {
                
                if let isImage = actualData["isImage"] as? Bool {
                    
                    if isImage {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("imageCell") as! ImageContentCell
                        
                        //cell.hasLiked = globHasLiked[realIndex]
                        cell.postUID = globPostUIDs[realIndex]
                        cell.data = actualData
                        cell.loadData()

                        cell.homeController = self
                        return cell
                        
                    }
                }
            }
            print("post")
        } else if indexPath.row % 2 == 1 {
            print("comment")

            let realIndex = (indexPath.row / 2)
            
            print(realIndex)
            
            let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
            cell.homeController = self
            cell.globPostUIDs = globPostUIDs
            cell.postUID = globPostUIDs[realIndex]
            cell.globPostData = postData
            
            print("message data count")
            print(messageData.count)
            cell.messageData = messageData[realIndex]
            print(messageData[realIndex])
            cell.loadData()
            
            return cell

        }
        
        return defaultCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numOfCells = postData.count * 2
        
        return numOfCells
    
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let key = indexPath.row
        let height = cell.frame.size.height
        self.cellHeightsDictionary[key] = height
        
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let key = indexPath.row
        
        if let actualHeight = self.cellHeightsDictionary[key] {
            
            if actualHeight != 0 {
                
                return actualHeight
                
            } else {
                return UITableViewAutomaticDimension
            }
            
        } else {
            return UITableViewAutomaticDimension
        }
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }

    override func viewDidAppear(animated: Bool) {
        print("view appeared")
        
        self.navigationController?.navigationBarHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        createRefresh()
        
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
