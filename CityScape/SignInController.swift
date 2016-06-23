//
//  SignInController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-23.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import FLAnimatedImage

class SignInController: UIViewController {

    //Outlets
    @IBOutlet weak var doneOutlet: UIBarButtonItem!
    @IBOutlet weak var gifImage: FLAnimatedImageView!
    
    
    
    //Actions
    @IBAction func cancelAction(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        
        
        
    }
    
    
    @IBAction func forgotPassword(sender: AnyObject) {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("forgotPassword") as! ForgotPasswordController
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
    }
    
    
    //Functions
    func loadGif() {
        
        guard let filePath: String = NSBundle.mainBundle().pathForResource("background", ofType: "gif") else {return}
        let gifData: NSData = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
        let image: FLAnimatedImage = FLAnimatedImage.init(GIFData: gifData)
        gifImage.animatedImage = image
        
    }
    
    
    
    
    //Launch Calls
    override func viewDidLoad() {
        super.viewDidLoad()

        
        doneOutlet.enabled = false
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        loadGif()
        
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
