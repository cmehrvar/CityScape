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
    var newPosts = [[NSObject : AnyObject]]()
    var addedPosts = [String : Bool]()
    
    var globFirstMessages = [[NSObject : AnyObject]]()
    var globSecondMessages = [[NSObject : AnyObject]]()
    var globThirdMessages = [[NSObject : AnyObject]]()
    
    var videoAssets = [String : AVAsset]()
    var videoPlayers = [AVPlayer?]()
    var videoPlayersObserved = [Bool]()
    var videoLayers = [AVPlayerLayer?]()
    var videoKeys = [String?]()
    
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
    
    func setPlayerTitle(postKey: String, cell: UICollectionViewCell) {
        
        var playerForCell = 0
        
        for i in 0..<8 {
            
            if videoKeys[i] == nil {
                
                playerForCell = i
                
            }
        }
        
        for i in 0..<8 {
            
            if videoKeys[i] == postKey {
                
                playerForCell = i
                
            }
        }
        
        videoKeys[playerForCell] = postKey
        
        if let postVideo = cell as? VideoVibeCollectionCell {
            
            postVideo.player = playerForCell
            
        } else if let inVideo = cell as? InMediaCollectionCell {
            
            if !inVideo.isImage {
                
                inVideo.player = playerForCell
                
            }
        } else if let inVideo = cell as? OutMediaCollectionCell {
            
            if !inVideo.isImage {
                
                inVideo.player = playerForCell
                
            }
        }
    }
    
    
    //CollectionView Delegates
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if !newPosts.isEmpty {
            
            var shouldRemove = false
            
            var isVisible = false
            
            for visibleCell in collectionView.visibleCells() {
                
                if let visibleVideo = visibleCell as? VideoVibeCollectionCell {
                    
                    if visibleVideo.postKey == self.newPosts[indexPath.section]["postChildKey"] as? String {
                        
                        isVisible = true
                        
                    }
                    
                } else {
                    
                    if let visibleVideo = visibleCell as? InMediaCollectionCell {
                        
                        if !visibleVideo.isImage {
                            
                            if indexPath.row == 4 {
                                
                                if visibleVideo.key == self.globFirstMessages[indexPath.section]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                                
                                
                            } else if indexPath.row == 5 {
                                
                                if visibleVideo.key == self.globSecondMessages[indexPath.section]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                                
                            } else if indexPath.row == 6 {
                                
                                if visibleVideo.key == self.globThirdMessages[indexPath.section]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                            }
                        }
                        
                    } else if let visibleVideo = visibleCell as? OutMediaCollectionCell {
                        
                        if !visibleVideo.isImage {
                            
                            if indexPath.row == 4 {
                                
                                if visibleVideo.key == self.globFirstMessages[indexPath.section]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                                
                            } else if indexPath.row == 5 {
                                
                                if visibleVideo.key == self.globSecondMessages[indexPath.section]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                                
                            } else if indexPath.row == 6 {
                                
                                if visibleVideo.key == self.globThirdMessages[indexPath.section]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                            }
                        }
                    }
                }
            }
            
            var playerNumber = 0
            
            if let videoCell = cell as? VideoVibeCollectionCell {
                
                shouldRemove = true
                playerNumber = videoCell.player
                
            } else if let inCell = cell as? InMediaCollectionCell {
                
                if !inCell.isImage {
                    
                    shouldRemove = true
                    playerNumber = inCell.player
                    
                }
                
            } else if let outCell = cell as? OutMediaCollectionCell {
                
                if !outCell.isImage {
                    
                    shouldRemove = true
                    playerNumber = outCell.player
                    
                }
            }
            
            if let player = videoPlayers[playerNumber] {
                
                if videoPlayersObserved[playerNumber] && shouldRemove {
                    
                    player.removeObserver(self, forKeyPath: "rate")
                    videoPlayersObserved[playerNumber] = false
                    
                }
            }
            
            if !isVisible && shouldRemove {
                
                if let videoCell = cell as? VideoVibeCollectionCell {
                    
                    if let subLayers = videoCell.videoOutlet.layer.sublayers {
                        
                        for layer in subLayers {
                            
                            layer.removeFromSuperlayer()
                            
                        }
                    }
                    
                } else if let videoCell = cell as? InMediaCollectionCell {
                    
                    if !videoCell.isImage  {
                        
                        if let subLayers = videoCell.videoOutlet.layer.sublayers {
                            
                            for layer in subLayers {
                                
                                layer.removeFromSuperlayer()
                                
                            }
                        }
                    }
                    
                } else if let videoCell = cell as? OutMediaCollectionCell {
                    
                    if !videoCell.isImage  {
                        
                        if let subLayers = videoCell.videoOutlet.layer.sublayers {
                            
                            for layer in subLayers {
                                
                                layer.removeFromSuperlayer()
                                
                            }
                        }
                    }
                }
                
                videoLayers[playerNumber]?.removeFromSuperlayer()
                videoLayers[playerNumber] = nil
                videoKeys[playerNumber] = nil
                videoPlayers[playerNumber]?.pause()
                videoPlayers[playerNumber] = nil
                
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        var shouldAdd = false
        
        var key = ""
        var playerNumber = 0
        
        if let postVideo = cell as? VideoVibeCollectionCell {
            
            shouldAdd = true
            key = postVideo.postKey
            playerNumber = postVideo.player
            
        } else if let inVideo = cell as? InMediaCollectionCell {
            
            if !inVideo.isImage {
                
                shouldAdd = true
                key = inVideo.key
                playerNumber = inVideo.player
                
            }
            
        } else if let outVideo = cell as? OutMediaCollectionCell {
            
            if !outVideo.isImage {
                
                shouldAdd = true
                key = outVideo.key
                playerNumber = outVideo.player
                
            }
        }
        
        if shouldAdd {
            
            if let player = videoPlayers[playerNumber] {
                
                if !videoPlayersObserved[playerNumber] {
                    
                    player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                    videoPlayersObserved[playerNumber] = true
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.videoLayers[playerNumber] = AVPlayerLayer(player: player)
                    
                    if let layer = self.videoLayers[playerNumber] {
                        
                        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
                        
                        if let postVideo = cell as? VideoVibeCollectionCell {
                            
                            layer.frame = postVideo.bounds
                            
                            postVideo.videoOutlet.layer.addSublayer(layer)
                            
                            if postVideo.postKey == self.videoWithSound {
                                
                                postVideo.soundImageOutlet.image = UIImage(named: "mute")
                                postVideo.soundLabelOutlet.text = "Tap to mute"
                                player.muted = false
                                
                            } else {
                                
                                postVideo.soundImageOutlet.image = UIImage(named: "unmute")
                                postVideo.soundLabelOutlet.text = "Tap for sound"
                                player.muted = true
                                
                            }
                            
                        } else if let inVideo = cell as? InMediaCollectionCell {
                            
                            if !inVideo.isImage {
                                
                                layer.frame = inVideo.bounds
                                inVideo.videoOutlet.layer.addSublayer(layer)
                                player.muted = true
                                
                            }
                            
                        } else if let outVideo = cell as? OutMediaCollectionCell {
                            
                            if !outVideo.isImage {
                                
                                layer.frame = outVideo.bounds
                                player.muted = true
                                outVideo.videoOutlet.layer.addSublayer(layer)
                                
                            }
                        }
                        
                        player.play()
                        
                    }
                })
            } else {
                
                var asset: AVAsset?
                
                if let loadedAsset = videoAssets[key] {
                    
                    asset = loadedAsset
                    
                } else {
                    
                    if cell is VideoVibeCollectionCell {
                        
                        if let urlString = newPosts[indexPath.section]["videoURL"] as? String, url = NSURL(string: urlString) {
                            
                            asset = AVAsset(URL: url)
                            
                        }
                        
                    } else if cell is InMediaCollectionCell || cell is OutMediaCollectionCell {
                        
                        if indexPath.row == 4 {
                            
                            if let urlString = globFirstMessages[indexPath.section]["media"] as? String, url = NSURL(string: urlString) {
                                
                                asset = AVAsset(URL: url)
                                
                            }
                            
                        } else if indexPath.row == 5 {
                            
                            if let urlString = globSecondMessages[indexPath.section]["media"] as? String, url = NSURL(string: urlString) {
                                
                                asset = AVAsset(URL: url)
                                
                            }
                            
                            
                        } else if indexPath.row == 6 {
                            
                            if let urlString = globThirdMessages[indexPath.section]["media"] as? String, url = NSURL(string: urlString) {
                                
                                asset = AVAsset(URL: url)
                                
                            }
                        }
                    }
                }
                
                if let actualAsset = asset {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        let playerItem = AVPlayerItem(asset: actualAsset)
                        self.videoKeys[playerNumber] = key
                        self.videoPlayers[playerNumber] = AVPlayer(playerItem: playerItem)
                        
                        if let player = self.videoPlayers[playerNumber] {
                            
                            player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                            self.videoPlayersObserved[playerNumber] = true
                            
                            self.videoLayers[playerNumber] = AVPlayerLayer(player: self.videoPlayers[playerNumber])
                            
                            if let layer = self.videoLayers[playerNumber] {
                                
                                layer.videoGravity = AVLayerVideoGravityResizeAspectFill
                                
                                if let postVideo = cell as? VideoVibeCollectionCell {
                                    
                                    self.videoLayers[playerNumber]?.frame = postVideo.bounds
                                    
                                    if postVideo.postKey == self.videoWithSound {
                                        
                                        postVideo.soundImageOutlet.image = UIImage(named: "mute")
                                        postVideo.soundLabelOutlet.text = "Tap to mute"
                                        player.muted = false
                                        
                                    } else {
                                        
                                        postVideo.soundImageOutlet.image = UIImage(named: "unmute")
                                        postVideo.soundLabelOutlet.text = "Tap for sound"
                                        player.muted = true
                                        
                                    }
                                    
                                    postVideo.videoOutlet.layer.addSublayer(layer)
                                    
                                } else if let inVideo = cell as? InMediaCollectionCell {
                                    
                                    if !inVideo.isImage {
                                        
                                        layer.frame = inVideo.bounds
                                        inVideo.videoOutlet.layer.addSublayer(layer)
                                        player.muted = true
                                        
                                    }
                                    
                                } else if let outVideo = cell as? OutMediaCollectionCell {
                                    
                                    if !outVideo.isImage {
                                        
                                        layer.frame = outVideo.bounds
                                        outVideo.videoOutlet.layer.addSublayer(layer)
                                        player.muted = true
                                        
                                    }
                                }
                                
                                player.play()
                                
                            }
                        }
                    })
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
                        
                        cell.soundOutlet.layer.cornerRadius = 5
                        cell.postKey = key
                        
                        setPlayerTitle(key, cell: cell)
                        
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
            
        } else if indexPath.row == 2 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("captionCell", forIndexPath: indexPath) as! CaptionCell
            cell.loadData(newPosts[indexPath.section])
            return cell
            
        } else if indexPath.row == 3 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("timeAgoCell", forIndexPath: indexPath) as! TimeAgoCollectionCell
            cell.loadData(newPosts[indexPath.section])
            return cell
            
        } else if indexPath.row == 4 {
            
            //if incoming -> inCell, else outCell
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if let senderId = globFirstMessages[indexPath.section]["senderId"] as? String {
                    
                    var selfMessage = false
                    
                    if senderId == selfUID {
                        
                        selfMessage = true
                        
                    }
                    
                    if let isMedia = globFirstMessages[indexPath.section]["isMedia"] as? Bool {
                        
                        if !isMedia {
                            
                            if !selfMessage {
                                
                                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("inMessageCell", forIndexPath: indexPath) as! IncomingCollectionCell
                                
                                if let secondId = globSecondMessages[indexPath.section]["senderId"] as? String {
                                    
                                    if secondId == senderId {
                                        
                                        cell.loadData(false, data: globFirstMessages[indexPath.section])
                                        
                                    } else {
                                        
                                        cell.loadData(true, data: globFirstMessages[indexPath.section])
                                        
                                    }
                                    
                                } else {
                                    
                                    cell.loadData(true, data: globFirstMessages[indexPath.section])
                                    
                                }
                                
                                return cell
                                
                                
                            } else {
                                
                                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("outMessageCell", forIndexPath: indexPath) as! OutgoingCollectionCell
                                
                                cell.loadData(globFirstMessages[indexPath.section])
                                return cell
                                
                            }
                            
                        } else {
                            
                            if !selfMessage {
                                
                                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("inMediaCell", forIndexPath: indexPath) as! InMediaCollectionCell
                                
                                
                                if let secondId = globSecondMessages[indexPath.section]["senderId"] as? String {
                                    
                                    if secondId == senderId {
                                        
                                        cell.loadCell(false, message: globFirstMessages[indexPath.section])
                                        
                                    } else {
                                        
                                        cell.loadCell(true, message: globFirstMessages[indexPath.section])
                                        
                                    }
                                    
                                } else {
                                    
                                    cell.loadCell(true, message: globFirstMessages[indexPath.section])
                                    
                                }
                                
                                if let key = globFirstMessages[indexPath.section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            } else {
                                
                                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("outMediaCell", forIndexPath: indexPath) as! OutMediaCollectionCell
                                
                                cell.loadCell(globFirstMessages[indexPath.section])
                                
                                if let key = globFirstMessages[indexPath.section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            }
                        }
                    }
                }
            }
            
        } else if indexPath.row == 5 {
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if let senderId = globSecondMessages[indexPath.section]["senderId"] as? String {
                    
                    var selfMessage = false
                    
                    if senderId == selfUID {
                        
                        selfMessage = true
                        
                    }
                    
                    if let isMedia = globSecondMessages[indexPath.section]["isMedia"] as? Bool {
                        
                        if !isMedia {
                            
                            if !selfMessage {
                                
                                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("inMessageCell", forIndexPath: indexPath) as! IncomingCollectionCell
                                
                                if let thirdId = globThirdMessages[indexPath.section]["senderId"] as? String {
                                    
                                    if thirdId == senderId {
                                        
                                        cell.loadData(false, data: globSecondMessages[indexPath.section])
                                        
                                    } else {
                                        
                                        cell.loadData(true, data: globSecondMessages[indexPath.section])
                                        
                                    }
                                } else {
                                    
                                    cell.loadData(true, data: globSecondMessages[indexPath.section])
                                    
                                }
                                
                                if let key = globSecondMessages[indexPath.section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            } else {
                                
                                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("outMessageCell", forIndexPath: indexPath) as! OutgoingCollectionCell
                                
                                cell.loadData(globSecondMessages[indexPath.section])
                                
                                if let key = globSecondMessages[indexPath.section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            }
                            
                        } else {
                            
                            if !selfMessage {
                                
                                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("inMediaCell", forIndexPath: indexPath) as! InMediaCollectionCell
                                
                                if let thirdId = globThirdMessages[indexPath.section]["senderId"] as? String {
                                    
                                    if thirdId == senderId {
                                        
                                        cell.loadCell(false, message: globSecondMessages[indexPath.section])
                                        
                                    } else {
                                        
                                        cell.loadCell(true, message: globSecondMessages[indexPath.section])
                                        
                                    }
                                    
                                } else {
                                    
                                    cell.loadCell(true, message: globSecondMessages[indexPath.section])
                                    
                                }
                                
                                if let key = globSecondMessages[indexPath.section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            } else {
                                
                                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("outMediaCell", forIndexPath: indexPath) as! OutMediaCollectionCell
                                
                                cell.loadCell(globSecondMessages[indexPath.section])
                                
                                if let key = globSecondMessages[indexPath.section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            }
                        }
                    }
                }
            }
            
        } else if indexPath.row == 6 {
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if let senderId = globThirdMessages[indexPath.section]["senderId"] as? String {
                    
                    var selfMessage = false
                    
                    if senderId == selfUID {
                        
                        selfMessage = true
                        
                    }
                    
                    if let isMedia = globThirdMessages[indexPath.section]["isMedia"] as? Bool {
                        
                        if !isMedia {
                            
                            if !selfMessage {
                                
                                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("inMessageCell", forIndexPath: indexPath) as! IncomingCollectionCell
                                cell.loadData(true, data: globThirdMessages[indexPath.section])
                                return cell
                                
                            } else {
                                
                                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("outMessageCell", forIndexPath: indexPath) as! OutgoingCollectionCell
                                cell.loadData(globThirdMessages[indexPath.section])
                                return cell
                                
                            }
                            
                        } else {
                            
                            if !selfMessage {
                                
                                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("inMediaCell", forIndexPath: indexPath) as! InMediaCollectionCell
                                
                                cell.loadCell(true, message: globThirdMessages[indexPath.section])
                                
                                if let key = globThirdMessages[indexPath.section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            } else {
                                
                                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("outMediaCell", forIndexPath: indexPath) as! OutMediaCollectionCell
                                
                                cell.loadCell(globThirdMessages[indexPath.section])
                                
                                if let key = globThirdMessages[indexPath.section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            }
                        }
                    }
                }
            }
            
        } else if indexPath.row == 7 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("goToChatCell", forIndexPath: indexPath) as! GoToChatCell
            cell.vibesController = self
            cell.loadData(newPosts[indexPath.section])
            return cell
            
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("inMessageCell", forIndexPath: indexPath) as! IncomingCollectionCell
        
        return cell
        
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
        
        return 8
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.view.bounds.width
        
        if indexPath.row == 0 {
            
            return CGSize(width: width, height: width)
            
        } else if indexPath.row == 1 {
            
            return CGSize(width: width, height: 65)
            
        } else if indexPath.row == 2 {
            
            if newPosts[indexPath.section]["caption"] as? String != "" {
                
                return CGSize(width: width, height: 33)
                
            } else {
                
                return CGSize(width: width, height: 0)
                
            }
            
        } else if indexPath.row == 3 {
            
            return CGSize(width: width, height: 25)
            
        } else if indexPath.row == 4 {
            
            if let senderId = globFirstMessages[indexPath.section]["senderId"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                var selfMessage = false
                
                if senderId == selfUID {
                    
                    selfMessage = true
                    
                }
                
                if let isMedia = globFirstMessages[indexPath.section]["isMedia"] as? Bool {
                    
                    if !isMedia {
                        
                        if !selfMessage {
                            
                            if let secondId = globSecondMessages[indexPath.section]["senderId"] as? String {
                                
                                if secondId == senderId {
                                    
                                    return CGSize(width: width, height: 38)
                                    
                                } else {
                                    
                                    return CGSize(width: width, height: 52)
                                    
                                }
                                
                            } else {
                                
                                return CGSize(width: width, height: 52)
                                
                            }
                            
                            
                            
                        } else {
                            
                            return CGSize(width: width, height: 38)
                            
                        }
                        
                    } else {
                        
                        if !selfMessage {
                            
                            if let secondId = globSecondMessages[indexPath.section]["senderID"] as? String {
                                
                                if secondId == senderId {
                                    
                                    return CGSize(width: width, height: 108)
                                    
                                } else {
                                    
                                    return CGSize(width: width, height: 120)
                                    
                                }
                                
                            } else {
                                
                                return CGSize(width: width, height: 120)
                                
                            }
                            
                        } else {
                            
                            return CGSize(width: width, height: 108)
                            
                            
                        }
                    }
                }
                
            } else {
                
                return CGSize(width: width, height: 0)
                
            }
            
        } else if indexPath.row == 5 {
            
            if let senderId = globSecondMessages[indexPath.section]["senderId"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                var selfMessage = false
                
                if senderId == selfUID {
                    
                    selfMessage = true
                    
                }
                
                if let isMedia = globSecondMessages[indexPath.section]["isMedia"] as? Bool {
                    
                    if !isMedia {
                        
                        if !selfMessage {
                            
                            if let thirdId = globThirdMessages[indexPath.section]["senderId"] as? String {
                                
                                if thirdId == senderId {
                                    return CGSize(width: width, height: 38)
                                    
                                } else {
                                    
                                    return CGSize(width: width, height: 52)
                                    
                                }
                            } else {
                                
                                return CGSize(width: width, height: 52)
                                
                            }
                            
                        } else {
                            
                            return CGSize(width: width, height: 38)
                            
                        }
                        
                    } else {
                        
                        if !selfMessage {
                            
                            if let thirdId = globThirdMessages[indexPath.section]["senderId"] as? String {
                                
                                if thirdId == senderId {
                                    return CGSize(width: width, height: 108)
                                    
                                } else {
                                    
                                    return CGSize(width: width, height: 120)
                                    
                                }
                                
                            } else {
                                
                                return CGSize(width: width, height: 120)
                                
                            }
                            
                        } else {
                            
                            return CGSize(width: width, height: 108)
                            
                        }
                    }
                }
            } else {
                
                return CGSize(width: width, height: 0)
                
            }
            
        } else if indexPath.row == 6 {
            
            if let senderId = globThirdMessages[indexPath.section]["senderId"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                var selfMessage = false
                
                if senderId == selfUID {
                    
                    selfMessage = true
                    
                }
                
                if let isMedia = globThirdMessages[indexPath.section]["isMedia"] as? Bool {
                    
                    if !isMedia {
                        
                        if !selfMessage {
                            
                            return CGSize(width: width, height: 52)
                            
                        } else {
                            
                            return CGSize(width: width, height: 38)
                            
                        }
                        
                    } else {
                        
                        if !selfMessage {
                            
                            return CGSize(width: width, height: 120)
                            
                        } else {
                            
                            return CGSize(width: width, height: 108)
                            
                        }
                    }
                }
            } else {
                
                return CGSize(width: width, height: 0)
                
            }
            
        } else if indexPath.row == 7 {
            
            if indexPath.section == newPosts.count - 1 {
                
                return CGSize(width: width, height: 80)
                
            } else {
                
                return CGSize(width: width, height: 36)
                
            }
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
                        
                        var messages = [[NSObject : AnyObject]]()
                        
                        for post in scopeData {
                            
                            if let message = post["messages"] as? [NSObject : AnyObject] {
                                
                                messages.append(message)
                                
                            } else {
                                
                                messages.append([NSObject : AnyObject]())
                                
                            }
                        }
                        
                        var firstMessages = [[NSObject : AnyObject]]()
                        var secondMessages = [[NSObject : AnyObject]]()
                        var thirdMessages = [[NSObject : AnyObject]]()

                        for message in messages {
                            
                            var messageArray = [[NSObject : AnyObject]]()
                            
                            for singleMessage in message {
                                
                                if let messageToAdd = singleMessage.1 as? [NSObject : AnyObject] {
                                    
                                    messageArray.append(messageToAdd)
                                    
                                }
                            }
                            
                            messageArray.sortInPlace({ (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
                                
                                if a["timeStamp"] as? NSTimeInterval > b["timeStamp"] as? NSTimeInterval {
                                    
                                    return true
                                    
                                } else {
                                    
                                    return false
                                    
                                }
                            })
                            
                            
                            if messageArray.count > 0 {
                                
                                thirdMessages.append(messageArray[0])
                                
                                if messageArray.count > 1 {
                                    
                                    secondMessages.append(messageArray[1])
                                    
                                    if messageArray.count > 2 {
                                        
                                        firstMessages.append(messageArray[2])
                                        
                                    } else {
                                        
                                        firstMessages.append([NSObject : AnyObject]())
                                        
                                    }
                                    
                                } else {
                                    
                                    firstMessages.append([NSObject : AnyObject]())
                                    secondMessages.append([NSObject : AnyObject]())
                                    
                                }
                                
                            } else {
                                
                                firstMessages.append([NSObject : AnyObject]())
                                secondMessages.append([NSObject : AnyObject]())
                                thirdMessages.append([NSObject : AnyObject]())
                                
                            }
                        }
    
                        self.globFirstMessages = firstMessages
                        self.globSecondMessages = secondMessages
                        self.globThirdMessages = thirdMessages
                        
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
                        
                        var messages = [[NSObject : AnyObject]]()
                        
                        for post in scopeData {
                            
                            if let message = post["messages"] as? [NSObject : AnyObject] {
                                
                                messages.append(message)
                                
                            } else {
                                
                                messages.append([NSObject : AnyObject]())
                                
                            }
                        }
                        
                        var firstMessages = [[NSObject : AnyObject]]()
                        var secondMessages = [[NSObject : AnyObject]]()
                        var thirdMessages = [[NSObject : AnyObject]]()
                        
                        var messageArray = [[NSObject : AnyObject]]()
                        
                        for message in messages {
                            
                            for singleMessage in message {
                                
                                if let messageToAdd = singleMessage.1 as? [NSObject : AnyObject] {
                                    
                                    messageArray.append(messageToAdd)
                                    
                                }
                            }
                            
                        }
                        
                        messageArray.sortInPlace({ (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
                            
                            if a["timeStamp"] as? NSTimeInterval > b["timeStamp"] as? NSTimeInterval {
                                
                                return true
                                
                            } else {
                                
                                return false
                                
                            }
                        })
                        
                        
                        if messageArray.count > 0 {
                            
                            firstMessages.insert(messageArray[0], atIndex: 0)
                            
                            if messageArray.count > 1 {
                                
                                secondMessages.insert(messageArray[1], atIndex: 0)
                                
                                if messageArray.count > 2 {
                                    
                                    thirdMessages.insert(messageArray[2], atIndex: 0)
                                    
                                } else {
                                    
                                    thirdMessages.insert([NSObject : AnyObject](), atIndex: 0)
                                    
                                }
                                
                            } else {
                                
                                secondMessages.insert([NSObject : AnyObject](), atIndex: 0)
                                thirdMessages.insert([NSObject : AnyObject](), atIndex: 0)
                                
                            }
                            
                        } else {
                            
                            firstMessages.insert([NSObject : AnyObject](), atIndex: 0)
                            secondMessages.insert([NSObject : AnyObject](), atIndex: 0)
                            thirdMessages.insert([NSObject : AnyObject](), atIndex: 0)
                            
                        }
                        
                        self.globFirstMessages = firstMessages
                        self.globSecondMessages = secondMessages
                        self.globThirdMessages = thirdMessages
                        
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
    
    
    override func viewDidAppear(animated: Bool) {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<8 {
            
            videoPlayersObserved.append(false)
            videoLayers.append(nil)
            videoPlayers.append(nil)
            videoKeys.append(nil)
            
        }
        
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
