//
//  CloseMenuController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-09.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class CloseMenuController: UIViewController {
    
    weak var rootController: MainRootController?
    
    @IBAction func closeMenu(sender: AnyObject) {
        
        rootController?.toggleMenu({ (bool) in
            print("menu closed")
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
