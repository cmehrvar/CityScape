//
//  VibesFeedController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-06.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Player
import Firebase
import FirebaseDatabase
import FirebaseAuth

class VibesFeedController: UIViewController, PlayerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    weak var rootController: MainRootController?
    
    //Variables
    var globPostUIDs = [String]()
    var postData = [[NSObject:AnyObject]?]()
    var messageData = [[NSObject : AnyObject]?]()
    var mainCommentVideos = [String : Player]()
    var loadedMessageData = [String : [[String : AnyObject]]]()
    
    var firstMessageData = [[String : AnyObject?]]()
    var secondMessageData = [[String : AnyObject?]]()
    var thirdMessageData = [[String : AnyObject?]]()
    
    var globHasLiked = [Bool?]()
    var refreshControl = UIRefreshControl()
    var dateFormatter = NSDateFormatter()
    var cellHeightsDictionary = [Int: CGFloat]()
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    
    //Actions
    @IBAction func slideToNearby(sender: AnyObject) {
        
        rootController?.toggleNearby({ (bool) in
            print("slide to nearby")
        })
        
    }
    
    
    @IBAction func slideToMessages(sender: AnyObject) {
        
        rootController?.toggleMessages({ (bool) in
            print("slide to messages")
        })
        
    }
    
    
    
    //Functions
    func getFirebaseData() {
        
        let ref = FIRDatabase.database().reference()
        
        self.messageData.removeAll()
        self.globPostUIDs.removeAll()
        self.postData.removeAll()
        self.loadedMessageData.removeAll()
        self.mainCommentVideos.removeAll()
        self.firstMessageData.removeAll()
        self.secondMessageData.removeAll()
        self.thirdMessageData.removeAll()
        
        
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
                
                self.observeData(stringArray, postData: funcPostData, hasLiked: funcHasLiked)
                
            }
            
            let now = NSDate()
            
            let updateString = "Last updated: " + self.dateFormatter.stringFromDate(now)
            self.refreshControl.attributedTitle = NSAttributedString(string: updateString)
            
            if self.refreshControl.refreshing {
                
                self.refreshControl.endRefreshing()
                
            }
        })
    }
    
    func observeData(postUIDs: [String], postData: [[NSObject : AnyObject]?], hasLiked: [Bool?]){
        
        for post in postUIDs {
            self.messageData.append([NSObject:AnyObject]())
            self.firstMessageData.append([String : AnyObject?]())
            self.secondMessageData.append([String : AnyObject?]())
            self.thirdMessageData.append([String : AnyObject?]())
            
        }
        
        self.globPostUIDs = postUIDs
        self.postData = postData
        self.globHasLiked = hasLiked
        
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
                        
                        self.globHasLiked[i] = liked
                        
                    } else {
                        
                        self.globHasLiked[i] = false
                        
                    }
                    
                    self.postData[i] = actualValue
                    self.tableView.reloadData()
                    
                }
            })
        }
    }
    
    func observeMessageData(postUID: String, index: Int){
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("posts").child(postUID).child("messages").queryLimitedToLast(3).observeEventType(.Value, withBlock: { (snapshot) in
            
            if let value = snapshot.value as? [NSObject:AnyObject] {
                
                self.messageData[index] = value
                self.setTableViewMessageData(value, index: index)
                
                self.tableView.reloadData()
            }
        })
    }
    
    func setTableViewMessageData(messages: [NSObject : AnyObject], index: Int){
        
        var i = 0
        
        let sortedValue = messages.sort { (a: (NSObject, AnyObject), b: (NSObject, AnyObject)) -> Bool in
            
            if a.1["timeStamp"] as? NSTimeInterval > b.1["timeStamp"] as? NSTimeInterval {
                return false
            } else {
                return true
            }
        }
        
        
        for value in sortedValue {
            
            if i == 0 {
                
                firstMessageData[index]["name"] = value.1["senderDisplayName"] as? String
                firstMessageData[index]["text"] = value.1["text"] as? String
                firstMessageData[index]["profilePic"] = value.1["profilePicture"] as? String
                firstMessageData[index]["isMedia"] = value.1["isMedia"] as? Bool
                firstMessageData[index]["isImage"] = value.1["isImage"] as? Bool
                firstMessageData[index]["media"] = value.1["media"] as? String
                firstMessageData[index]["senderId"] = value.1["senderId"] as? String
                
                
            } else if i == 1 {
                
                secondMessageData[index]["name"] = value.1["senderDisplayName"] as? String
                secondMessageData[index]["text"] = value.1["text"] as? String
                secondMessageData[index]["profilePic"] = value.1["profilePicture"] as? String
                secondMessageData[index]["isMedia"] = value.1["isMedia"] as? Bool
                secondMessageData[index]["isImage"] = value.1["isImage"] as? Bool
                secondMessageData[index]["media"] = value.1["media"] as? String
                secondMessageData[index]["senderId"] = value.1["senderId"] as? String
                
            } else if i == 2 {
                
                thirdMessageData[index]["name"] = value.1["senderDisplayName"] as? String
                thirdMessageData[index]["text"] = value.1["text"] as? String
                thirdMessageData[index]["profilePic"] = value.1["profilePicture"] as? String
                thirdMessageData[index]["isMedia"] = value.1["isMedia"] as? Bool
                thirdMessageData[index]["isImage"] = value.1["isImage"] as? Bool
                thirdMessageData[index]["media"] = value.1["media"] as? String
                thirdMessageData[index]["senderId"] = value.1["senderId"] as? String
                
            } else {
                break
            }
            
            i += 1
            
        }
    }
    
    func createRefresh(){
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        self.dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        self.dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        self.tableView.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(VibesController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    func refresh(sender: AnyObject) {
        
        self.getFirebaseData()
        
    }





    
    //TableView Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postData.count * 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .None
        tableView.decelerationRate = UIScrollViewDecelerationRateFast
        
        let realIndex = (indexPath.row / 4)
        
        let defaultCell = tableView.dequeueReusableCellWithIdentifier("noCommentCell") as! NoCommentCell
        
        if indexPath.row % 4 == 0 || indexPath.row == 0 {
            
            if let actualData = postData[realIndex] {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("topCell") as! TopContentCell
                cell.loadData(actualData)
                return cell
                
                //let cell = tableView.dequeueReusableCellWithIdentifier("topCell") as! Top
                
                /*
                 
                 if let isImage = actualData["isImage"] as? Bool {
                 
                 if isImage {
                 
                 let cell = tableView.dequeueReusableCellWithIdentifier("topCell") as! TopContentCell
                 
                 if let loadedMessage = loadedMessageData[globPostUIDs[realIndex]] {
                 
                 cell.loadedMessages = loadedMessage
                 
                 }
                 
                 //cell.hasLiked = globHasLiked[realIndex]
                 //cell.postUID = globPostUIDs[realIndex]
                 
                 
                 //cell.rootController = rootController
                 //cell.globPostUIDs = globPostUIDs
                 //cell.globPostData = postData
                 //cell.hasLikedArray = globHasLiked
                 //cell.messageData = messageData[realIndex]
                 
                 //cell.postIndex = realIndex
                 
                 //cell.homeController = self
                 return cell
                 
                 } else {
                 
                 
                 //Do something with video
                 
                 
                 
                 
                 
                 }
                 }
                 
                 */
            }
            
        } else if indexPath.row % 4 == 1 {
            
            if let senderId = firstMessageData[realIndex]["senderId"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid, isMedia = firstMessageData[realIndex]["isMedia"] as? Bool {
                
                if senderId == selfUID {
                    
                    if isMedia {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("outMediaCommentCell") as! OutMediaCommentCell
                        cell.vibesController = self
                        cell.postIndex = (indexPath.row % 4) - 1
                        cell.messageIndex = 1
                        cell.setMediaComment(firstMessageData[realIndex])
                        return cell
                        
                    } else {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("outTextCommentCell") as! OutTextCommentCell
                        cell.loadData(firstMessageData[realIndex])
                        return cell
                        
                    }
                    
                } else {
                    
                    if isMedia {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("inMediaCommentCell") as! InMediaCommentCell
                        cell.vibesController = self
                        cell.postIndex = (indexPath.row % 4) - 1
                        cell.messageIndex = 1
                        cell.setMediaComment(firstMessageData[realIndex])
                        return cell
                        
                    } else {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("inTextCommentCell") as! InTextCommentCell
                        cell.loadData(firstMessageData[realIndex])
                        return cell
                        
                    }
                }
                
            } else {

                return defaultCell
                
            }
            
            
        } else if indexPath.row % 4 == 2 {
            
            if let senderId = secondMessageData[realIndex]["senderId"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid, isMedia = secondMessageData[realIndex]["isMedia"] as? Bool {
                
                if senderId == selfUID {
                    
                    if isMedia {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("outMediaCommentCell") as! OutMediaCommentCell
                        cell.vibesController = self
                        cell.postIndex = (indexPath.row % 4) - 2
                        cell.messageIndex = 2
                        cell.setMediaComment(secondMessageData[realIndex])
                        return cell
                        
                    } else {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("outTextCommentCell") as! OutTextCommentCell
                        cell.loadData(secondMessageData[realIndex])
                        return cell
                        
                    }
                    
                } else {
                    
                    if isMedia {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("inMediaCommentCell") as! InMediaCommentCell
                        cell.vibesController = self
                        cell.postIndex = (indexPath.row % 4) - 2
                        cell.messageIndex = 2
                        cell.setMediaComment(secondMessageData[realIndex])
                        return cell
                        
                    } else {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("inTextCommentCell") as! InTextCommentCell
                        cell.loadData(secondMessageData[realIndex])
                        return cell
                        
                    }
                }
                
            } else {

                return defaultCell
                
            }
            
        } else if indexPath.row % 4 == 3 {
            
            if let senderId = thirdMessageData[realIndex]["senderId"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid, isMedia = thirdMessageData[realIndex]["isMedia"] as? Bool {
                
                if senderId == selfUID {
                    
                    if isMedia {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("outMediaCommentCell") as! OutMediaCommentCell
                        cell.vibesController = self
                        cell.postIndex = (indexPath.row % 4) - 3
                        cell.messageIndex = 3
                        cell.setMediaComment(thirdMessageData[realIndex])
                        return cell
                        
                    } else {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("outTextCommentCell") as! OutTextCommentCell
                        cell.loadData(thirdMessageData[realIndex])
                        return cell
                        
                    }
                    
                } else {
                    
                    if isMedia {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("inMediaCommentCell") as! InMediaCommentCell
                        cell.vibesController = self
                        cell.postIndex = (indexPath.row % 4) - 3
                        cell.messageIndex = 3
                        cell.setMediaComment(thirdMessageData[realIndex])
                        return cell
                        
                    } else {
                        
                        let cell = tableView.dequeueReusableCellWithIdentifier("inTextCommentCell") as! InTextCommentCell
                        cell.loadData(thirdMessageData[realIndex])
                        return cell
                        
                    }
                }
                
            } else {

                return defaultCell
                
            }
        }
        
        return defaultCell
        
        
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
                
            } else if indexPath.row % 4 == 0 {
                return 374.0
            } else {
                return 30.0
            }
            
        } else if indexPath.row % 4 == 0 {
            return 374.0
        } else {
            return 30.0
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }

    
    
    
    
    
    //Player Delegates
    func playerReady(player: Player){
        
        print("player ready")
        
    }
    func playerPlaybackStateDidChange(player: Player){
        
        print("playback state did change")
        
        
    }
    func playerBufferingStateDidChange(player: Player){
        
         print("buffering state did change")
        

    }
    
    func playerPlaybackWillStartFromBeginning(player: Player){
        
         print("playback state did change")
        
    }
    func playerPlaybackDidEnd(player: Player){
        
        print("playback ended")
  
    }
    
    func playerCurrentTimeDidChange(player: Player) {
        print("current time did change")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
