//
//  StatusCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-21.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import NYAlertViewController
import Firebase
import FirebaseAuth
import FirebaseDatabase

class StatusCell: UICollectionViewCell, UITextFieldDelegate {

    @IBOutlet weak var statusOutlet: UILabel!
    
    var selfProfile = false
    
    weak var profileController: ProfileController?
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "\n" {
            
            textField.resignFirstResponder()
            return false
            
        }
        
        guard let text = textField.text else {return false}
        return text.characters.count + (string.characters.count - range.length) <= 30
        
    }
    
    
    @IBAction func editStatus(_ sender: Any) {
        
        if selfProfile {
            
            //let alertController =
            let alertController = NYAlertViewController()
            
            var scopeTextField: UITextField?
            
            //alertController.alertViewBackgroundColor = UIColor.white
            
            alertController.title = "Edit current status"
            alertController.message = nil
            alertController.titleColor = UIColor.black
            
            alertController.buttonColor = UIColor.red
            alertController.buttonTitleColor = UIColor.white
            
            alertController.cancelButtonColor = UIColor.lightGray
            alertController.cancelButtonTitleColor = UIColor.white
            
            alertController.backgroundTapDismissalGestureEnabled = false
            
            alertController.addTextField(configurationHandler: { (textfield) in

                textfield?.delegate = self
                textfield?.autocorrectionType = .no
                textfield?.placeholder = "Enter a new status..."
                scopeTextField = textfield
                
                
            })
            
            alertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                self.profileController?.dismiss(animated: true, completion: {
                    
                    print("alert controller dismissed")
                    
                })
                
                
            }))
            
            alertController.addAction(NYAlertAction(title: "Edit Status", style: .default, handler: { (action) in
                
                if let status = scopeTextField?.text, let myUid = FIRAuth.auth()?.currentUser?.uid {
                    
                    FIRDatabase.database().reference().child("users").child(myUid).child("currentStatus").setValue(status)

                }

               self.profileController?.dismiss(animated: true, completion: {
                
                    print("alert controller dismissed")
                
               })
                
                
            }))
            
            profileController?.present(alertController, animated: true, completion: {
                
                print("Alert controller presented")
                
            })
            
            
            
            
        }
        
        
    }
    
    
    
    func loadCell(_ data: [AnyHashable: Any]){
        
        if let myUid = FIRAuth.auth()?.currentUser?.uid, let yourUid = data["uid"] as? String {
            
            if myUid == yourUid {
                
                selfProfile = true
                
            } else {
                
                selfProfile = false
                
            }
        } else {
            
            selfProfile = false
            
        }
        
        statusOutlet.adjustsFontSizeToFitWidth = true
        statusOutlet.baselineAdjustment = .alignCenters
        
        if let status = data["currentStatus"] as? String {
            
            statusOutlet.text = status
            
        }
    }
    
    override func prepareForReuse() {
        
        statusOutlet.text = nil
        
    }
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
