//
//  LogInController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-16.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import FLAnimatedImage
import Firebase
import FirebaseDatabase

class LogInController: UIViewController {
    
    //Outlets
    @IBOutlet weak var gifBackground: FLAnimatedImageView!
    
    
    //Actions
    @IBAction func register(sender: AnyObject) {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("signUp") as! UINavigationController
        presentViewController(vc, animated: true, completion: nil)
                
    }
    
    
    
    @IBAction func signIn(sender: AnyObject) {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SignIn") as! UINavigationController
        presentViewController(vc, animated: true, completion: nil)
        
        
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        loadGif()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Functions
    func loadGif() {
        
        guard let filePath: String = NSBundle.mainBundle().pathForResource("background", ofType: "gif") else {return}
        let gifData: NSData = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
        let image: FLAnimatedImage = FLAnimatedImage.init(GIFData: gifData)
        gifBackground.animatedImage = image
        
    }
    
    
    
    /*
     var actualNumber: String = ""
     
     if let actualCharacters = self.mobileNumber.text?.characters {
     
     for char in actualCharacters {
     
     if char == "0" || char == "1" || char == "2" || char == "3" || char == "4" || char == "5" || char == "6" || char == "7" || char == "8" || char == "9" {
     
     actualNumber.append(char)
     
     }
     }
     }
     
     print(actualNumber)
     */


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
