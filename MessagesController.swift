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

    //Outlets
    @IBOutlet weak var globCollectionViewOutlet: UICollectionView!

    //Actions
    func loadMatches(data: [NSObject : AnyObject]){

        var matches = [[NSObject : AnyObject]]()

        for (_, value) in data {
            
            if let valueToAdd = value as? [NSObject : AnyObject] {
                
                matches.append(valueToAdd)

            }
        }
        
        matches.sortInPlace { (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
            
            if a["lastActivity"] as? NSTimeInterval > b["lastActivity"] as? NSTimeInterval {
                
                return true
                
            } else {
                
                return false
                
            }
        }
        
        globMatches = matches
        globCollectionViewOutlet.reloadData()
 
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
