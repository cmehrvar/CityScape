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
    @IBAction func toggleMenu(_ sender: AnyObject) {
        
        rootController?.toggleMenu({ (bool) in
            
            print("menu toggled", terminator: "")
            
        })
    }
    
    
    @IBAction func toggleNotification(_ sender: AnyObject) {
        
                
        rootController?.toggleNotifications({ (bool) in
            
            print("notification toggled", terminator: "")
            
        })
    }
    
    
    @IBAction func logoToHome(_ sender: AnyObject) {
        
        if let currentTab = rootController?.currentTab {
            
            if currentTab == 1 {
                
                rootController?.nearbyController?.globCollectionView.setContentOffset(CGPoint.zero, animated: true)
                
                if let lastLocation = rootController?.nearbyController?.globLocation {
                    
                    rootController?.nearbyController?.queryNearby(lastLocation)
                    
                }
                
            } else if currentTab == 2 {
                
                rootController?.vibesFeedController?.globCollectionView.setContentOffset(CGPoint.zero, animated: true)
                rootController?.vibesFeedController?.globCollectionView.reloadData()
                
            } else if currentTab == 3 {
                
                rootController?.messagesController?.globTableView.setContentOffset(CGPoint.zero, animated: true)
                rootController?.messagesController?.globTableView.reloadData()
                
            }
        }

        rootController?.toggleHome({ (bool) in
            
            print("home toggled", terminator: "")
            
        })
    }
    
    var imageView = UIImageView()
    
    override func viewDidAppear(_ animated: Bool) {
        
        imageView.frame = view.bounds
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView = UIImageView(image: UIImage(named: "topGradient"))
        imageView.contentMode = .scaleAspectFill
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
