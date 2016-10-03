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
    
    //Outlets
    @IBOutlet weak var numberOfNotificationsOutlet: UILabel!
    @IBOutlet weak var numberOfNotificationsViewOutlet: NotificationNumberIndicatorView!
    

    //Actions
    @IBAction func toggleMenu(sender: AnyObject) {
        
        rootController?.toggleMenu({ (bool) in
            
            print("menu toggled")
            
        })
    }
    
    
    @IBAction func toggleNotification(sender: AnyObject) {
        
                
        rootController?.toggleNotifications({ (bool) in
            
            print("notification toggled")
            
        })
    }
    
    
    @IBAction func logoToHome(sender: AnyObject) {
        
        rootController?.toggleHome({ (bool) in
            
            print("home toggled")
            
        })
    }
    
    var imageView = UIImageView()
    
    override func viewDidAppear(animated: Bool) {
        
        imageView.frame = view.bounds
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView = UIImageView(image: UIImage(named: "topGradient"))
        imageView.contentMode = .ScaleAspectFill
        view.addSubview(imageView)
        
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
