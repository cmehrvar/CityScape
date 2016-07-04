//
//  MainRootController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-30.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class MainRootController: UIViewController {
    
    let drawerWidthConstant: CGFloat = 280.0
    var menuIsRevealed = false
    
    
    //Outlets
    @IBOutlet weak var mainLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!
    
    
    weak var homeController: HomeController?
    weak var menuController: MenuController?
    
    
    //Functions
    func setMenuStage() {
        
        menuLeadingConstraint.constant = -drawerWidthConstant
        
    }
    
    func toggleMenu(completion: (Bool) -> ()) {
        
        var panelOffset: CGFloat = 0
        var mainLeading: CGFloat = 0
        var mainTrailing: CGFloat = 0
        var closeMenuAlpha: CGFloat = 0
        
        if menuIsRevealed {
            
            panelOffset = -drawerWidthConstant
            
        } else {
            
            closeMenuAlpha = 1
            mainLeading = drawerWidthConstant
            mainTrailing = -drawerWidthConstant
            
        }
        
        menuIsRevealed = !menuIsRevealed
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.homeController?.closeMenuOutlet.alpha = closeMenuAlpha
            self.menuLeadingConstraint.constant = panelOffset
            self.mainLeadingConstraint.constant = mainLeading
            self.mainTrailingConstraint.constant = mainTrailing
            self.view.layoutIfNeeded()

            }) { (complete) in
                
                completion(complete)
                
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMenuStage()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "homeSegue" {
            
            let home = segue.destinationViewController as? HomeController
            homeController = home
            homeController?.rootController = self
            
            
        } else if segue.identifier == "menuSegue" {
            
            let menu = segue.destinationViewController as? MenuController
            menuController = menu
            menuController?.rootController = self
            
            
        }

        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
