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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return leaders.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderCell", for: indexPath) as! LeaderboardCell
        
        cell.rankOutlet.text = "#\((indexPath as NSIndexPath).row + 1)"
        
        cell.loadCell(leaders[(indexPath as NSIndexPath).row])
        
        return cell
        
    }
    
    
    
    func loadLeaderboard(){
        
        let ref = FIRDatabase.database().reference().child("leaders")
        
        ref.observeSingleEvent(of: .value, with:  { (snapshot) in
            
            if let value = snapshot.value as? [String : Int] {
                
                var scopeLeaders = [String]()
                
                let sortedValue = value.sorted(by: { (a: (String, Int), b: (String, Int)) -> Bool in
                    
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
    
    @IBAction func back(_ sender: AnyObject) {
        
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
