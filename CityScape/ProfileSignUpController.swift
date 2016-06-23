//
//  ProfileSignUpController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-22.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import FLAnimatedImage
import DownPicker
import FBSDKLoginKit

class ProfileSignUpController: UIViewController {
    
    //Global Variables
    var nextButton: UIBarButtonItem!
    let cities = ["Vancouver", "Edmonton", "Toronto", "Montreal", "Halifax", "St. Johns"]
    var realDownPicker: DownPicker = DownPicker()
    var firstNameVar: String!
    var lastNameVar: String!
    var profileVar: String!
    
    //Outlets
    @IBOutlet weak var gif: FLAnimatedImageView!
    @IBOutlet weak var downPicker: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var profilePicture: ProfilePictureView!
    
    
    //Actions
    func done(sender: UIBarButtonItem) {
        
        print("next hit")
        
    }

    //Functions
    func loadGif() {
        
        guard let filePath: String = NSBundle.mainBundle().pathForResource("background", ofType: "gif") else {return}
        let gifData: NSData = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
        let image: FLAnimatedImage = FLAnimatedImage.init(GIFData: gifData)
        gif.animatedImage = image
        
    }
    
    func handleDownPicker() {
        
        realDownPicker = DownPicker(textField: downPicker, withData: cities)
        realDownPicker.setPlaceholder("Tap to choose your city")
        realDownPicker.shouldDisplayCancelButton = false
        
    }
    
    func fillFormFromFacebook() {
        
        if firstNameVar != nil {
            
            firstName.text = firstNameVar
            
        }
        
        if lastNameVar != nil {
            
            lastName.text = lastNameVar
            
        }
        
        if profileVar != nil {
            
            print(profileVar)
            profilePicture.sd_setImageWithURL(NSURL(string: profileVar))
            
        }
        
        
    }


    //Launch Calls
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        nextButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "done:")
        self.navigationItem.rightBarButtonItem = nextButton
        nextButton.enabled = false
        loadGif()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        fillFormFromFacebook()
        handleDownPicker()
        loadGif()
        
    }
    
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        
        if parent == nil {
            
            FBSDKLoginManager().logOut()
            
            print("back button hit")
            
        }
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
