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
                        
                        if let notificationKey = globNotifications[indexPath.row]["notificationKey"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid  {
                            
                            let ref = FIRDatabase.database().reference().child("users").child(selfUID)
                            ref.child("notifications").child(notificationKey).updateChildValues(["read" : true])
                            
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
                
            }
        }
        
        return UITableViewCell()
   
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(globNotifications.count)
        
        return globNotifications.count
        
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
