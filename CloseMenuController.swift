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
    
    @IBAction func closeMenu(_ sender: AnyObject) {
        
        if let menuRevealed = rootController?.menuIsRevealed, let notificationRevealed = rootController?.notificationRevealed {
            
            if menuRevealed {
                
                if let keyboardShown = self.rootController?.menuController?.keyboardShown {
                    
                    if keyboardShown {
                        
                        self.rootController?.menuController?.view.endEditing(true)
                        
                    } else {
                        
                        rootController?.toggleMenu({ (bool) in
                            
                            print("menu closed", terminator: "")
                            
                        })
                    }
                }
                
            } else if notificationRevealed {
                
                rootController?.toggleNotifications({ (bool) in
                    
                    print("notifications toggled", terminator: "")
                    
                })
            }
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
