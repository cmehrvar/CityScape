//
//  TopChatController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-05.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class TopChatController: UIViewController {
    
    weak var rootController: ChatRootController?
    
    var globPostUIDs = [String]()
    var postData = [[NSObject:AnyObject]?]()
    var tableViewOffset = CGPoint()
    
    weak var mainRootController: MainRootController?

    
    @IBAction func back(sender: AnyObject) {

        let post = postData
        let id = globPostUIDs
        
        let offset = tableViewOffset

        let vc = mainRootController
        
        self.dismissViewControllerAnimated(true, completion: {
            
                vc?.homeController?.observeData(id, postData: post)
                vc?.homeController?.tableView.contentOffset = offset
                vc?.homeController?.tableView.reloadData()
                
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
