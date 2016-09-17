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
    
    @IBOutlet weak var chatProfileOutlet: TopChatProfileView!
    @IBOutlet weak var chatNameOutlet: UILabel!
    
    
    @IBOutlet weak var topChatBoxView: UIView!
    
    //Toggle Actions
    @IBAction func toggleNearby(sender: AnyObject) {
        
       rootController?.toggleNearby({ (bool) in
        
            print("nearby toggled")
        
       })
    }

    @IBAction func toggleVibes(sender: AnyObject) {
        
        rootController?.toggleVibes({ (bool) in
            
            print("vibes toggled")
            
        })
    }

    @IBAction func toggleMessages(sender: AnyObject) {
    
        rootController?.toggleMessages({ (bool) in
            
            print("messages toggled")
            
        })
    }

    
    //Highlight Actions
    @IBAction func nearbyHighlight(sender: AnyObject) {
        toggleColour(1)
    }

    @IBAction func vibesHighlight(sender: AnyObject) {
        toggleColour(2)
    }

    @IBAction func messagesHighlight(sender: AnyObject) {
        toggleColour(3)
    }

    
    //Toggle Outside Actions
    @IBAction func nearbyOutside(sender: AnyObject) {
        
        rootController?.toggleNearby({ (bool) in
            
            print("nearby toggled")
            
        })

    }

    @IBAction func vibesOutside(sender: AnyObject) {
        
        rootController?.toggleVibes({ (bool) in
        
            print("vibes toggled")
            
        })
        
    }

    @IBAction func messagesOutside(sender: AnyObject) {
        
        rootController?.toggleMessages({ (bool) in
            
            print("messages toggled")
            
        })
        
    }
  
    
    func toggleColour(button: Int) {
        
        if button == 1 {
            
            nearbyViewOutlet.backgroundColor = UIColor.whiteColor()
            nearbyButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), forState: .Normal)
            
            vibesViewOutlet.backgroundColor = UIColor.clearColor()
            torontoOutlet.textColor = UIColor.whiteColor()
            vibesOutlet.textColor = UIColor.whiteColor()
            
            messagesViewOutlet.backgroundColor = UIColor.clearColor()
            messagesButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
        } else if button == 2 {
            
            nearbyViewOutlet.backgroundColor = UIColor.clearColor()
            nearbyButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            vibesViewOutlet.backgroundColor = UIColor.whiteColor()
            torontoOutlet.textColor = UIColor(netHex: 0xDF412E)
            vibesOutlet.textColor = UIColor(netHex: 0xDF412E)
            
            messagesViewOutlet.backgroundColor = UIColor.clearColor()
            messagesButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
        } else if button == 3 {
            
            nearbyViewOutlet.backgroundColor = UIColor.clearColor()
            nearbyButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            vibesViewOutlet.backgroundColor = UIColor.clearColor()
            torontoOutlet.textColor = UIColor.whiteColor()
            vibesOutlet.textColor = UIColor.whiteColor()
            
            messagesViewOutlet.backgroundColor = UIColor.whiteColor()
            messagesButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), forState: .Normal)
            
        }
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        
        torontoOutlet.adjustsFontSizeToFitWidth = true
        torontoOutlet.baselineAdjustment = .None
        
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
