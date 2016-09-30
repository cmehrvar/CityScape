//
//  NewVibesController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-02.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Player
import AVFoundation
import NVActivityIndicatorView
import SDWebImage

class NewVibesController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PlayerDelegate {
    
    //Player Delegates
    func playerReady(player: Player){
        
    }
    func playerPlaybackStateDidChange(player: Player){
        
    }
    func playerBufferingStateDidChange(player: Player){
        
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player){
        
    }
    func playerPlaybackDidEnd(player: Player){
        
        //player.playFromBeginning()
        
    }
    
    func playerCurrentTimeDidChange(player: Player) {
        
    }
    
    //Variables
    weak var rootController: MainRootController?
    var transitioning = false
    var videoPlayers = [String : Player]()
    var newPosts = [[NSObject : AnyObject]]()
    var addedPosts = [String : Bool]()
    
    var beganDisplaying = 0
    var endedDisplaying = 0
    
    var contentOffset: CGFloat = 0
    var contentOffsetToShowNavAt: CGFloat = 0
    
    var scrollingUp = false
    var showingNav = false
    var navHidden = false
    
    //Outlets
    @IBOutlet weak var globCollectionView: UICollectionView!
    @IBOutlet weak var vibeFlowLayout: UICollectionViewFlowLayout!


    
    //Actions
    @IBAction func goToProfile(sender: AnyObject) {
        
        
        
    }
    
  
    //CollectionView Delegates
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath: indexPath) as? VideoVibeCollectionCell {

            if let player = videoPlayers[cell.postKey] {
                
                player.stop()
                
            }
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        if indexPath.row == 0 {
            
            if let isImage = newPosts[indexPath.section]["isImage"] as? Bool {
                
                if isImage {
                    
                    if let urlString = newPosts[indexPath.section]["imageURL"] as? String, url = NSURL(string: urlString){
                        
                        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageVibeCollectionCell
                        cell.createIndicator()
                        cell.loadImage(url)
                        cell.addPinchRecognizer()
                        return cell
                    }
                    
                } else {
                    
                    
                    if let videoURLString = newPosts[indexPath.section]["videoURL"] as? String, url = NSURL(string: videoURLString), imageUrlString = newPosts[indexPath.section]["imageURL"] as? String, imageUrl = NSURL(string: imageUrlString) {
                        
                        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath: indexPath) as! VideoVibeCollectionCell
                        
                        
                        cell.videoThumbnailOutlet.sd_setImageWithURL(imageUrl, completed: { (image, error, cache, url) in
                            
                            print("done loading video thumbnail")
                            
                        })
                        
                        
                        if let key = newPosts[indexPath.section]["postChildKey"] as? String {
                            
                            cell.postKey = key
                            
                            if let player = videoPlayers[key] {
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    if let videoPlayerView = player.view {
                                        
                                        self.addChildViewController(player)
                                        player.didMoveToParentViewController(self)
                                        player.playFromCurrentTime()
                                        videoPlayerView.removeFromSuperview()
                                        cell.videoOutlet.addSubview(videoPlayerView)
                                        cell.videoOutlet.alpha = 1
                                        
                                    }
                                    
                                })
                                
                            } else {
                                
                                cell.createIndicator()
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    let scopePlayer = Player()
                                    scopePlayer.delegate = self
                                    
                                    self.addChildViewController(scopePlayer)
                                    scopePlayer.view.frame = cell.videoOutlet.bounds
                                    scopePlayer.didMoveToParentViewController(self)
                                    scopePlayer.setUrl(url)
                                    scopePlayer.fillMode = AVLayerVideoGravityResizeAspectFill
                                    scopePlayer.playbackLoops = true
                                    scopePlayer.playFromCurrentTime()
                                    
                                    if let videoPlayerView = scopePlayer.view {
                                        
                                        cell.videoOutlet.addSubview(videoPlayerView)
                                        cell.videoOutlet.alpha = 1
                                        
                                    }
                                    
                                    self.videoPlayers[key] = scopePlayer
                                    
                                })
                            }
                        }
                        
                        return cell
                        
                    }
                }
            } 

            
        } else if indexPath.row == 1 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("buttonsCell", forIndexPath: indexPath) as! LikeButtonsCollectionCell
            
            cell.loadData(newPosts[indexPath.section])
            
            return cell
            
        }

        return UICollectionViewCell()

    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView = UICollectionReusableView()

        if kind == UICollectionElementKindSectionHeader {
            
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell", forIndexPath: indexPath) as! VibeHeaderCollectionCell

            cell.vibesController = self
            cell.loadCell(newPosts[indexPath.section])
 
            reusableView = cell
            
        }
        
        return reusableView
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return newPosts.count
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 2
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.view.bounds.width
        
        if indexPath.row == 0 {

            return CGSize(width: width, height: width)
            
        } else if indexPath.row == 1 {
            
            return CGSize(width: width, height: 55)
            
        }
        
        return CGSizeZero
        
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = self.view.bounds.width

        return CGSize(width: width, height: 50)

    }
    

    func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        
        print("began displaying index path: \(indexPath.section)")
        
        if indexPath.section <= endedDisplaying {
            
            if scrollingUp {
                
                contentOffsetToShowNavAt = collectionView.contentOffset.y
                beganDisplaying = indexPath.section
                
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        
        print("ended displaying index path: \(indexPath.section)")
        
        endedDisplaying = indexPath.section
        
    }
    

    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < contentOffset {
            
            scrollingUp = true
            
            if beganDisplaying == 0 && scrollView.contentOffset.y == 0 {
                
                if !showingNav {
                    
                    showingNav = true
                    
                    rootController?.showNav(0.3, completion: { (bool) in
                        
                        print("nav shown")
                        
                        self.navHidden = false
                        self.showingNav = false
                        
                    })

                }

            } else if contentOffsetToShowNavAt >= scrollView.contentOffset.y + 120 && navHidden && beganDisplaying != 0 {
                
                if !showingNav {
                    
                    showingNav = true

                    rootController?.showNav(0.3, completion: { (bool) in
                        
                        print("nav shown")
                        
                        self.navHidden = false
                        self.showingNav = false
                        
                    })
                }
                
            } else {
                
                //print("dont show nav")
            }
            
            
        } else if scrollView.contentOffset.y > contentOffset {
            
            scrollingUp = false
            
        }
        
        contentOffset = scrollView.contentOffset.y
        
    }
    

    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if velocity.y > 0 {
            
            if !transitioning && !navHidden {
     
                rootController?.hideAllNav({ (bool) in
                    
                    self.navHidden = true
 
                    print("top nav hidded")
                    
                })
            }
            
        } else {
            print("velocity negative")
        }
    }
    
    

    //Functions
    var observingCity: String = ""
    var currentCity: String = ""
    
    func observeCurrentCityPosts(){
        
        observingCity = currentCity
        let scopeCity = currentCity
        
        self.rootController?.bottomNavController?.torontoOutlet.text = scopeCity
        
        self.newPosts.removeAll()
        self.addedPosts.removeAll()
        self.videoPlayers.removeAll()
        
        if scopeCity != "" {
            
            self.rootController?.bottomNavController?.torontoOutlet.text = self.currentCity
            
            let ref = FIRDatabase.database().reference().child("posts").child(self.currentCity)
            
            ref.queryLimitedToLast(100).observeEventType(.Value, withBlock: { (snapshot) in
                
                var scopeData = [[NSObject : AnyObject]]()
                
                if let value = snapshot.value as? [NSObject : AnyObject] {
                    
                    if self.observingCity != scopeCity {
                        
                        ref.removeAllObservers()
                        
                    } else {
                        
                        for (_, snapValue) in value {
                            
                            if let valueToAdd = snapValue as? [NSObject : AnyObject] {
                                
                                scopeData.append(valueToAdd)
                                
                            }
                        }
                        
                        scopeData.sortInPlace({ (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
                            
                            if a["timeStamp"] as? NSTimeInterval > b["timeStamp"] as? NSTimeInterval {
                                
                                return true
                                
                            } else {
                                
                                return false
                                
                            }
                        })
                        
                        self.newPosts = scopeData
                        self.globCollectionView.reloadData()
                        
                    }
                }
            })
        }
    }
    
    
    
    func observePosts(){
        
        let scopeCity = observingCity
        
        self.rootController?.bottomNavController?.torontoOutlet.text = scopeCity
        
        self.newPosts.removeAll()
        self.addedPosts.removeAll()
        self.videoPlayers.removeAll()
        
        if scopeCity != "" {
            
            self.rootController?.bottomNavController?.torontoOutlet.text = scopeCity
            
            let ref = FIRDatabase.database().reference().child("posts").child(scopeCity)
            
            ref.queryLimitedToLast(100).observeEventType(.Value, withBlock: { (snapshot) in

                var scopeData = [[NSObject : AnyObject]]()
                
                if let value = snapshot.value as? [NSObject : AnyObject] {
                    
                    if self.observingCity != scopeCity {
                        
                        ref.removeAllObservers()
                        
                    } else {
                        
                        for (_, snapValue) in value {
                            
                            if let valueToAdd = snapValue as? [NSObject : AnyObject] {
                                
                                scopeData.append(valueToAdd)
                                
                            }
                        }
                        
                        scopeData.sortInPlace({ (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
                            
                            if a["timeStamp"] as? NSTimeInterval > b["timeStamp"] as? NSTimeInterval {
                                
                                return true
                                
                            } else {
                                
                                return false
                                
                            }
                        })
                        
                        self.newPosts = scopeData
                        self.globCollectionView.reloadData()
                        
                    }
                }
            })
        }
    }

    func addGestureRecognizers(){

        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showNav))
        downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        downSwipeGestureRecognizer.delegate = self
        
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showMessages))
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        leftSwipeGestureRecognizer.delegate = self
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showNearby))
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        rightSwipeGestureRecognizer.delegate = self
        
        self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        //self.view.addGestureRecognizer(downSwipeGestureRecognizer)
        
    }
    
    
    func showNav(){
        
        rootController?.showNav(0.3, completion: { (bool) in
            
            print("nav shown")
            
            self.navHidden = false
            self.showingNav = false
            
        })
    }
    
    func showNearby(){
        
        transitioning = true
        
        self.globCollectionView.scrollEnabled = false
        
        rootController?.toggleNearby({ (bool) in
            
            self.globCollectionView.scrollEnabled = true
            
            self.navHidden = false
            self.transitioning = false
            print("nearby toggled")
            
        })
    }
    
    func showMessages(){
        
        transitioning  = true
        
        self.globCollectionView.scrollEnabled = false
        
        rootController?.toggleMessages({ (bool) in

            self.globCollectionView.scrollEnabled = true
            
            self.navHidden = false
            self.transitioning = false
            print("messages toggled")
            
        })
    }
    
    func printSomething(){
        
        print("something printed!")
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vibeFlowLayout.sectionHeadersPinToVisibleBounds = true
        globCollectionView.alwaysBounceVertical = false
        globCollectionView.bounces = false
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.vibeController = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(observeCurrentCityPosts), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showNav), name: UIApplicationDidBecomeActiveNotification, object: nil)

        addGestureRecognizers()

        // Do any additional setup after loading the view.
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
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
