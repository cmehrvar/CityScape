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
    
    var playerKeys = ["", "", ""]
    
    var player1Observing = false
    var player2Observing = false
    var player3Observing = false
    
    var player1: AVPlayer?
    var player2: AVPlayer?
    var player3: AVPlayer?
    
    var playerLayer1: AVPlayerLayer?
    var playerLayer2: AVPlayerLayer?
    var playerLayer3: AVPlayerLayer?
    
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
        
        if !newPosts.isEmpty {
            
            if let key = newPosts[indexPath.section]["postChildKey"] as? String, videoCell = cell as? VideoVibeCollectionCell {
                
                var isVisible = false
                
                for visibleCell in collectionView.visibleCells() {
                    
                    if let visibleVideo = visibleCell as? VideoVibeCollectionCell {
                        
                        if visibleVideo.postKey == key {
                            
                            print(visibleVideo.postKey)
                            
                            isVisible = true
                            
                        }
                    }
                }
                
                print("is visible: \(isVisible)")
                
                if videoCell.playerTitle == "player1" {
                    
                    if let player = player1 {
                        
                        if player1Observing {
                            
                            player.removeObserver(self, forKeyPath: "rate")
                            player1Observing = false
                            
                        }
                    }

                    if !isVisible {
                        
                        playerLayer1?.removeFromSuperlayer()
                        playerLayer1 = nil

                        playerKeys[0] = ""
                        player1?.pause()
                        player1 = nil

                    }
                
                
                } else if videoCell.playerTitle == "player2" {
                    
                    if let player = player2 {
                        
                        if player2Observing {
                            
                            player.removeObserver(self, forKeyPath: "rate")
                            player2Observing = false
                            
                        }
                    }

                    if !isVisible {
                        
                        playerLayer2?.removeFromSuperlayer()
                        playerLayer2 = nil
                        
                        playerKeys[1] = ""
                        player2?.pause()
                        player2 = nil
                        
                        
                        }
                    
                    
                } else if videoCell.playerTitle == "player3" {
                    
                    if let player = player3 {
                        
                        if player3Observing {
                            
                            player.removeObserver(self, forKeyPath: "rate")
                            player3Observing = false
                            
                        }
                    }

                    if !isVisible {
                        
                        playerLayer3?.removeFromSuperlayer()
                        playerLayer3 = nil

                        playerKeys[2] = ""
                        player3?.pause()
                        player3 = nil
                        
                    }
                }
                
                
                if !isVisible {
                    
                    if let subLayers = videoCell.videoOutlet.layer.sublayers {
                        
                        for layer in subLayers {
                            
                            layer.removeFromSuperlayer()
                            
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if let videoCell = cell as? VideoVibeCollectionCell, key = newPosts[indexPath.section]["postChildKey"] as? String {
            
            if videoCell.playerTitle == "player1" {
                
                if let player = player1 {
                    
                    if !player1Observing {
                        
                        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                        player1Observing = true
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if videoCell.postKey == key {
        
                            self.playerLayer1 = AVPlayerLayer(player: player)
                            self.playerLayer1?.videoGravity = AVLayerVideoGravityResizeAspectFill
                            self.playerLayer1?.frame = videoCell.bounds
                            
                            if let layer = self.playerLayer1 {
                                
                                videoCell.videoOutlet.layer.addSublayer(layer)
                                
                            }
 
                            if self.videoWithSound == key {
                                
                                self.player1?.muted = false
                                
                            } else {
                                
                                self.player1?.muted = true
                                
                            }
  
                            self.player1?.play()
                            
                        }
                    })
                    
                } else {
                    
                    if let key = newPosts[indexPath.section]["postChildKey"] as? String {
                        
                        var asset: AVAsset?
                        
                        if let loadedAsset = videoAssets[key] {
                            
                            asset = loadedAsset
                            
                        } else if let urlString = newPosts[indexPath.section]["videoURL"] as? String, url = NSURL(string: urlString) {
                            
                            asset = AVAsset(URL: url)
                            
                        }
                        
                        if let actualAsset = asset {
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                let playerItem = AVPlayerItem(asset: actualAsset)
                                self.playerKeys[0] = key
                                self.player1 = AVPlayer(playerItem: playerItem)
                                self.player1?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                                self.player1Observing = true
                                
                                self.playerLayer1 = AVPlayerLayer(player: self.player1)
                                self.playerLayer1?.videoGravity = AVLayerVideoGravityResizeAspectFill
                                self.playerLayer1?.frame = videoCell.bounds
                                
                                if let layer = self.playerLayer1 {
                                    
                                    videoCell.videoOutlet.layer.addSublayer(layer)
                                    
                                }
                                
                                if self.videoWithSound == key {
                                    
                                    self.player1?.muted = false
                                    
                                } else {
                                    
                                    self.player1?.muted = true
                                    
                                }


                                self.player1?.play()
                                
                            })
                        }
                    }
                }
                
            } else if videoCell.playerTitle == "player2" {
                
                if let player = player2 {
                    
                    if !player2Observing {
                        
                        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                        self.player2Observing = true
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if videoCell.postKey == key {
                            
                            self.playerLayer2 = AVPlayerLayer(player: player)
                            self.playerLayer2?.videoGravity = AVLayerVideoGravityResizeAspectFill
                            self.playerLayer2?.frame = videoCell.bounds
                            
                            if let layer = self.playerLayer2 {
                                
                                videoCell.videoOutlet.layer.addSublayer(layer)
                                
                            }
                            
                            if self.videoWithSound == key {
                                
                                self.player2?.muted = false
                                
                            } else {
                                
                                self.player2?.muted = true
                                
                            }


                            self.player2?.play()
                            
                        }
                    })
                    
                    
                } else {
                    
                    if let key = newPosts[indexPath.section]["postChildKey"] as? String {
                        
                        var asset: AVAsset?
                        
                        if let loadedAsset = videoAssets[key] {
                            
                            asset = loadedAsset
                            
                        } else if let urlString = newPosts[indexPath.section]["videoURL"] as? String, url = NSURL(string: urlString) {
                            
                            asset = AVAsset(URL: url)
                            
                        }
                        
                        if let actualAsset = asset {
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                let playerItem = AVPlayerItem(asset: actualAsset)
                                self.playerKeys[0] = key
                                self.player2 = AVPlayer(playerItem: playerItem)
                                self.player2?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                                self.player2Observing = true
                                
                                self.playerLayer2 = AVPlayerLayer(player: self.player2)
                                self.playerLayer2?.videoGravity = AVLayerVideoGravityResizeAspectFill
                                self.playerLayer2?.frame = videoCell.bounds
                                
                                if let layer = self.playerLayer2 {
                                    
                                    videoCell.videoOutlet.layer.addSublayer(layer)
                                    
                                }
                                
                                if self.videoWithSound == key {
                                    
                                    self.player2?.muted = false
                                    
                                } else {
                                    
                                    self.player2?.muted = true
                                    
                                }

                                self.player2?.play()
                            })
                        }
                    }
                }
                
            } else if videoCell.playerTitle == "player3" {
                
                if let player = player3 {
                    
                    if !player3Observing {
                        
                        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                        self.player3Observing = true
    
                    }

                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if videoCell.postKey == key {

                            self.playerLayer3 = AVPlayerLayer(player: player)
                            self.playerLayer3?.videoGravity = AVLayerVideoGravityResizeAspectFill
                            self.playerLayer3?.frame = videoCell.bounds
                            
                            if let layer = self.playerLayer3 {
                                
                                videoCell.videoOutlet.layer.addSublayer(layer)
                                
                            }
                            
                            if self.videoWithSound == key {
                                
                                self.player3?.muted = false
                                
                            } else {
                                
                                self.player3?.muted = true
                                
                            }

                            
                            self.player3?.play()
                            
                        }
                    })
                    
                } else {
                    
                    if let key = newPosts[indexPath.section]["postChildKey"] as? String {
                        
                        var asset: AVAsset?
                        
                        if let loadedAsset = videoAssets[key] {
                            
                            asset = loadedAsset
                            
                        } else if let urlString = newPosts[indexPath.section]["videoURL"] as? String, url = NSURL(string: urlString) {
                            
                            asset = AVAsset(URL: url)
                            
                        }
                        
                        if let actualAsset = asset {
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                let playerItem = AVPlayerItem(asset: actualAsset)
                                self.playerKeys[0] = key
                                self.player3 = AVPlayer(playerItem: playerItem)
                                self.player3?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                                self.player3Observing = true
                                
                                self.playerLayer3 = AVPlayerLayer(player: self.player3)
                                self.playerLayer3?.videoGravity = AVLayerVideoGravityResizeAspectFill
                                self.playerLayer3?.frame = videoCell.bounds
                                
                                if let layer = self.playerLayer3 {
                                    
                                    videoCell.videoOutlet.layer.addSublayer(layer)
                                    
                                }
                                
                                if self.videoWithSound == key {
                                    
                                    self.player3?.muted = false
                                    
                                } else {
                                    
                                    self.player3?.muted = true
                                    
                                }

                                self.player3?.play()
                                
                            })
                        }
                    }
                }
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
                    
                    if let  imageUrlString = newPosts[indexPath.section]["imageURL"] as? String, imageUrl = NSURL(string: imageUrlString), key = newPosts[indexPath.section]["postChildKey"] as? String {
                        
                        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath: indexPath) as! VideoVibeCollectionCell
                        
                        cell.postKey = key
                        
                        var isPlaying = false
                        var playerForCell = 0
                        
                        for i in 0..<playerKeys.count {
                            
                            if playerKeys[i] == "" {
                                
                                playerForCell = i
                                
                            }
                        }
                        
                        for i in 0..<playerKeys.count {
                            
                            if playerKeys[i] == key {
                                
                                isPlaying = true
                                playerForCell = i
                                
                            }
                        }
                        
                        if !isPlaying {
                            
                            cell.createIndicator()
                            
                        }
                        
                        if playerForCell == 0 {
                            
                            playerKeys[0] = key
                            cell.playerTitle = "player1"
                            
                        } else if playerForCell == 1 {
                            
                            playerKeys[1] = key
                            cell.playerTitle = "player2"
                            
                        } else if playerForCell == 2 {
                            
                            playerKeys[2] = key
                            cell.playerTitle = "player3"
                            
                        }
                        
                        cell.vibesController = self

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
        
        if indexPath.section <= endedDisplaying {
            
            if scrollingUp {
                
                contentOffsetToShowNavAt = collectionView.contentOffset.y
                beganDisplaying = indexPath.section
                
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        
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
            
            if let player = object as? AVPlayer, item = player.currentItem {
                
                if CMTimeGetSeconds(player.currentTime()) == CMTimeGetSeconds(item.duration) {
                    
                    player.seekToTime(kCMTimeZero)
                    player.play()
                    
                } else if player.rate == 0 {
                    
                    player.play()
                    
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(true)
        
        if let player = player1 {
            
            player.removeObserver(self, forKeyPath: "rate")
            playerKeys[0] = ""
            player.pause()
            player1 = nil
            
        } else if let player = player2 {
            
            player.removeObserver(self, forKeyPath: "rate")
            playerKeys[1] = ""
            player.pause()
            player2 = nil
            
        } else if let player = player3 {
            
            player.removeObserver(self, forKeyPath: "rate")
            playerKeys[2] = ""
            player.pause()
            player3 = nil
            
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
        
        self.videoAssets.removeAll()
        
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
