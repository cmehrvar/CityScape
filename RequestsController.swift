//
//  RequestsController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-21.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class RequestsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var rootController: MainRootController?

    @IBOutlet weak var numberOfRequestsOutlet: UILabel!
    @IBOutlet weak var globTableViewOutlet: UITableView!

    var requests = [[NSObject : AnyObject]]()

    //TableView Delegates
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.allowsSelection = false
        
        let cell = tableView.dequeueReusableCellWithIdentifier("requestTableViewCell", forIndexPath: indexPath) as! RequestTableViewCell
        cell.requestController = self
        
        cell.loadCell(requests[indexPath.row])
        
        return cell
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return requests.count
        
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
