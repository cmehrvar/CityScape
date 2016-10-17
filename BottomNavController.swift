//
//  BottomNavController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-15.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class BottomNavController: UIViewController {
    
    //Variables
    weak var rootController: MainRootController?
    
    //Outlets
    @IBOutlet weak var nearbyViewOutlet: NavButtonView!
    @IBOutlet weak var vibesViewOutlet: NavButtonView!
    @IBOutlet weak var messagesViewOutlet: NavButtonView!
    @IBOutlet weak var nearbyButtonOutlet: UIButton!
    @IBOutlet weak var torontoOutlet: UILabel!
    @IBOutlet weak var vibesOutlet: UILabel!
    @IBOutlet weak var vibesButtonOutlet: UIButton!
    @IBOutlet weak var messagesButtonOutlet: UIButton!

    //Toggle Actions
    @IBAction func toggleNearby(_ sender: AnyObject) {
        
       rootController?.toggleNearby({ (bool) in
        
            print("nearby toggled", terminator: "")
        
       })
    }

    @IBAction func toggleVibes(_ sender: AnyObject) {
        
        rootController?.toggleVibes({ (bool) in
            
            print("vibes toggled", terminator: "")
            
        })
    }

    @IBAction func toggleMessages(_ sender: AnyObject) {
    
        rootController?.toggleMessages({ (bool) in
            
            print("messages toggled", terminator: "")
            
        })
    }

    
    //Highlight Actions
    @IBAction func nearbyHighlight(_ sender: AnyObject) {
        toggleColour(1)
    }

    @IBAction func vibesHighlight(_ sender: AnyObject) {
        toggleColour(2)
    }

    @IBAction func messagesHighlight(_ sender: AnyObject) {
        toggleColour(3)
    }

    
    //Toggle Outside Actions
    @IBAction func nearbyOutside(_ sender: AnyObject) {
        
        rootController?.toggleNearby({ (bool) in
            
            print("nearby toggled", terminator: "")
            
        })

    }

    @IBAction func vibesOutside(_ sender: AnyObject) {
        
        rootController?.toggleVibes({ (bool) in
        
            print("vibes toggled", terminator: "")
            
        })
        
    }

    @IBAction func messagesOutside(_ sender: AnyObject) {
        
        rootController?.toggleMessages({ (bool) in
            
            print("messages toggled", terminator: "")
            
        })
        
    }
  
    
    func toggleColour(_ button: Int) {
        
        if button == 1 {
            
            nearbyViewOutlet.backgroundColor = UIColor.white
            nearbyButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), for: UIControlState())
            
            vibesViewOutlet.backgroundColor = UIColor.clear
            torontoOutlet.textColor = UIColor.white
            vibesOutlet.textColor = UIColor.white
            
            messagesViewOutlet.backgroundColor = UIColor.clear
            messagesButtonOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
        } else if button == 2 {
            
            nearbyViewOutlet.backgroundColor = UIColor.clear
            nearbyButtonOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
            vibesViewOutlet.backgroundColor = UIColor.white
            torontoOutlet.textColor = UIColor(netHex: 0xDF412E)
            vibesOutlet.textColor = UIColor(netHex: 0xDF412E)
            
            messagesViewOutlet.backgroundColor = UIColor.clear
            messagesButtonOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
        } else if button == 3 {
            
            nearbyViewOutlet.backgroundColor = UIColor.clear
            nearbyButtonOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
            vibesViewOutlet.backgroundColor = UIColor.clear
            torontoOutlet.textColor = UIColor.white
            vibesOutlet.textColor = UIColor.white
            
            messagesViewOutlet.backgroundColor = UIColor.white
            messagesButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), for: UIControlState())
            
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        torontoOutlet.adjustsFontSizeToFitWidth = true
        torontoOutlet.baselineAdjustment = .none
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        nearbyButtonOutlet.adjustsImageWhenHighlighted = false
        messagesButtonOutlet.adjustsImageWhenHighlighted = false

       
        
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
