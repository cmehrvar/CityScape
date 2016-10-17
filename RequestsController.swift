//
//  RequestsController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-21.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RequestsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var rootController: MainRootController?

    @IBOutlet weak var numberOfRequestsOutlet: UILabel!
    @IBOutlet weak var globTableViewOutlet: UITableView!

    var requests = [[AnyHashable: Any]]()

    
    @IBAction func back(_ sender: AnyObject) {
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            rootController?.toggleProfile(uid, selfProfile: true, completion: { (bool) in
                
                print("self profile toggled")
                
            })
        }
    }
    
    
    
    //TableView Delegates
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.allowsSelection = false
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestTableViewCell", for: indexPath) as! RequestTableViewCell
        cell.requestController = self
        
        cell.loadCell(requests[(indexPath as NSIndexPath).row])
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
