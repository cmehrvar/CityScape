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
    
    var globNotifications = [[NSObject : AnyObject]]()

    //Outlets
    @IBOutlet weak var globTableViewOutlet: UITableView!

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.allowsSelection = false
        
        if let notificationRevealed = rootController?.notificationRevealed {
            
            if notificationRevealed {
                
                if let read = globNotifications[indexPath.row]["read"] as? Bool {
                    
                    if !read {
                        
                        if let selfUid = FIRAuth.auth()?.currentUser?.uid, userUID = globNotifications[indexPath.row]["uid"] as? String, type = globNotifications[indexPath.row]["type"] as? String {
                            
                            let ref = FIRDatabase.database().reference().child("users").child(selfUid).child("notifications").child(userUID)
   
                            if type == "addedYou" {
                                
                                ref.child("squadRequest").child("read").setValue(true)
                                
                            } else {
                                
                                ref.child(type).child("read").setValue(true)
                                
                            }
                        }
                    }
                }
            }
        }

        
        if let type = globNotifications[indexPath.row]["type"] as? String {
            
            if type == "squadRequest" || type == "addedYou" {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("squadRequestCell", forIndexPath: indexPath) as! SquadRequestCell

                cell.notificationController = self
                
                cell.profilePictureOutlet.layer.cornerRadius = ((60 - (8*2)) / 2)
                cell.loadCell(globNotifications[indexPath.row])
                return cell
                
            } else if type == "matches" || type == "squad" {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as! MessageCell
                
                cell.notificationController = self
                cell.profileOutlet.layer.cornerRadius = ((60 - (8*2)) / 2)
                cell.loadCell(globNotifications[indexPath.row])
                return cell
                
            } else if type == "likesYou" {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("likeCell", forIndexPath: indexPath) as! LikeCell
                cell.profileOutlet.layer.cornerRadius = ((60 - (8*2)) / 2)
                
                cell.loadData(globNotifications[indexPath.row])
                
                
                return cell
            }
            
        }
        
        return UITableViewCell()
   
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return globNotifications.count
        
    }
    
    
    func slideRight(){
        
        rootController?.toggleNotifications({ (bool) in
            
            print("notifications toggled")
            
        })
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(slideRight))
        swipeGesture.direction = .Right
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
