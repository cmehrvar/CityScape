//
//  MessagesController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-06.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class MessagesController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    weak var rootController: MainRootController?
    
    var globMatches = [[NSObject : AnyObject]]()
    var oldMatches = [[NSObject : AnyObject]]()
    
    
    //Outlets
    @IBOutlet weak var globCollectionViewOutlet: UICollectionView!

    //Actions
    func loadMatches(data: [NSObject : AnyObject]){
        
        globMatches.removeAll()
        
        let sortedMatches = data.sort({ (a: (NSObject, AnyObject), b: (NSObject, AnyObject)) -> Bool in
            
            if a.1["lastActivity"] as? NSTimeInterval > b.1["lastActivity"] as? NSTimeInterval {
                return true
            } else {
                return false
            }
            
        })
        
        var i = 0
        
        for (_, value) in sortedMatches {
            
            if let dictValue = value as? [NSObject : AnyObject] {
                
                globMatches.append(dictValue)
                
                if let userUID = dictValue["uid"] as? String {
                    
                    let ref = FIRDatabase.database().reference().child("users").child(userUID)
                    
                    ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        
                        if let userDataValue = snapshot.value as? [NSObject : AnyObject], selfUID = FIRAuth.auth()?.currentUser?.uid {
 
                            if dictValue["online"] as? Bool != userDataValue["online"] as? Bool {
                                
                                print("update online!")
                                let myRef = FIRDatabase.database().reference().child("users").child(selfUID).child("matches").child(userUID)
                                myRef.child("online").setValue(userDataValue["online"] as? Bool)
  
                            }
                            
                            if value["profilePicture"] as? String != userDataValue["profilePicture"] as? String {
                                ref.child("users").child(selfUID).child("matches").child(userUID).child("profilePicture").setValue(userDataValue["profilePicture"])

                            }
                        }
                    })
                }
                
                i += 1
            }
        }

        if oldMatches != globMatches {
            
            oldMatches = globMatches
            globCollectionViewOutlet.reloadData()
            
        }
    }
    
    func addGestureRecognizers(){
        
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showNav))
        downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        downSwipeGestureRecognizer.delegate = self
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showVibes))
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        rightSwipeGestureRecognizer.delegate = self
        
        self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
        self.view.addGestureRecognizer(downSwipeGestureRecognizer)
        
    }
    
    func showNav(){
        
        rootController?.showNav(0.3, completion: { (bool) in
            
            print("nav showed")
            
        })
    }
    
    func showVibes(){
        
        rootController?.toggleVibes({ (bool) in
            
            print("vibes toggled")
            
        })
    }
    
    
    //Collection View Delegates
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return globMatches.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("matchCell", forIndexPath: indexPath) as! MatchCollectionViewCell
        
        
        var diameter: CGFloat!
        
        if let rootHeight = rootController?.view.bounds.height {
            
            let screenSize = (rootHeight - 120)
            
            diameter = (screenSize * 0.33) - ((screenSize * 0.33) * 0.3)
            
        }
        
        cell.profileOutlet.layer.cornerRadius = (((diameter - 20) / 2) - 1)
        
        cell.indicatorOutlet.layer.cornerRadius = 8
        cell.indicatorOutlet.layer.borderWidth = 2
        cell.indicatorOutlet.layer.borderColor = UIColor.whiteColor().CGColor
        
        cell.messagesController = self
        
        cell.loadCell(globMatches[indexPath.row])
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var diameter: CGFloat = 0.0
        
        if let rootHeight = rootController?.view.bounds.height {
            
            let screenSize = (rootHeight - 120)
            
            diameter = (screenSize * 0.33) - ((screenSize * 0.33) * 0.3)
            
        }
        
        let size = CGSize(width: (diameter), height: diameter)
        
        return size
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        
        print("view did appear")
        
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGestureRecognizers()
        
        // Do any additional setup after loading the view.
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
