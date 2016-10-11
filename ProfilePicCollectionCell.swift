//
//  ProfilePicCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-02.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import AWSS3
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ProfilePicCollectionCell: UICollectionViewCell, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    weak var profileController: ProfileController?
    
    var selfProfile = false
    
    var currentPicture = 1
    var pictures = 1
    
    var uid = ""
    var editedPhoto = ""
    
    var profile1 = ""
    var profile2 = ""
    var profile3 = ""
    var profile4 = ""
    var profile5 = ""
    
    @IBOutlet weak var profilePicOutlet: UIImageView!
    @IBOutlet weak var profilePic2Outlet: UIImageView!
    @IBOutlet weak var profilePic3Outlet: UIImageView!
    @IBOutlet weak var profilePic4Outlet: UIImageView!
    @IBOutlet weak var profilePic5Outlet: UIImageView!
    
    @IBOutlet weak var profilePicCenterConstOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var indicator2WidthConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var indicator3WidthConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var indicator4WidthConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var indicator5WidthConstOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var indicator1Outlet: ProfileCurrentPictureIndicatorVIew!
    @IBOutlet weak var indicator2Outlet: ProfileCurrentPictureIndicatorVIew!
    @IBOutlet weak var indicator3Outlet: ProfileCurrentPictureIndicatorVIew!
    @IBOutlet weak var indicator4Outlet: ProfileCurrentPictureIndicatorVIew!
    @IBOutlet weak var indicator5Outlet: ProfileCurrentPictureIndicatorVIew!
    
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet weak var editImageOutlet: UIImageView!
    
    
    //Actions
    @IBAction func edit(sender: AnyObject) {
        
        print("currentPicture: \(currentPicture)")
        
        if currentPicture == 1 {
            
            callCamera("profilePicture")
            
        } else if currentPicture == 2 {
            
            callCamera("profilePicture2")
            
        } else if currentPicture == 3 {
            
            callCamera("profilePicture3")
            
        } else if currentPicture == 4 {
            
            callCamera("profilePicture4")
            
        } else if currentPicture == 5 {
            
            callCamera("profilePicture5")
            
        }
    }
    
    
    
    
    //Functions
    func swipeLeft(){
        
        print("current picture: \(currentPicture)")
        print("total pictures: \(pictures)")
        print("swipe left")
        
        var scopePictures = pictures
        
        if selfProfile && pictures < 5 {
            
            scopePictures += 1
            
        }

        if currentPicture < scopePictures && scopePictures != 1 {
            
            let screenWidth = self.bounds.width
            
            if currentPicture == 1 {
                
                currentPicture = 2
                profileController?.currentPicture = 2
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -screenWidth
                    
                    self.indicator1Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator2Outlet.backgroundColor = UIColor.lightGrayColor()
                    self.indicator3Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator4Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator5Outlet.backgroundColor = UIColor.clearColor()
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
                
            } else if currentPicture == 2 {
                
                currentPicture = 3
                profileController?.currentPicture = 3
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -(screenWidth*2)
                    
                    self.indicator1Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator2Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator3Outlet.backgroundColor = UIColor.lightGrayColor()
                    self.indicator4Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator5Outlet.backgroundColor = UIColor.clearColor()
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
                
            } else if currentPicture == 3 {
                
                currentPicture = 4
                profileController?.currentPicture = 4
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -(screenWidth * 3)
                    
                    self.indicator1Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator2Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator3Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator4Outlet.backgroundColor = UIColor.lightGrayColor()
                    self.indicator5Outlet.backgroundColor = UIColor.clearColor()
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
                
            } else if currentPicture == 4 {
                
                currentPicture = 5
                profileController?.currentPicture = 5
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -(screenWidth * 4)
                    
                    self.indicator1Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator2Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator3Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator4Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator5Outlet.backgroundColor = UIColor.lightGrayColor()
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
            }
            
        }
    }
    
    func swipeRight(){
        
        print("current picture: \(currentPicture)")
        print("total pictures: \(pictures)")
        print("swipe right")
        
        var scopePictures = pictures
        
        if selfProfile && pictures < 5 {
            
            scopePictures += 1
            
        }

        
        if (currentPicture == scopePictures || currentPicture > 1) && scopePictures != 1 {
            
            let screenWidth = self.bounds.width
            
            if currentPicture == 2 {
                
                currentPicture = 1
                profileController?.currentPicture = 1
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = 0
                    
                    self.indicator1Outlet.backgroundColor = UIColor.lightGrayColor()
                    self.indicator2Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator3Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator4Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator5Outlet.backgroundColor = UIColor.clearColor()
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
                
            } else if currentPicture == 3 {
                
                currentPicture = 2
                profileController?.currentPicture = 2
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -screenWidth
                    
                    self.indicator1Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator2Outlet.backgroundColor = UIColor.lightGrayColor()
                    self.indicator3Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator4Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator5Outlet.backgroundColor = UIColor.clearColor()
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
                
            } else if currentPicture == 4 {
                
                currentPicture = 3
                profileController?.currentPicture = 3
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -(screenWidth * 2)
                    
                    self.indicator1Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator2Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator3Outlet.backgroundColor = UIColor.lightGrayColor()
                    self.indicator4Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator5Outlet.backgroundColor = UIColor.clearColor()
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
                
            } else if currentPicture == 5 {
                
                currentPicture = 4
                profileController?.currentPicture = 4
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -(screenWidth * 3)
                    
                    self.indicator1Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator2Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator3Outlet.backgroundColor = UIColor.clearColor()
                    self.indicator4Outlet.backgroundColor = UIColor.lightGrayColor()
                    self.indicator5Outlet.backgroundColor = UIColor.clearColor()
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
            }
        }
        
        print("right swipe")
        
    }
    
    
    func loadImages(data: [NSObject : AnyObject], screenWidth: CGFloat){

        if let profilePicture = data["profilePicture"] as? String, url = NSURL(string: profilePicture) {
            
            profilePicOutlet.sd_setImageWithURL(url, placeholderImage: nil)
            profile1 = profilePicture
            profileController?.profile1 = profilePicture
            pictures = 1
            
        }
        
        if let profilePicture2 = data["profilePicture2"] as? String, url = NSURL(string: profilePicture2) {
            
            profilePic2Outlet.sd_setImageWithURL(url, placeholderImage: nil)
            profile2 = profilePicture2
            pictures = 2
            
        }
        
        
        if let profilePicture3 = data["profilePicture3"] as? String, url = NSURL(string: profilePicture3) {
            
            profilePic3Outlet.sd_setImageWithURL(url, placeholderImage: nil)
            profile3 = profilePicture3
            pictures = 3
            
        }
        
        if let profilePicture4 = data["profilePicture4"] as? String, url = NSURL(string: profilePicture4) {
            
            profilePic4Outlet.sd_setImageWithURL(url, placeholderImage: nil)
            profile4 = profilePicture4
            pictures = 4
            
        }
        
        if let profilePicture5 = data["profilePicture5"] as? String, url = NSURL(string: profilePicture5) {
            
            profilePic5Outlet.sd_setImageWithURL(url, placeholderImage: nil)
            profile5 = profilePicture5
            pictures = 5
            
        }
        
        if let userUID = data["uid"] as? String {
            
            uid = userUID
            
        }
        
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if selfUID == data["uid"] as? String {
                
                editImageOutlet.alpha = 1
                editButtonOutlet.enabled = true
                
                selfProfile = true
                
                if pictures == 1 {
                    
                    indicator1Outlet.alpha = 1
                    indicator2Outlet.alpha = 1
                    indicator3Outlet.alpha = 0
                    indicator4Outlet.alpha = 0
                    indicator5Outlet.alpha = 0

                    profilePic2Outlet.image = nil
                    
                    indicator2WidthConstOutlet.constant = 24
                    indicator3WidthConstOutlet.constant = 0
                    indicator4WidthConstOutlet.constant = 0
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 2 {
                    
                    indicator1Outlet.alpha = 1
                    indicator2Outlet.alpha = 1
                    indicator3Outlet.alpha = 1
                    indicator4Outlet.alpha = 0
                    indicator5Outlet.alpha = 0

                    profilePic3Outlet.image = nil
                    
                    indicator2WidthConstOutlet.constant = 24
                    indicator3WidthConstOutlet.constant = 24
                    indicator4WidthConstOutlet.constant = 0
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 3 {
                    
                    indicator1Outlet.alpha = 1
                    indicator2Outlet.alpha = 1
                    indicator3Outlet.alpha = 1
                    indicator4Outlet.alpha = 1
                    indicator5Outlet.alpha = 0

                    profilePic4Outlet.image = nil
                    
                    indicator2WidthConstOutlet.constant = 24
                    indicator3WidthConstOutlet.constant = 24
                    indicator4WidthConstOutlet.constant = 24
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 4 {
                    
                    indicator1Outlet.alpha = 1
                    indicator2Outlet.alpha = 1
                    indicator3Outlet.alpha = 1
                    indicator4Outlet.alpha = 1
                    indicator5Outlet.alpha = 1

                    profilePic5Outlet.image = nil
                    
                    indicator2WidthConstOutlet.constant = 24
                    indicator3WidthConstOutlet.constant = 24
                    indicator4WidthConstOutlet.constant = 24
                    indicator5WidthConstOutlet.constant = 24
                    
                } else if pictures == 5 {
                    
                    indicator1Outlet.alpha = 1
                    indicator2Outlet.alpha = 1
                    indicator3Outlet.alpha = 1
                    indicator4Outlet.alpha = 1
                    indicator5Outlet.alpha = 1

                    indicator2WidthConstOutlet.constant = 24
                    indicator3WidthConstOutlet.constant = 24
                    indicator4WidthConstOutlet.constant = 24
                    indicator5WidthConstOutlet.constant = 24
                    
                }
                
                
            } else {
                
                editImageOutlet.alpha = 0
                editButtonOutlet.enabled = false
                selfProfile = false
                
                if pictures == 1 {
                    
                    indicator1Outlet.alpha = 1
                    indicator2Outlet.alpha = 0
                    indicator3Outlet.alpha = 0
                    indicator4Outlet.alpha = 0
                    indicator5Outlet.alpha = 0

                    indicator2WidthConstOutlet.constant = 0
                    indicator3WidthConstOutlet.constant = 0
                    indicator4WidthConstOutlet.constant = 0
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 2 {
                    
                    indicator1Outlet.alpha = 1
                    indicator2Outlet.alpha = 1
                    indicator3Outlet.alpha = 0
                    indicator4Outlet.alpha = 0
                    indicator5Outlet.alpha = 0

                    indicator2WidthConstOutlet.constant = 24
                    indicator3WidthConstOutlet.constant = 0
                    indicator4WidthConstOutlet.constant = 0
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 3 {
                    
                    indicator1Outlet.alpha = 1
                    indicator2Outlet.alpha = 1
                    indicator3Outlet.alpha = 1
                    indicator4Outlet.alpha = 0
                    indicator5Outlet.alpha = 0

                    indicator2WidthConstOutlet.constant = 24
                    indicator3WidthConstOutlet.constant = 24
                    indicator4WidthConstOutlet.constant = 0
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 4 {
                    
                    indicator1Outlet.alpha = 1
                    indicator2Outlet.alpha = 1
                    indicator3Outlet.alpha = 1
                    indicator4Outlet.alpha = 1
                    indicator5Outlet.alpha = 0

                    indicator2WidthConstOutlet.constant = 24
                    indicator3WidthConstOutlet.constant = 24
                    indicator4WidthConstOutlet.constant = 24
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 5 {
                    
                    indicator1Outlet.alpha = 1
                    indicator2Outlet.alpha = 1
                    indicator3Outlet.alpha = 1
                    indicator4Outlet.alpha = 1
                    indicator5Outlet.alpha = 1

                    indicator2WidthConstOutlet.constant = 24
                    indicator3WidthConstOutlet.constant = 24
                    indicator4WidthConstOutlet.constant = 24
                    indicator5WidthConstOutlet.constant = 24
                    
                }
            }
        }
        
        
        if currentPicture == 1 {
            
            profilePicCenterConstOutlet.constant = 0
            
            indicator1Outlet.backgroundColor = UIColor.lightGrayColor()
            indicator2Outlet.backgroundColor = UIColor.clearColor()
            indicator3Outlet.backgroundColor = UIColor.clearColor()
            indicator4Outlet.backgroundColor = UIColor.clearColor()
            indicator5Outlet.backgroundColor = UIColor.clearColor()
            
        } else if currentPicture == 2 {
            
            profilePicCenterConstOutlet.constant = -(screenWidth)
            
            indicator1Outlet.backgroundColor = UIColor.clearColor()
            indicator2Outlet.backgroundColor = UIColor.lightGrayColor()
            indicator3Outlet.backgroundColor = UIColor.clearColor()
            indicator4Outlet.backgroundColor = UIColor.clearColor()
            indicator5Outlet.backgroundColor = UIColor.clearColor()
            
        } else if currentPicture == 3 {
            
            profilePicCenterConstOutlet.constant = -(screenWidth * 2)
            
            indicator1Outlet.backgroundColor = UIColor.clearColor()
            indicator2Outlet.backgroundColor = UIColor.clearColor()
            indicator3Outlet.backgroundColor = UIColor.lightGrayColor()
            indicator4Outlet.backgroundColor = UIColor.clearColor()
            indicator5Outlet.backgroundColor = UIColor.clearColor()
            
        } else if currentPicture == 4 {
            
            profilePicCenterConstOutlet.constant = -(screenWidth * 3)
            
            indicator1Outlet.backgroundColor = UIColor.clearColor()
            indicator2Outlet.backgroundColor = UIColor.clearColor()
            indicator3Outlet.backgroundColor = UIColor.clearColor()
            indicator4Outlet.backgroundColor = UIColor.lightGrayColor()
            indicator5Outlet.backgroundColor = UIColor.clearColor()
            
        } else if currentPicture == 5 {
            
            profilePicCenterConstOutlet.constant = -(screenWidth * 4)
            
            indicator1Outlet.backgroundColor = UIColor.clearColor()
            indicator2Outlet.backgroundColor = UIColor.clearColor()
            indicator3Outlet.backgroundColor = UIColor.clearColor()
            indicator4Outlet.backgroundColor = UIColor.clearColor()
            indicator5Outlet.backgroundColor = UIColor.lightGrayColor()
            
        }
        
        addSwipeGesture()
        
    }
    
    
    
    
    func callCamera(imageToEdit: String){
        
        let scopeCurrentPicture = currentPicture
        let scopePictures = pictures
        
        let scopeProfile1 = profile1
        let scopeProfile2 = profile2
        let scopeProfile3 = profile3
        let scopeProfile4 = profile4
        let scopeProfile5 = profile5
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("users").child(selfUID)
            
            let alertController = UIAlertController(title: "What would you like to do?", message: nil, preferredStyle: .ActionSheet)
            
            alertController.addAction(UIAlertAction(title: "Edit Image", style: .Default, handler: { (action) in
                
                print("edit image")
                self.profileController?.presentFusuma(imageToEdit)
                
                
            }))
            
            if scopeCurrentPicture > 1 && scopeCurrentPicture <= scopePictures {

                alertController.addAction(UIAlertAction(title: "Swap with first image", style: .Default, handler: { (action) in
                    
                    print("make first picture")
                    
                    self.currentPicture = 1
                    self.profileController?.currentPicture = 1
                    
                    if scopeCurrentPicture == 2 {

                        ref.child("profilePicture").setValue(scopeProfile2)
                        ref.child("profilePicture2").setValue(scopeProfile1)
                        
                    } else if scopeCurrentPicture == 3 {
                        
                        ref.child("profilePicture").setValue(scopeProfile3)
                        ref.child("profilePicture3").setValue(scopeProfile1)
                        
                    } else if scopeCurrentPicture == 4 {
                        
                        ref.child("profilePicture").setValue(scopeProfile4)
                        ref.child("profilePicture4").setValue(scopeProfile1)
                        
                    } else if scopeCurrentPicture == 5 {
                        
                        ref.child("profilePicture").setValue(scopeProfile5)
                        ref.child("profilePicture5").setValue(scopeProfile1)
                    }
                }))

                
                alertController.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) in
                    
                    print("delete picture")
  
                    if scopeCurrentPicture == 2 {
                        
                        if scopePictures == 2 {
                            
                            self.currentPicture = 1
                            self.profileController?.currentPicture = 1
                            
                            ref.child("profilePicture2").removeValue()
                            
                        } else if scopePictures == 3 {
                            
                            self.currentPicture = 2
                            self.profileController?.currentPicture = 2
                            
                            ref.child("profilePicture2").setValue(scopeProfile3)
                            ref.child("profilePicture3").removeValue()
                            
                            print("third picture becomes second picture")
                            
                        } else if scopePictures == 4 {
                            
                            self.currentPicture = 3
                            self.profileController?.currentPicture = 3
                            
                            print("fourth picture becomes third picture, third picture becomes second picture")
                            ref.child("profilePicture2").setValue(scopeProfile3)
                            ref.child("profilePicture3").setValue(scopeProfile4)
                            ref.child("profilePicture4").removeValue()

                        } else if scopePictures == 5 {
                            
                            self.currentPicture = 4
                            self.profileController?.currentPicture = 4
                            
                            print("fifth picture becomes fourth picture, fourth picture becomes third picture, third picture becomes second picture")
                            ref.child("profilePicture2").setValue(scopeProfile3)
                            ref.child("profilePicture3").setValue(scopeProfile4)
                            ref.child("profilePicture4").setValue(scopeProfile5)
                            ref.child("profilePicture5").removeValue()
                            
                        }
                        
                    } else if scopeCurrentPicture == 3 {
                        
                        if scopePictures == 3 {
                            
                            self.currentPicture = 2
                            self.profileController?.currentPicture = 2
                            
                            ref.child("profilePicture3").removeValue()
                            
                        } else if scopePictures == 4 {
                            
                            self.currentPicture = 3
                            self.profileController?.currentPicture = 3
                            
                            print("fourth becomes third")
                            
                            ref.child("profilePicture3").setValue(scopeProfile4)
                            ref.child("profilePicture4").removeValue()
                            
                            
                        } else if scopePictures == 5 {
                            
                            self.currentPicture = 4
                            self.profileController?.currentPicture = 4
                            
                            print("fifth becomes fourth, fourth becomes third")
                            
                            ref.child("profilePicture3").setValue(scopeProfile4)
                            ref.child("profilePicture4").setValue(scopeProfile5)
                            ref.child("profilePicture5").removeValue()
                            
                        }
                        
                    } else if scopeCurrentPicture == 4 {
                        
                        if scopePictures == 4 {
                            
                            self.currentPicture = 3
                            self.profileController?.currentPicture = 3
                            
                            ref.child("profilePicture4").removeValue()
                            
                        }
                        
                        if scopePictures == 5 {
                            
                            print("fifth becomes fourth")
                            
                            self.currentPicture = 4
                            self.profileController?.currentPicture = 4
                            
                            ref.child("profilePicture4").setValue(scopeProfile5)
                            ref.child("profilePicture5").removeValue()
                        }
                        
                    } else if scopeCurrentPicture == 5 {
                        
                        print("profile5 = nil")
                        
                        self.currentPicture = 4
                        self.profileController?.currentPicture = 4
                        
                        ref.child("profilePicture5").removeValue()
                        
                    }
                }))
            }
            
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (actions) in
                
            }))
            
            
            self.profileController?.presentViewController(alertController, animated: true, completion: nil)
            
        }
    }
    
    
    
    func addSwipeGesture(){
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        leftSwipe.direction = .Left
        leftSwipe.delegate = self
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        rightSwipe.direction = .Right
        rightSwipe.delegate = self
        
        self.addGestureRecognizer(rightSwipe)
        self.addGestureRecognizer(leftSwipe)
        
        
    }
    
    
    override func prepareForReuse() {
        
        profilePicOutlet.image = nil
        profilePic2Outlet.image = nil
        profilePic3Outlet.image = nil
        profilePic4Outlet.image = nil
        profilePic5Outlet.image = nil
 
        
    }
    

    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
