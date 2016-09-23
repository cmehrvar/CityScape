//
//  SquadCountController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-21.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class SquadCountController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var rootController: MainRootController?

    var selfSquad = false
    
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var globTableViewOutlet: UITableView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!

    var squad = [[NSObject : AnyObject]]()

    //TableView Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return squad.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("squadTableViewCell", forIndexPath: indexPath) as! SquadTableViewCell

        cell.squadCountController = self
        cell.selfSquad = selfSquad
        cell.loadCell(squad[indexPath.row])

        return cell
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameOutlet.adjustsFontSizeToFitWidth = true

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
