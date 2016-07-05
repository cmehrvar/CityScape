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
    var mostRecentTimeInterval: NSTimeInterval!
    
    @IBAction func back(sender: AnyObject) {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        rootController?.view.window?.layer.addAnimation((transition), forKey: nil)
        
        
        vc.homeController?.globMostRecentTimeStamp = mostRecentTimeInterval

        let time = mostRecentTimeInterval
        
        rootController?.presentViewController(vc, animated: false, completion: {
            
            vc.homeController?.globMostRecentTimeStamp = time
            vc.homeController?.reloadFirebaseData()
            
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
