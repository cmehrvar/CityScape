//
//  NotificationController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-16.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class NotificationController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var rootController: MainRootController?
    
    var globNotifications = [[NSObject : AnyObject]]()
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("likeCell", forIndexPath: indexPath) as! LikeCell
            cell.profileOutlet.layer.cornerRadius = ((60 - (8*2)) / 2)
            return cell
            
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("postUpdateCell", forIndexPath: indexPath) as! PostUpdateCell
            cell.profileOutlet.layer.cornerRadius = ((60 - (8*2)) / 2)
            return cell

        } else if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as! MessageCell
            cell.profileOutlet.layer.cornerRadius = ((60 - (8*2)) / 2)
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("squadRequestCell", forIndexPath: indexPath) as! SquadRequestCell
            cell.profilePictureOutlet.layer.cornerRadius = ((60 - (8*2)) / 2)
            return cell
            
        }
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
        
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
