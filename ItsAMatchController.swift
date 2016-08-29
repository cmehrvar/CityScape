//
//  ItsAMatchController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-27.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ItsAMatchController: UIViewController {

    //Outlets
    @IBOutlet weak var itsAOutlet: UILabel!
    @IBOutlet weak var matchOutlet: UILabel!
    @IBOutlet weak var likesYouOutlet: UILabel!
    @IBOutlet weak var profilesViewHeightOutlet: NSLayoutConstraint!
    @IBOutlet weak var myProfileOutlet: MatchProfileViews!
    @IBOutlet weak var yourProfileOutlet: MatchProfileViews!
    @IBOutlet weak var buttonHeightConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var myRankOutlet: UILabel!
    @IBOutlet weak var yourRankOutlet: UILabel!
    @IBOutlet weak var distanceOutlet: UILabel!
    
    
    
    
    //Actions
    
    @IBAction func sendMessage(sender: AnyObject) {
        
        rootController?.toggleMatch(nil, completion: { (bool) in
            
            print("send message")
            
        })
    }
    
    
    @IBAction func keepPlaying(sender: AnyObject) {
        
        rootController?.toggleMatch(nil, completion: { (bool) in
            
            print("keep playing")
            
        })
    }
    
    
    
    //Variables
    weak var rootController: MainRootController?
    
    //Functions
    func setStage() {
        
        let screenWidth = self.view.bounds.width
        let screenHeight = self.view.bounds.height
        
        self.profilesViewHeightOutlet.constant = screenWidth / 2.5
        
        self.buttonHeightConstOutlet.constant = screenHeight / 10
        
        self.myProfileOutlet.layer.cornerRadius = ((screenWidth / 2.5) - 21) / 2
        self.myProfileOutlet.layer.borderWidth = 3
        self.myProfileOutlet.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.yourProfileOutlet.layer.cornerRadius = ((screenWidth / 2.5) - 21) / 2
        self.yourProfileOutlet.layer.borderWidth = 3
        self.yourProfileOutlet.layer.borderColor = UIColor.whiteColor().CGColor
        
    }
    
    //Launch Calls
    override func viewDidAppear(animated: Bool) {
        
        setStage()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        likesYouOutlet.adjustsFontSizeToFitWidth = true
        likesYouOutlet.baselineAdjustment = .None
        likesYouOutlet.sizeToFit()

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
