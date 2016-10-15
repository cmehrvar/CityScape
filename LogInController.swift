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
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import NYAlertViewController

class LogInController: UIViewController {
    
    weak var termsController: TermsOfServiceController?

    //Outlets
    @IBOutlet weak var gifBackground: FLAnimatedImageView!
    @IBOutlet weak var neverPost: UILabel!
    @IBOutlet weak var termsOfService: UIButton!
    @IBOutlet weak var exploreCityOutlet: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var termsContainer: UIView!
    
    //Actions
    @IBAction func terms(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3) { 
            
            self.termsContainer.alpha = 1
            self.view.layoutIfNeeded()
            
        } 
    }

    @IBAction func facebookSignIn(sender: AnyObject) {

        let alertController = NYAlertViewController()
        
        alertController.backgroundTapDismissalGestureEnabled = true
        
        alertController.title = nil
        alertController.message = "Do you agree to the terms of service Atlas has provided?"
        
        alertController.messageColor = UIColor.darkGrayColor()
        
        alertController.buttonColor = UIColor.redColor()
        alertController.buttonTitleColor = UIColor.whiteColor()
        
        alertController.cancelButtonTitleColor = UIColor.whiteColor()
        alertController.cancelButtonColor = UIColor.lightGrayColor()

        alertController.addAction(NYAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
 
        alertController.addAction(NYAlertAction(title: "Agree", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: {
                
                let login: FBSDKLoginManager = FBSDKLoginManager()
                login.logInWithReadPermissions(["email", "user_birthday", "user_relationship_details", "user_work_history", "user_location"], fromViewController: self) { (result, error) in
                    
                    if error == nil {
                        
                        print("logged in")
                        if FBSDKAccessToken.currentAccessToken() != nil {
                            
                            UIView.animateWithDuration(0.3) {
                                self.loadingView.alpha = 1
                            }
                            
                            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                            
                            FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) -> Void in
                                
                                if error == nil {
                                    
                                    if let uid = user?.uid {
                                        
                                        self.checkIfTaken("users", credential: uid, completion: { (taken) in
                                            
                                            if !taken {
                                                
                                                let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name, gender, birthday, age_range, interested_in, work, location, picture"], tokenString: result.token.tokenString, version: nil, HTTPMethod: "GET")
                                                
                                                req.startWithCompletionHandler({ (connection, graphResult, error) -> Void in
                                                    
                                                    if error == nil {
                                                        
                                                        var userData = [NSObject : AnyObject]()
                                                        
                                                        print(graphResult["picture"])
                                                        
                                                        if let birthday = graphResult["birthday"] as? String {
                                                            
                                                            let dateFormatter = NSDateFormatter()
                                                            dateFormatter.dateFormat = "MM-dd-yyyy"
                                                            
                                                            if let date = dateFormatter.dateFromString(birthday) {
                                                                
                                                                let timeInterval = date.timeIntervalSince1970
                                                                userData["age"] = timeInterval
                                                                
                                                            } else if let ageRange = graphResult["age_range"] as? [String : Int], let minAge = ageRange["min"] {
                                                                
                                                                userData["minAge"] = minAge
                                                                
                                                            }
                                                        }
                                                        
                                                        if let email = graphResult["email"] as? String {
                                                            userData["email"] = email
                                                        }
                                                        
                                                        if let gender = graphResult["gender"] as? String {
                                                            userData["gender"] = gender
                                                        }
                                                        
                                                        if let id = graphResult["id"] as? String {
                                                            userData["profilePicture"] = "https://graph.facebook.com/" + id + "/picture?type=large"
                                                        }
                                                        
                                                        if let interested_in = graphResult["interested_in"] as? [String] {
                                                            
                                                            var interestedGenders = [String]()
                                                            
                                                            for i in 0..<interested_in.count {
                                                                interestedGenders.append(interested_in[i])
                                                            }
                                                            
                                                            userData["interestedIn"] = interestedGenders
                                                            
                                                        }
                                                        
                                                        if let firstName = graphResult["first_name"] as? String {
                                                            
                                                            userData["firstName"] = firstName
                                                            
                                                        }
                                                        
                                                        if let lastName = graphResult["last_name"] as? String {
                                                            
                                                            userData["lastName"] = lastName
                                                            
                                                        }
                                                        
                                                        if let occupations = graphResult["work"] as? [[NSObject:AnyObject]], latest = occupations.first, position = latest["position"] as? [NSObject : AnyObject], name = position["name"] as? String, employer = latest["employer"] as? [NSObject : AnyObject], employerName = employer["name"] as? String{
                                                            
                                                            userData["employer"] = employerName
                                                            userData["occupation"] = name
                                                            
                                                        }
                                                        
                                                        if let currentCity = graphResult["location"] as? [String : AnyObject], name = currentCity["name"] as? String {
                                                            
                                                            let components = name.componentsSeparatedByString(", ")
                                                            
                                                            if components.count >= 1 {
                                                                userData["city"] = components[0]
                                                            }
                                                            
                                                            if components.count == 2 {
                                                                userData["state"] = components[1]
                                                            }
                                                        }
                                                        
                                                        userData["nearbyRadius"] = 10
                                                        userData["userScore"] = 0
                                                        userData["uid"] = uid
                                                        userData["online"] = true
                                                        userData["lastActive"] = NSDate().timeIntervalSince1970
                                                        
                                                        let ref = FIRDatabase.database().reference()
                                                        
                                                        ref.child("lastCityRank").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                                            
                                                            if let rank = snapshot.value as? Int {
                                                                
                                                                userData["cityRank"] = rank + 1
                                                                
                                                                ref.child("lastCityRank").setValue(rank + 1)
                                                                ref.child("users").child(uid).setValue(userData)
                                                                ref.child("userScores").child(uid).setValue(0)
                                                                ref.child("userUIDs").child(uid).setValue(true)
                                                                
                                                                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
                                                                
                                                                self.presentViewController(vc, animated: true, completion: {
                                                                    
                                                                    vc.setStage()
                                                                    
                                                                    if let city = userData["city"] as? String {
                                                                        
                                                                        vc.vibesFeedController?.currentCity = city
                                                                        vc.vibesFeedController?.observeCurrentCityPosts()
                                                                        
                                                                    }
                                                                    
                                                                    
                                                                    
                                                                    vc.loadSelfData({ (userData) in
                                                                        
                                                                        print("first time selfData loaded")
                                                                        
                                                                        if userData["interestedIn"] == nil {
                                                                            
                                                                            vc.askInterestedIn()
                                                                            
                                                                        } else {
                                                                            
                                                                            vc.nearbyController?.requestWhenInUseAuthorization()
                                                                            vc.nearbyController?.updateLocation()
                                                                            
                                                                        }
                                                                        
                                                                    })
                                                                    
                                                                    vc.toggleNearby({ (bool) in
                                                                        
                                                                        print("nearby toggled")
                                                                        
                                                                    })
                                                                })
                                                                
                                                            }
                                                        })
                                                        
                                                    } else {
                                                        print(error)
                                                    }
                                                })
                                                
                                            } else {
                                                
                                                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
                                                
                                                self.presentViewController(vc, animated: true, completion: {
                                                    
                                                    vc.setStage()
                                                    
                                                    vc.loadSelfData({ (value) in
                                                        
                                                        print("self data loaded")
                                                        
                                                        if value ["interestedIn"] != nil {
                                                            
                                                            if let latitude = value["latitude"] as? CLLocationDegrees, longitude = value["longitude"] as? CLLocationDegrees {
                                                                
                                                                let location = CLLocation(latitude: latitude, longitude: longitude)
                                                                vc.nearbyController?.queryNearby(location)
                                                                
                                                            }
                                                            
                                                        } else {
                                                            
                                                            vc.askInterestedIn()
                                                            
                                                        }
                                                    })
                                                    
                                                    vc.toggleNearby({ (bool) in
                                                        
                                                        print("nearby toggled")
                                                        
                                                    })
                                                })
                                            }
                                        })
                                    }
                                    
                                } else {
                                    print(error)
                                }
                            })
                        }
                        
                    } else if result.isCancelled{
                        UIView.animateWithDuration(0.3) {
                            self.loadingView.alpha = 0
                        }
                    } else {
                        UIView.animateWithDuration(0.3) {
                            self.loadingView.alpha = 0
                        }
                    }
                }
            })
        }))
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func checkIfTaken(key: String, credential: String, completion: (taken: Bool) -> ()) {
        
        let ref = FIRDatabase.database().reference()
        
        ref.child(key).child(credential).observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            
            completion(taken: snapshot.exists())
            
        })
    }

    func handleFont(){
        
        self.neverPost.adjustsFontSizeToFitWidth = true
        self.exploreCityOutlet.adjustsFontSizeToFitWidth = true
        
    }
    
    
    var attrs = [
        NSFontAttributeName : UIFont.systemFontOfSize(12.0),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSUnderlineStyleAttributeName : 1]
    
    var attributedString = NSMutableAttributedString(string:"")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonTitleStr = NSMutableAttributedString(string:"Terms of Service", attributes:attrs)
        attributedString.appendAttributedString(buttonTitleStr)
        termsOfService.setAttributedTitle(attributedString, forState: .Normal)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        handleFont()
        loadGif()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Functions
    func loadGif() {
        
        if let filePath = NSBundle.mainBundle().pathForResource("background", ofType: "gif"), gifData = NSData(contentsOfFile: filePath) {
            
            let image: FLAnimatedImage = FLAnimatedImage.init(GIFData: gifData)
            gifBackground.animatedImage = image
            
        }
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "termsSegue" {
            
            let terms = segue.destinationViewController as! TermsOfServiceController
            termsController = terms
            termsController?.logInController = self
            //termsController.log
            
            
        }
        
        
        
     }
    
    
}
