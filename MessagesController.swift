//
//  MessagesController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-06.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

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
        
        for (_, value) in sortedMatches {
            
            if let dictValue = value as? [NSObject : AnyObject] {
                globMatches.append(dictValue)
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
            
            let screenSize = (rootHeight * 0.8)
            
            diameter = (screenSize * 0.33) - ((screenSize * 0.33) * 0.28)
            
        }
        
        cell.profileOutlet.layer.cornerRadius = ((((diameter) * 116) / 136) / 2) - 1
        
        cell.indicatorOutlet.layer.cornerRadius = 8
        cell.indicatorOutlet.layer.borderWidth = 2
        cell.indicatorOutlet.layer.borderColor = UIColor.whiteColor().CGColor
        
        if let uid = globMatches[indexPath.row]["uid"] as? String {
            cell.uid = uid
        }
        
        if let firstName = globMatches[indexPath.row]["firstName"] as? String {
            cell.nameOutlet.text = firstName
        }
        
        cell.loadData()
        cell.messagesController = self
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var diameter: CGFloat!
        
        if let rootHeight = rootController?.view.bounds.height {
            
            let screenSize = (rootHeight * 0.8)
            
            diameter = (screenSize * 0.33) - ((screenSize * 0.33) * 0.28)
            
        }
        
        let size = CGSize(width: (diameter * 0.934), height: diameter)
        
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
