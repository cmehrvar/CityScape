//
//  ProfileSignUpController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-22.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import FLAnimatedImage

class ProfileSignUpController: UIViewController {
    
    @IBOutlet weak var nextButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var gif: FLAnimatedImageView!
    
    @IBAction func nextButton(sender: AnyObject) {
        
        
        
        
    }
    
    func loadGif() {
        
        guard let filePath: String = NSBundle.mainBundle().pathForResource("background", ofType: "gif") else {return}
        let gifData: NSData = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
        let image: FLAnimatedImage = FLAnimatedImage.init(GIFData: gifData)
        gif.animatedImage = image
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadGif()
        
        nextButtonOutlet.enabled = false

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
