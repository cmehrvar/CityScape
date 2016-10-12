//
//  TermsOfServiceController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-10-12.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class TermsOfServiceController: UIViewController {
    
    weak var logInController: LogInController?

    
    @IBAction func back(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3) { 
            
            //self.logInController.termsC
            self.logInController?.termsContainer.alpha = 0
            self.logInController?.view.layoutIfNeeded()
            
        }
        
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
