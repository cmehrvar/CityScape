//
//  LeaderboardController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-10-15.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class LeaderboardController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    weak var rootController: MainRootController?
    
    var leaders = [String]()
    
    
    @IBOutlet weak var globTableviewOutlet: UITableView!
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return leaders.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("leaderCell", forIndexPath: indexPath) as! LeaderboardCell
        
        cell.rankOutlet.text = "#\(indexPath.row + 1)"
        
        cell.loadCell(leaders[indexPath.row])
        
        return cell
        
    }
    
    
    
    func loadLeaderboard(){
        
        let ref = FIRDatabase.database().reference().child("leaders")
        
        ref.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            
            if let value = snapshot.value as? [String : Int] {
                
                var scopeLeaders = [String]()
                
                let sortedValue = value.sort({ (a: (String, Int), b: (String, Int)) -> Bool in
                    
                    if a.1 > b.1 {
                        
                        return false
                        
                    } else {
                        
                        return true
                        
                    }
                    
                })
                
                for leader in sortedValue {
                    
                    scopeLeaders.append(leader.0)

                }
                
                self.leaders = scopeLeaders
                self.globTableviewOutlet.reloadData()

            }
        })
    }
    
    @IBAction func back(sender: AnyObject) {
        
        rootController?.toggleLeaderboard({ (bool) in
            
            print("leaderboard closed")
            
        })
        
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
