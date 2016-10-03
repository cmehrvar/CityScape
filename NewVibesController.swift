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
//import Player
import AVFoundation
import NVActivityIndicatorView
import SDWebImage

class NewVibesController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var videoWithSound = ""
    
    //Variables
    weak var rootController: MainRootController?
    var transitioning = false
    var videoAssets = [String : AVAsset]()
    var newPosts = [[NSObject : AnyObject]]()
    var addedPosts = [String : Bool]()
    
    var player1Key = ""
    var player2Key = ""
    var player3Key = ""
    
    var playerItem1: AVPlayerItem?
    var playerItem2: AVPlayerItem?
    var playerItem3: AVPlayerItem?
    
    var player1: Player1?
    var player2: Player2?
    var player3: Player3?
    
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
    
    
    
    
    
    
    //CollectionView Delegates
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        if let videoCell = cell as? VideoVibeCollectionCell {
            
            if videoCell.playerTitle == "player1" {
                
                player1?.removeObserver(self, forKeyPath: "rate")
                player1?.pause()
                player1 = nil
                playerItem1 = nil
                player1Key = ""
                
            } else if videoCell.playerTitle == "player2" {
                
                player2?.removeObserver(self, forKeyPath: "rate")
                player2?.pause()
                player2 = nil
                playerItem2 = nil
                player2Key = ""
                
            } else if videoCell.playerTitle == "player3" {
                
                player3?.removeObserver(self, forKeyPath: "rate")
                player3?.pause()
                player3 = nil
                playerItem3 = nil
                player3Key = ""
                
            }
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if let videoCell = cell as? VideoVibeCollectionCell {
            
            if let key = newPosts[indexPath.section]["postChildKey"] as? String, videoURLString = newPosts[indexPath.section]["videoURL"] as? String, url = NSURL(string: videoURLString) {
                
                var playerTitle = ""
                
                if key == player1Key {
                    
                    player1?.play()
                    
                } else if key == player2Key {
                    
                    player2?.play()
                    
                } else if key == player3Key {
                    
                    player3?.play()
                    
                } else {
                    
                    var asset: AVAsset!
                    
                    if let loadedAsset = videoAssets[key] {
                        
                        asset = loadedAsset
                        
                    } else {
                        
                        asset = AVAsset(URL: url)
                        
                    }
                    
                    if player1 == nil {
                        
                        player1Key = key
                        playerTitle = "player1"
                        playerItem1 = AVPlayerItem(asset: asset)
                        
                        if let item = playerItem1 {
                            
                            player1 = Player1(playerItem: item)
                            
                        }
                        
                        if videoWithSound == key {
                            
                            player1?.muted = false
                            
                        } else {
                            
                            player1?.muted = true
                            
                        }
                        
                        player1?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            let playerLayer = AVPlayerLayer(player: self.player1)
                            playerLayer.frame = videoCell.videoOutlet.bounds
                            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            videoCell.videoOutlet.layer.addSublayer(playerLayer)
                            self.player1?.play()
                            
                        })
                        
                    } else if player2 == nil {
                        
                        player2Key = key
                        playerTitle = "player2"
                        playerItem2 = AVPlayerItem(asset: asset)
                        
                        if let item = playerItem2 {
                            
                            player2 = Player2(playerItem: item)
                            
                        }
                        
                        if videoWithSound == key {
                            
                            player2?.muted = false
                            
                        } else {
                            
                            player2?.muted = true
                            
                        }
                        
                        player2?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            let playerLayer = AVPlayerLayer(player: self.player2)
                            playerLayer.frame = videoCell.videoOutlet.bounds
                            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            videoCell.videoOutlet.layer.addSublayer(playerLayer)
                            self.player2?.play()
                            
                        })
                        
                    } else {
                        
                        player3Key = key
                        playerTitle = "player3"
                        playerItem3 = AVPlayerItem(asset: asset)
                        
                        if let item = playerItem3 {
                            
                            player3 = Player3(playerItem: item)
                            
                        }
                        
                        if videoWithSound == key {
                            
                            player3?.muted = false
                            
                        } else {
                            
                            player3?.muted = true
                            
                        }
                        
                        player3?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            let playerLayer = AVPlayerLayer(player: self.player3)
                            playerLayer.frame = videoCell.videoOutlet.bounds
                            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            videoCell.videoOutlet.layer.addSublayer(playerLayer)
                            self.player3?.play()
                            
                        })
                    }
                }
                
                videoCell.playerTitle = playerTitle
                
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
                    
                    if let  imageUrlString = newPosts[indexPath.section]["imageURL"] as? String, imageUrl = NSURL(string: imageUrlString) {
                        
                        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath: indexPath) as! VideoVibeCollectionCell
                        
                        cell.vibesController = self
                        cell.createIndicator()
                        cell.videoThumbnailOutlet.sd_setImageWithURL(imageUrl, completed: { (image, error, cache, url) in
                            
                            print("done loading video thumbnail")
                            
                        })
      
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
            
            return CGSize(width: width, height: 65)
            
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
        //self.videoPlayers.removeAll()
        
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
        //self.videoPlayers.removeAll()
        
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
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "rate" {
            
            if object is Player1 {
                
                if let player = player1, item = playerItem1 {
                    
                    if CMTimeGetSeconds(player.currentTime()) == CMTimeGetSeconds(item.duration) {
                        
                        player1?.seekToTime(kCMTimeZero)
                        player1?.play()
                        
                    } else if player1?.rate == 0 {
                        
                        player1?.play()
                        
                    }
                }
                
            } else if object is Player2 {
                
                if let player = player2, item = playerItem2 {
                    
                    if CMTimeGetSeconds(player.currentTime()) == CMTimeGetSeconds(item.duration) {
                        
                        player2?.seekToTime(kCMTimeZero)
                        player2?.play()
                        
                    } else if player2?.rate == 0 {
                        
                        player2?.play()
                        
                    }
                }

            } else if object is Player3 {
                
                if let player = player3, item = playerItem3 {
                    
                    if CMTimeGetSeconds(player.currentTime()) == CMTimeGetSeconds(item.duration) {
                        
                        player3?.seekToTime(kCMTimeZero)
                        player3?.play()
                        
                    } else if player3?.rate == 0 {
                        
                        player3?.play()
                        
                    }
                }
            }
        }
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
