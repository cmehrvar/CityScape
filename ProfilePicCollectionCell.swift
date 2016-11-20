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
import NYAlertViewController

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
    
    
    @IBOutlet weak var indicator1Outlet: UIView!
    @IBOutlet weak var indicator2Outlet: UIView!
    @IBOutlet weak var indicator3Outlet: UIView!
    @IBOutlet weak var indicator4Outlet: UIView!
    @IBOutlet weak var indicator5Outlet: UIView!

    @IBOutlet weak var backView1: UIView!
    @IBOutlet weak var backView2: UIView!
    @IBOutlet weak var backView3: UIView!
    @IBOutlet weak var backView4: UIView!
    
    
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet weak var editImageOutlet: UIImageView!
    
    
    //Actions
    @IBAction func edit(_ sender: AnyObject) {
        
        print("currentPicture: \(currentPicture)", terminator: "")
        
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
        
        print("current picture: \(currentPicture)", terminator: "")
        print("total pictures: \(pictures)", terminator: "")
        print("swipe left", terminator: "")
        
        var scopePictures = pictures
        
        if selfProfile && pictures < 5 {
            
            scopePictures += 1
            
        }

        if currentPicture < scopePictures && scopePictures != 1 {
            
            let screenWidth = self.bounds.width
            
            if currentPicture == 1 {
                
                currentPicture = 2
                profileController?.currentPicture = 2
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -screenWidth
                    
                    self.indicator1Outlet.alpha = 0.6
                    self.indicator2Outlet.alpha = 0.9
                    self.indicator3Outlet.alpha = 0.6
                    self.indicator4Outlet.alpha = 0.6
                    self.indicator5Outlet.alpha = 0.6
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
                
            } else if currentPicture == 2 {
                
                currentPicture = 3
                profileController?.currentPicture = 3
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -(screenWidth*2)
                    
                    self.indicator1Outlet.alpha = 0.6
                    self.indicator2Outlet.alpha = 0.6
                    self.indicator3Outlet.alpha = 0.9
                    self.indicator4Outlet.alpha = 0.6
                    self.indicator5Outlet.alpha = 0.6
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
                
            } else if currentPicture == 3 {
                
                currentPicture = 4
                profileController?.currentPicture = 4
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -(screenWidth * 3)
                    
                    self.indicator1Outlet.alpha = 0.6
                    self.indicator2Outlet.alpha = 0.6
                    self.indicator3Outlet.alpha = 0.6
                    self.indicator4Outlet.alpha = 0.9
                    self.indicator5Outlet.alpha = 0.6
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
                
            } else if currentPicture == 4 {
                
                currentPicture = 5
                profileController?.currentPicture = 5
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -(screenWidth * 4)
                    
                    self.indicator1Outlet.alpha = 0.6
                    self.indicator2Outlet.alpha = 0.6
                    self.indicator3Outlet.alpha = 0.6
                    self.indicator4Outlet.alpha = 0.6
                    self.indicator5Outlet.alpha = 0.9
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
            }
            
        }
    }
    
    func swipeRight(){
        
        print("current picture: \(currentPicture)", terminator: "")
        print("total pictures: \(pictures)", terminator: "")
        print("swipe right", terminator: "")
        
        var scopePictures = pictures
        
        if selfProfile && pictures < 5 {
            
            scopePictures += 1
            
        }

        
        if (currentPicture == scopePictures || currentPicture > 1) && scopePictures != 1 {
            
            let screenWidth = self.bounds.width
            
            if currentPicture == 2 {
                
                currentPicture = 1
                profileController?.currentPicture = 1
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = 0
                    
                    self.indicator1Outlet.alpha = 0.9
                    self.indicator2Outlet.alpha = 0.6
                    self.indicator3Outlet.alpha = 0.6
                    self.indicator4Outlet.alpha = 0.6
                    self.indicator5Outlet.alpha = 0.6
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
                
            } else if currentPicture == 3 {
                
                currentPicture = 2
                profileController?.currentPicture = 2
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -screenWidth
                    
                    self.indicator1Outlet.alpha = 0.6
                    self.indicator2Outlet.alpha = 0.9
                    self.indicator3Outlet.alpha = 0.6
                    self.indicator4Outlet.alpha = 0.6
                    self.indicator5Outlet.alpha = 0.6
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
                
            } else if currentPicture == 4 {
                
                currentPicture = 3
                profileController?.currentPicture = 3
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -(screenWidth * 2)
                    
                    self.indicator1Outlet.alpha = 0.6
                    self.indicator2Outlet.alpha = 0.6
                    self.indicator3Outlet.alpha = 0.9
                    self.indicator4Outlet.alpha = 0.6
                    self.indicator5Outlet.alpha = 0.6
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
                
            } else if currentPicture == 5 {
                
                currentPicture = 4
                profileController?.currentPicture = 4
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.profilePicCenterConstOutlet.constant = -(screenWidth * 3)
                    
                    self.indicator1Outlet.alpha = 0.6
                    self.indicator2Outlet.alpha = 0.6
                    self.indicator3Outlet.alpha = 0.6
                    self.indicator4Outlet.alpha = 0.9
                    self.indicator5Outlet.alpha = 0.6
                    
                    self.layoutIfNeeded()
                    
                    }, completion: { (bool) in
                        
                        self.profileController?.globCollectionCell.reloadData()
                        
                })
            }
        }
        
        print("right swipe", terminator: "")
        
    }
    
    
    func loadImages(_ data: [AnyHashable: Any], screenWidth: CGFloat){
        
        indicator1Outlet.layer.cornerRadius = 7
        indicator2Outlet.layer.cornerRadius = 7
        indicator3Outlet.layer.cornerRadius = 7
        indicator4Outlet.layer.cornerRadius = 7
        indicator5Outlet.layer.cornerRadius = 7

        if let profilePicture = data["profilePicture"] as? String, let url = URL(string: profilePicture) {
            
            profilePicOutlet.sd_setImage(with: url, placeholderImage: nil)
            profile1 = profilePicture
            profileController?.profile1 = profilePicture
            pictures = 1
            
        }
        
        if let profilePicture2 = data["profilePicture2"] as? String, let url = URL(string: profilePicture2) {
            
            profilePic2Outlet.sd_setImage(with: url, placeholderImage: nil)
            profile2 = profilePicture2
            pictures = 2
            
        }
        
        
        if let profilePicture3 = data["profilePicture3"] as? String, let url = URL(string: profilePicture3) {
            
            profilePic3Outlet.sd_setImage(with: url, placeholderImage: nil)
            profile3 = profilePicture3
            pictures = 3
            
        }
        
        if let profilePicture4 = data["profilePicture4"] as? String, let url = URL(string: profilePicture4) {
            
            profilePic4Outlet.sd_setImage(with: url, placeholderImage: nil)
            profile4 = profilePicture4
            pictures = 4
            
        }
        
        if let profilePicture5 = data["profilePicture5"] as? String, let url = URL(string: profilePicture5) {
            
            profilePic5Outlet.sd_setImage(with: url, placeholderImage: nil)
            profile5 = profilePicture5
            pictures = 5
            
        }
        
        if let userUID = data["uid"] as? String {
            
            uid = userUID
            
        }
        
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if selfUID == data["uid"] as? String {
                
                backView1.alpha = 1
                backView2.alpha = 1
                backView3.alpha = 1
                backView4.alpha = 1
                
                editImageOutlet.alpha = 1
                editButtonOutlet.isEnabled = true
                
                selfProfile = true
                
                if pictures == 1 {

                    profilePic2Outlet.image = nil
                    
                    indicator2WidthConstOutlet.constant = 14
                    indicator3WidthConstOutlet.constant = 0
                    indicator4WidthConstOutlet.constant = 0
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 2 {

                    profilePic3Outlet.image = nil
                    
                    indicator2WidthConstOutlet.constant = 14
                    indicator3WidthConstOutlet.constant = 14
                    indicator4WidthConstOutlet.constant = 0
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 3 {
                    
                    profilePic4Outlet.image = nil
                    
                    indicator2WidthConstOutlet.constant = 14
                    indicator3WidthConstOutlet.constant = 14
                    indicator4WidthConstOutlet.constant = 14
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 4 {

                    profilePic5Outlet.image = nil
                    
                    indicator2WidthConstOutlet.constant = 14
                    indicator3WidthConstOutlet.constant = 14
                    indicator4WidthConstOutlet.constant = 14
                    indicator5WidthConstOutlet.constant = 14
                    
                } else if pictures == 5 {

                    indicator2WidthConstOutlet.constant = 14
                    indicator3WidthConstOutlet.constant = 14
                    indicator4WidthConstOutlet.constant = 14
                    indicator5WidthConstOutlet.constant = 14
                    
                }
                
                
            } else {
                
                backView1.alpha = 0
                backView2.alpha = 0
                backView3.alpha = 0
                backView4.alpha = 0
                
                editImageOutlet.alpha = 0
                editButtonOutlet.isEnabled = false
                selfProfile = false
                
                if pictures == 1 {

                    indicator2WidthConstOutlet.constant = 0
                    indicator3WidthConstOutlet.constant = 0
                    indicator4WidthConstOutlet.constant = 0
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 2 {

                    indicator2WidthConstOutlet.constant = 14
                    indicator3WidthConstOutlet.constant = 0
                    indicator4WidthConstOutlet.constant = 0
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 3 {

                    indicator2WidthConstOutlet.constant = 14
                    indicator3WidthConstOutlet.constant = 14
                    indicator4WidthConstOutlet.constant = 0
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 4 {

                    indicator2WidthConstOutlet.constant = 14
                    indicator3WidthConstOutlet.constant = 14
                    indicator4WidthConstOutlet.constant = 14
                    indicator5WidthConstOutlet.constant = 0
                    
                } else if pictures == 5 {

                    indicator2WidthConstOutlet.constant = 14
                    indicator3WidthConstOutlet.constant = 14
                    indicator4WidthConstOutlet.constant = 14
                    indicator5WidthConstOutlet.constant = 14
                    
                }
            }
        }
        
        
        if currentPicture == 1 {
            
            profilePicCenterConstOutlet.constant = 0

            indicator1Outlet.alpha = 0.9
            indicator2Outlet.alpha = 0.6
            indicator3Outlet.alpha = 0.6
            indicator4Outlet.alpha = 0.6
            indicator5Outlet.alpha = 0.6
 
        } else if currentPicture == 2 {
            
            profilePicCenterConstOutlet.constant = -(screenWidth)
            
            indicator1Outlet.alpha = 0.6
            indicator2Outlet.alpha = 0.9
            indicator3Outlet.alpha = 0.6
            indicator4Outlet.alpha = 0.6
            indicator5Outlet.alpha = 0.6
            
        } else if currentPicture == 3 {
            
            profilePicCenterConstOutlet.constant = -(screenWidth * 2)
            
            indicator1Outlet.alpha = 0.6
            indicator2Outlet.alpha = 0.6
            indicator3Outlet.alpha = 0.9
            indicator4Outlet.alpha = 0.6
            indicator5Outlet.alpha = 0.6
            
        } else if currentPicture == 4 {
            
            profilePicCenterConstOutlet.constant = -(screenWidth * 3)
            
            indicator1Outlet.alpha = 0.6
            indicator2Outlet.alpha = 0.6
            indicator3Outlet.alpha = 0.6
            indicator4Outlet.alpha = 0.9
            indicator5Outlet.alpha = 0.6
            
        } else if currentPicture == 5 {
            
            profilePicCenterConstOutlet.constant = -(screenWidth * 4)
            
            indicator1Outlet.alpha = 0.6
            indicator2Outlet.alpha = 0.6
            indicator3Outlet.alpha = 0.6
            indicator4Outlet.alpha = 0.6
            indicator5Outlet.alpha = 0.9
            
        }
        
        addSwipeGesture()
        
    }

    
    func callCamera(_ imageToEdit: String){
        
        let scopeCurrentPicture = currentPicture
        let scopePictures = pictures
        
        let scopeProfile1 = profile1
        let scopeProfile2 = profile2
        let scopeProfile3 = profile3
        let scopeProfile4 = profile4
        let scopeProfile5 = profile5
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("users").child(selfUID)
            
            let nyAlertController = NYAlertViewController()
            
            nyAlertController.title = "What would you like to do?"
            nyAlertController.message = nil
            
            nyAlertController.titleColor = UIColor.black
            nyAlertController.buttonColor = UIColor.lightGray
            nyAlertController.buttonTitleColor = UIColor.white
            nyAlertController.cancelButtonColor = UIColor.lightGray
            nyAlertController.cancelButtonTitleColor = UIColor.white
            
            nyAlertController.backgroundTapDismissalGestureEnabled = true

            if scopeCurrentPicture == 1 || ((scopeCurrentPicture == (scopePictures + 1)) && scopeProfile5 == "")  {
                
                nyAlertController.buttonColor = UIColor.red
                
                nyAlertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    
                    self.profileController?.dismiss(animated: true, completion: nil)
                    
                    print("canceled")
                    
                }))
                
                nyAlertController.addAction(NYAlertAction(title: "Edit Image", style: .default, handler: { (action) in
                    
                    self.profileController?.dismiss(animated: true, completion: {
                        
                        
                        
                        //PRESENT CAMERA
                        
                        
                        
                    })
                }))

                
            } else if scopeCurrentPicture > 1 && scopeCurrentPicture <= scopePictures {
                
                nyAlertController.addAction(NYAlertAction(title: "Edit Image", style: .default, handler: { (action) in
                    
                    self.profileController?.dismiss(animated: true, completion: {
                        
                        
                        //PRESENT FUSUMA
                        
                        
                        
                    })
                }))


                nyAlertController.addAction(NYAlertAction(title: "Swap with first image", style: .default, handler: { (action) in
                    
                    self.profileController?.dismiss(animated: true, completion: {
                        
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
                    })
                }))
                
                nyAlertController.addAction(NYAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    
                    self.profileController?.dismiss(animated: true, completion: {
                        
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
                    })
                }))
                
                nyAlertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    
                    self.profileController?.dismiss(animated: true, completion: nil)
                    
                    print("canceled")
                    
                }))

            }
            
            
            self.profileController?.present(nyAlertController, animated: true, completion: nil)
            
        }
    }
    
    
    
    func addSwipeGesture(){
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        leftSwipe.direction = .left
        leftSwipe.delegate = self
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        rightSwipe.direction = .right
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
