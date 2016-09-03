//
//  TopNavBarController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-06.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class TopNavBarController: UIViewController {
    
    //Variables
    weak var rootController: MainRootController?
    

    //Actions
    @IBAction func toggleMenu(sender: AnyObject) {
        
        rootController?.toggleMenu({ (bool) in
            
            print("menu toggled")
            
        })
    }
    
    
    @IBAction func logoToHome(sender: AnyObject) {
        
        rootController?.toggleHome({ (bool) in
            
            print("home toggled")
            
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
