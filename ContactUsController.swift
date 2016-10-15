//
//  ContactUsController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-10-12.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ContactUsController: UIViewController {

    weak var rootController: MainRootController?
    
    @IBAction func back(sender: AnyObject) {
        
        rootController?.toggleContactUs({ (bool) in
            
            print("contact us toggled", terminator: "")
            
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
