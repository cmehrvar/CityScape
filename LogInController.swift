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
    @IBAction func terms(_ sender: AnyObject) {
        
        UIView.animate(withDuration: 0.3, animations: { 
            
            self.termsContainer.alpha = 1
            self.view.layoutIfNeeded()
            
        })  
    }

    @IBAction func facebookSignIn(_ sender: AnyObject) {

        let alertController = NYAlertViewController()
        
        alertController.backgroundTapDismissalGestureEnabled = true
        
        alertController.title = nil
        alertController.message = "Do you agree to the terms of service Atlas has provided?"
        
        alertController.messageColor = UIColor.darkGray
        
        alertController.buttonColor = UIColor.red
        alertController.buttonTitleColor = UIColor.white
        
        alertController.cancelButtonTitleColor = UIColor.white
        alertController.cancelButtonColor = UIColor.lightGray

        alertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
 
        alertController.addAction(NYAlertAction(title: "Agree", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: {
                
                let login: FBSDKLoginManager = FBSDKLoginManager()
                login.logIn(withReadPermissions: ["email", "user_birthday", "user_relationship_details", "user_work_history", "user_location"], from: self) { (result, error) in
                    
                    if error == nil {
                        
                        print(result?.token.userID)
                        
                        print("logged in")
                        if FBSDKAccessToken.current() != nil {
    
                            UIView.animate(withDuration: 0.3, animations: {
                                self.loadingView.alpha = 1
                            }) 
                            
                            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                            
                            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) -> Void in
                                
                                if error == nil {
                                    
                                    if let uid = user?.uid {
                                        
                                        self.checkIfTaken("users", credential: uid, completion: { (taken) in
                                            
                                            if !taken {
                                                
                                                if let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name, gender, birthday, age_range, interested_in, work, location, picture"], tokenString: result?.token.tokenString, version: nil, httpMethod: "GET") {
                                                    
                                                    req.start(completionHandler: { (connection, result, error) in
                                                        
                                                        if error == nil {
                                                            
                                                            if let graphResult = result as? [AnyHashable : Any] {
                                                                
                                                                var userData = [AnyHashable: Any]()
                                                                
                                                                print(graphResult["picture"])
                                                                
                                                                if let birthday = graphResult["birthday"] as? String {
                                                                    
                                                                    let dateFormatter = DateFormatter()
                                                                    dateFormatter.dateFormat = "MM-dd-yyyy"
                                                                    
                                                                    if let date = dateFormatter.date(from: birthday) {
                                                                        
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
                                                                
                                                                if let occupations = graphResult["work"] as? [[AnyHashable: Any]], let latest = occupations.first, let position = latest["position"] as? [AnyHashable: Any], let name = position["name"] as? String, let employer = latest["employer"] as? [AnyHashable: Any], let employerName = employer["name"] as? String{
                                                                    
                                                                    userData["employer"] = employerName
                                                                    userData["occupation"] = name
                                                                    
                                                                }
                                                                
                                                                if let currentCity = graphResult["location"] as? [String : AnyObject], let name = currentCity["name"] as? String {
                                                                    
                                                                    let components = name.components(separatedBy: ", ")
                                                                    
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
                                                                userData["lastActive"] = Date().timeIntervalSince1970
                                                                
                                                                let ref = FIRDatabase.database().reference()
                                                                
                                                                ref.child("lastCityRank").observeSingleEvent(of: .value, with: { (snapshot) in
                                                                    
                                                                    if let rank = snapshot.value as? Int {
                                                                        
                                                                        userData["cityRank"] = rank + 1
                                                                        
                                                                        ref.child("lastCityRank").setValue(rank + 1)
                                                                        ref.child("users").child(uid).setValue(userData)
                                                                        
                                                                        if let facebookUID = FBSDKAccessToken.current().userID {
                                                                            
                                                                            ref.child("facebookUIDs").child(facebookUID).setValue(uid)
                                                                            
                                                                        }
                                                                        
                                                                        ref.child("userScores").child(uid).setValue(0)
                                                                        ref.child("userUIDs").child(uid).setValue(true)
                                                                        
                                                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainRootController") as! MainRootController
                                                                        
                                                                        self.present(vc, animated: true, completion: {
                                                                            
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
                                                            }
                                                        }
                                                    })
                                                    
                                                }
  
                                            } else {
                                                
                                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainRootController") as! MainRootController
                                                
                                                self.present(vc, animated: true, completion: {
                                                    
                                                    vc.setStage()
                                                    
                                                    vc.loadSelfData({ (value) in
                                                        
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
                        
                    } else if (result?.isCancelled)!{
                        UIView.animate(withDuration: 0.3, animations: {
                            self.loadingView.alpha = 0
                        }) 
                    } else {
                        UIView.animate(withDuration: 0.3, animations: {
                            self.loadingView.alpha = 0
                        }) 
                    }
                }
            })
        }))
        
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func checkIfTaken(_ key: String, credential: String, completion: @escaping (_ taken: Bool) -> ()) {
        
        let ref = FIRDatabase.database().reference()
        
        ref.child(key).child(credential).observeSingleEvent(of: .value, with:  { (snapshot) in
            
            if snapshot.exists() {
                
                if let value = snapshot.value as? [AnyHashable: Any] {
                    
                    if value["uid"] == nil {
                        
                        completion(false)
                        
                    } else {
                        
                        completion(true)
                        
                    }
                    
                } else {
                    
                    completion(false)
 
                }

            } else {
                
                completion(false)
                
            }
            
            completion(snapshot.exists())
            
        })
    }

    func handleFont(){
        
        self.neverPost.adjustsFontSizeToFitWidth = true
        self.exploreCityOutlet.adjustsFontSizeToFitWidth = true
        
    }
    
    
    var attrs = [
        NSFontAttributeName : UIFont.systemFont(ofSize: 12.0),
        NSForegroundColorAttributeName : UIColor.white,
        NSUnderlineStyleAttributeName : 1] as [String : Any]
    
    var attributedString = NSMutableAttributedString(string:"")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonTitleStr = NSMutableAttributedString(string:"Terms of Service", attributes:attrs)
        attributedString.append(buttonTitleStr)
        termsOfService.setAttributedTitle(attributedString, for: UIControlState())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        handleFont()
        loadGif()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Functions
    func loadGif() {
        
        if let filePath = Bundle.main.path(forResource: "background", ofType: "gif"), let gifData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
            
            let image: FLAnimatedImage = FLAnimatedImage.init(gifData: gifData)
            gifBackground.animatedImage = image
            
        }
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.

        if segue.identifier == "termsSegue" {
            
            let terms = segue.destination as! TermsOfServiceController
            termsController = terms
            termsController?.logInController = self
 
        } 
     }
    
    
}
