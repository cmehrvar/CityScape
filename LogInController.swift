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

class LogInController: UIViewController {
    
    
    //Outlets
    @IBOutlet weak var gifBackground: FLAnimatedImageView!
    @IBOutlet weak var neverPost: UILabel!
    @IBOutlet weak var termsOfService: UIButton!
    @IBOutlet weak var exploreCityOutlet: UILabel!
    @IBOutlet weak var loadingView: UIView!
    
    //Actions
    @IBAction func facebookSignIn(sender: AnyObject) {

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
                                        
                                        let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name, gender, birthday, age_range, interested_in, work, location"], tokenString: result.token.tokenString, version: nil, HTTPMethod: "GET")
                                        
                                        req.startWithCompletionHandler({ (connection, graphResult, error) -> Void in
                                            
                                            if error == nil {
                                                
                                                var userData = [NSObject : AnyObject]()
                                                
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
                                                userData["uid"] = uid
                                                userData["online"] = true
                                                userData["lastActive"] = NSDate().timeIntervalSince1970
                                                
                                                let ref = FIRDatabase.database().reference()
                                                
                                                ref.child("lastCityRank").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                                    
                                                    if let lastRank = snapshot.value as? Int {
                                                        userData["cityRank"] = lastRank + 1
                                                        ref.child("lastCityRank").setValue(lastRank + 1)
                                                    }
                                                    
                                                    ref.child("users").child(uid).setValue(userData)
                                                    ref.child("userScores").child(uid).setValue(0)
                                                    
                                                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
                                                    
                                                    self.presentViewController(vc, animated: true, completion: {
                                                        
                                                        self.loadingView.alpha = 0
                                                        
                                                        vc.loadSelfData({ (bool) in
                                                            print("self data loaded")
                                                        })
                                                        
                                                        vc.toggleNearby({ (bool) in
                                                            print("nearby toggled")
                                                        })
                                                        
                                                    })
                                                })

                                            } else {
                                                print(error)
                                            }
                                        })
  
                                    } else {
                                        
                                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
                                        
                                        self.presentViewController(vc, animated: true, completion: {
                                            
                                            vc.loadSelfData({ (bool) in
                                                print("self data loaded")
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
