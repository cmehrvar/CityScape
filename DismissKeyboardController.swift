//
//  DismissKeyboardController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-15.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class DismissKeyboardController: UIViewController, UIGestureRecognizerDelegate {
    
    weak var rootController: MainRootController?

    func tapHandler(){
        
        rootController?.dismissKeyboard({ (bool) in
            
            print("keyboard dismissed")
            
        })
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)

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
