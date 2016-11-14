//
//  NotificationController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-16.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class NotificationController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var rootController: MainRootController?
    
    var globNotifications = [[AnyHashable: Any]]()

    //Outlets
    @IBOutlet weak var globTableViewOutlet: UITableView!

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.allowsSelection = false
        
        if let notificationRevealed = rootController?.notificationRevealed {
            
            if notificationRevealed {
                
                if let read = globNotifications[(indexPath as NSIndexPath).row]["read"] as? Bool {
                    
                    if !read {
                        
                        if let selfUid = FIRAuth.auth()?.currentUser?.uid, let type = globNotifications[(indexPath as NSIndexPath).row]["type"] as? String {
                            
                            let ref = FIRDatabase.database().reference().child("users").child(selfUid).child("notifications")
                            
                            if type == "groupChats" {
                                
                                if let chatKey = globNotifications[(indexPath as NSIndexPath).row]["chatKey"] as? String {
                                    
                                    ref.child("groupChats").child(chatKey).child("read").setValue(true)
                                    
                                }
                                
                            } else if type == "post" {
                                
                                if let postKey = globNotifications[(indexPath as NSIndexPath).row]["postChildKey"] as? String {
                                    
                                    ref.child("posts").child(postKey).child("read").setValue(true)
                                    
                                }
                                
                            } else if type == "postComment" {
                                
                                if let userUID = globNotifications[indexPath.row]["senderUid"] as? String {
                                    
                                    ref.child(userUID).child("postComment").child("read").setValue(true)
                                    
                                }
 
                            } else {

                                if let userUID = globNotifications[(indexPath as NSIndexPath).row]["uid"] as? String {
                                    
                                    if type == "squadRequest" || type == "addedYou" {
                                        
                                        ref.child(userUID).child("squadRequest").child("read").setValue(true)
                                        
                                    } else {
                                        
                                        ref.child(userUID).child(type).child("read").setValue(true)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        if let type = globNotifications[(indexPath as NSIndexPath).row]["type"] as? String {
            
            if type == "squadRequest" || type == "addedYou" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "squadRequestCell", for: indexPath) as! SquadRequestCell
                
                cell.notificationController = self
                
                cell.profilePictureOutlet.layer.cornerRadius = ((60 - (8*2)) / 2)
                cell.loadCell(globNotifications[(indexPath as NSIndexPath).row])
                return cell
                
            } else if type == "matches" || type == "squad" || type == "groupChats" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
                
                cell.notificationController = self
                cell.profileOutlet.layer.cornerRadius = ((60 - (8*2)) / 2)
                cell.loadCell(globNotifications[(indexPath as NSIndexPath).row])
                return cell
                
            } else if type == "likesYou" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "likeCell", for: indexPath) as! LikeCell
                cell.profileOutlet.layer.cornerRadius = ((60 - (8*2)) / 2)
                
                cell.notificationController = self
                cell.loadData(globNotifications[(indexPath as NSIndexPath).row])
                
                
                return cell
            } else if type == "post" || type == "postComment" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "postUpdateCell", for: indexPath) as! PostUpdateCell
                cell.notificationController = self
                cell.profileOutlet.layer.cornerRadius = ((60 - (8*2)) / 2)
                cell.loadCell(globNotifications[(indexPath as NSIndexPath).row])
                return cell
            } else if type == "postComment" {
                
                
                //PRESENT POST COMMENT CELL
                
                
            }
            
        }
        
        return UITableViewCell()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return globNotifications.count
        
    }
    
    
    func slideRight(){
        
        rootController?.toggleNotifications({ (bool) in
            
            print("notifications toggled", terminator: "")
            
        })
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(slideRight))
        swipeGesture.direction = .right
        self.globTableViewOutlet.addGestureRecognizer(swipeGesture)
        
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
