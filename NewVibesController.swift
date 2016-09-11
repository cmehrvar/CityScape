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
    //@IBOutlet weak var JSQHeightConstOutlet: NSLayoutConstraint!
    //@IBOutlet weak var JSQContainerOutlet: UIView!
    //@IBOutlet weak var CollectionViewBottomConstOutlet: NSLayoutConstraint!

    //CollectionView Delegates
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
 
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
                
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath: indexPath) as! VideoVibeCollectionCell

                if let key = newPosts[indexPath.section]["postChildKey"] as? String {
                    
                    if videoPlayers[key] == nil {
                        
                        if let videoURLString = newPosts[indexPath.section]["videoURL"] as? String, url = NSURL(string: videoURLString), imageUrlString = newPosts[indexPath.section]["imageURL"] as? String, imageUrl = NSURL(string: imageUrlString) {
                            
                            cell.videoThumbnailOutlet.sd_setImageWithURL(imageUrl, completed: { (image, error, cache, url) in
                                
                                print("done loading video thumbnail")
                                
                            })
                            
                            cell.createIndicator()

                            dispatch_async(dispatch_get_main_queue(), {
                                
                                self.videoPlayers[key] = Player()
                                self.videoPlayers[key]?.delegate = self
                                
                                if let player = self.videoPlayers[key] {
                                    
                                    if let videoPlayerView = player.view {
                                        
                                        self.addChildViewController(player)
                                        player.view.frame = cell.videoOutlet.bounds
                                        player.didMoveToParentViewController(self)
                                        player.setUrl(url)
                                        player.fillMode = AVLayerVideoGravityResizeAspectFill
                                        player.playbackLoops = true
                                        player.playFromBeginning()
                                        
                                        
                                        cell.videoOutlet.addSubview(videoPlayerView)
                                        
                                    }
                                }
                            })
                        }
                    } else {
                        
                        if let player = self.videoPlayers[key] {
                            
                            if let videoPlayerView = player.view {
                                
                                self.addChildViewController(player)
                                cell.videoOutlet.addSubview(videoPlayerView)
                                player.playFromBeginning()
                                
                            }
                        }
                    }
                }

                return cell

            }
        } 
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageVibeCollectionCell
        
        return cell
        
        
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView = UICollectionReusableView()

        if kind == UICollectionElementKindSectionHeader {
            
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell", forIndexPath: indexPath) as! VibeHeaderCollectionCell

            cell.loadCell(newPosts[indexPath.section])
            cell.nameOutlet.adjustsFontSizeToFitWidth = true
 
            reusableView = cell
            
        }
        
        return reusableView
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return newPosts.count
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = self.view.bounds.width
        return CGSize(width: width, height: width)
        
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
        
        if scopeCity != "" {
            
            self.rootController?.bottomNavController?.torontoOutlet.text = self.currentCity
            
            let ref = FIRDatabase.database().reference().child("posts").child(self.currentCity)
            
            ref.queryLimitedToLast(25).observeEventType(.ChildAdded, withBlock: { (snapshot) in
                
                if let value = snapshot.value as? [NSObject : AnyObject] {
                    
                    if self.observingCity != scopeCity {
                        
                        ref.removeAllObservers()
                        
                    } else {
                        
                        if let key = value["postChildKey"] as? String {
                            
                            if self.addedPosts[key] != true {
                                
                                self.addedPosts[key] = true
                                self.newPosts.insert(value, atIndex: 0)
                                
                                self.globCollectionView.reloadData()
                                
                            }
                        }
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
        
        if scopeCity != "" {
            
            self.rootController?.bottomNavController?.torontoOutlet.text = scopeCity
            
            let ref = FIRDatabase.database().reference().child("posts").child(scopeCity)
            
            ref.queryLimitedToLast(25).observeEventType(.ChildAdded, withBlock: { (snapshot) in
                
                if let value = snapshot.value as? [NSObject : AnyObject] {
                    
                    if self.observingCity != scopeCity {
                        
                        ref.removeAllObservers()
                        
                    } else {
                        
                        if let key = value["postChildKey"] as? String {
                            
                            if self.addedPosts[key] != true {
                                
                                self.addedPosts[key] = true
                                self.newPosts.insert(value, atIndex: 0)
                                
                                self.globCollectionView.reloadData()
                                
                            }
                        }
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
        
        /*
         let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler))
         panGesture.delegate = self
         self.view.addGestureRecognizer(panGesture)
         */
        
        
        
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
     
     func panHandler(sender: UIPanGestureRecognizer) {
     
     let translation = sender.translationInView(self.view)
     
     var initialX: CGFloat = 0
     var initialY: CGFloat = 0
     
     switch sender.state {
     
     case.Began:
     
     initialX = translation.x
     initialY = translation.y
     //self.globCollectionView.scrollEnabled = false
     
     case .Changed:
     
     //self.rootController?.vibesLeading.constant += translation.x / 25
     //self.rootController?.vibesTrailing.constant -= translation.x / 25
     
     print(translation.x)
     
     case .Ended:
     
     self.globCollectionView.scrollEnabled = true
     
     /*
     if translation.x + 50 < initialX {
     
     self.rootController?.toggleMessages({ (bool) in
     
     print("messages toggled")
     
     })
     } else if translation.x > initialX + 50 {
     
     self.rootController?.toggleNearby({ (bool) in
     
     print("nearby toggled")
     
     })
     
     }
     */
     
     if translation.y < initialY {
     
     if !transitioning {
     
     self.rootController?.hideAllNav({ (bool) in
     
     print("all nav hidden")
     
     })
     
     }
     
     downScroll = true
     
     } else {
     print("dont hide nav")
     
     downScroll = false
     }
     
     
     
     
     print("pan ended")
     
     default:
     break
     }
     }
     
     
     */
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
