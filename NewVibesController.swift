//
//  NewVibesController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-02.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class NewVibesController: UIViewController, UIGestureRecognizerDelegate {
    
    //Variables
    weak var rootController: MainRootController?

    
    
    //Functions
    func addGestureRecognizers(){
        
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showNav))
        downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        downSwipeGestureRecognizer.delegate = self
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showMessages))
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        leftSwipeGestureRecognizer.delegate = self
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showNearby))
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        rightSwipeGestureRecognizer.delegate = self
        
        self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.view.addGestureRecognizer(downSwipeGestureRecognizer)
        
    }
    
    func showNav(){
        
        rootController?.showNav({ (bool) in
            
            print("nav showed")
            
        })
    }
    
    func showNearby(){
        
        rootController?.toggleNearby({ (bool) in
            
            print("nearby toggled")
            
        })
    }
    
    func showMessages(){
        
        rootController?.toggleMessages({ (bool) in
            
            print("messages toggled")
            
        })
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGestureRecognizers()

        // Do any additional setup after loading the view.
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
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
