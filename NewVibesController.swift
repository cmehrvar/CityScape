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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class NewVibesController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var refresher:UIRefreshControl!
    
    var videoWithSound = ""
    
    //Variables
    weak var rootController: MainRootController?
    var transitioning = false
    var newPosts = [[AnyHashable: Any]]()
    var addedPosts = [String : Bool]()
    
    var globFirstMessages = [[AnyHashable: Any]]()
    var globSecondMessages = [[AnyHashable: Any]]()
    var globThirdMessages = [[AnyHashable: Any]]()
    
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
    @IBOutlet weak var noPostsOutlet: UIImageView!
    
    
    
    
    func setPlayerTitle(_ postKey: String, cell: UICollectionViewCell) {
        
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
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if !newPosts.isEmpty {
            
            var shouldRemove = false
            
            var isVisible = false
            
            for visibleCell in collectionView.visibleCells {
                
                if let visibleVideo = visibleCell as? VideoVibeCollectionCell {
                    
                    if visibleVideo.postKey == self.newPosts[(indexPath as NSIndexPath).section]["postChildKey"] as? String {
                        
                        isVisible = true
                        
                    }
                    
                } else {
                    
                    if let visibleVideo = visibleCell as? InMediaCollectionCell {
                        
                        if !visibleVideo.isImage {
                            
                            if (indexPath as NSIndexPath).row == 4 {
                                
                                if visibleVideo.key == self.globFirstMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                                
                                
                            } else if (indexPath as NSIndexPath).row == 5 {
                                
                                if visibleVideo.key == self.globSecondMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                                
                            } else if (indexPath as NSIndexPath).row == 6 {
                                
                                if visibleVideo.key == self.globThirdMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                            }
                        }
                        
                    } else if let visibleVideo = visibleCell as? OutMediaCollectionCell {
                        
                        if !visibleVideo.isImage {
                            
                            if (indexPath as NSIndexPath).row == 4 {
                                
                                if visibleVideo.key == self.globFirstMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                                
                            } else if (indexPath as NSIndexPath).row == 5 {
                                
                                if visibleVideo.key == self.globSecondMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                                
                            } else if (indexPath as NSIndexPath).row == 6 {
                                
                                if visibleVideo.key == self.globThirdMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
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
                    
                    for view in videoCell.videoThumbnailOutlet.subviews  {
                        
                        view.removeFromSuperview()
                        
                    }
                    
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        var shouldAdd = false
        
        var key = ""
        var playerNumber = 0
        
        if let postVideo = cell as? VideoVibeCollectionCell {
            
            postVideo.createIndicator()
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
                
                DispatchQueue.main.async(execute: {
                    
                    
                    self.videoLayers[playerNumber] = AVPlayerLayer(player: player)
                    
                    if let layer = self.videoLayers[playerNumber] {
                        
                        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
                        
                        if let postVideo = cell as? VideoVibeCollectionCell {
                            
                            layer.frame = postVideo.bounds
                            
                            postVideo.videoOutlet.layer.addSublayer(layer)
                            
                            if postVideo.postKey == self.videoWithSound {
                                
                                postVideo.soundImageOutlet.image = UIImage(named: "unmute")
                                postVideo.soundLabelOutlet.text = "Tap to mute"
                                player.isMuted = false
                                
                            } else {
                                
                                postVideo.soundImageOutlet.image = UIImage(named: "mute")
                                postVideo.soundLabelOutlet.text = "Tap for sound"
                                player.isMuted = true
                                
                            }
                            
                        } else if let inVideo = cell as? InMediaCollectionCell {
                            
                            if !inVideo.isImage {
                                
                                layer.frame = inVideo.bounds
                                inVideo.videoOutlet.layer.addSublayer(layer)
                                player.isMuted = true
                                
                            }
                            
                        } else if let outVideo = cell as? OutMediaCollectionCell {
                            
                            if !outVideo.isImage {
                                
                                layer.frame = outVideo.bounds
                                player.isMuted = true
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
                        
                        if let urlString = newPosts[(indexPath as NSIndexPath).section]["videoURL"] as? String, let url = URL(string: urlString) {
                            
                            asset = AVAsset(url: url)
                            
                        }
                        
                    } else if cell is InMediaCollectionCell || cell is OutMediaCollectionCell {
                        
                        if (indexPath as NSIndexPath).row == 4 {
                            
                            if let urlString = globFirstMessages[(indexPath as NSIndexPath).section]["media"] as? String, let url = URL(string: urlString) {
                                
                                asset = AVAsset(url: url)
                                
                            }
                            
                        } else if (indexPath as NSIndexPath).row == 5 {
                            
                            if let urlString = globSecondMessages[(indexPath as NSIndexPath).section]["media"] as? String, let url = URL(string: urlString) {
                                
                                asset = AVAsset(url: url)
                                
                            }
                            
                            
                        } else if (indexPath as NSIndexPath).row == 6 {
                            
                            if let urlString = globThirdMessages[(indexPath as NSIndexPath).section]["media"] as? String, let url = URL(string: urlString) {
                                
                                asset = AVAsset(url: url)
                                
                            }
                        }
                    }
                }
                
                if let actualAsset = asset {
                    
                    DispatchQueue.main.async(execute: {
                        
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
                                        
                                        postVideo.soundImageOutlet.image = UIImage(named: "unmute")
                                        postVideo.soundLabelOutlet.text = "Tap to mute"
                                        player.isMuted = false
                                        
                                    } else {
                                        
                                        postVideo.soundImageOutlet.image = UIImage(named: "mute")
                                        postVideo.soundLabelOutlet.text = "Tap for sound"
                                        player.isMuted = true
                                        
                                    }
                                    
                                    postVideo.videoOutlet.layer.addSublayer(layer)
                                    
                                } else if let inVideo = cell as? InMediaCollectionCell {
                                    
                                    if !inVideo.isImage {
                                        
                                        layer.frame = inVideo.bounds
                                        inVideo.videoOutlet.layer.addSublayer(layer)
                                        player.isMuted = true
                                        
                                    }
                                    
                                } else if let outVideo = cell as? OutMediaCollectionCell {
                                    
                                    if !outVideo.isImage {
                                        
                                        layer.frame = outVideo.bounds
                                        outVideo.videoOutlet.layer.addSublayer(layer)
                                        player.isMuted = true
                                        
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
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if (indexPath as NSIndexPath).row == 0 {
            
            if let isImage = newPosts[(indexPath as NSIndexPath).section]["isImage"] as? Bool {
                
                if isImage {
                    
                    if let urlString = newPosts[(indexPath as NSIndexPath).section]["imageURL"] as? String, let url = URL(string: urlString){
                        
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageVibeCollectionCell
                        cell.createIndicator()
                        cell.loadImage(url)
                        cell.addPinchRecognizer()
                        return cell
                    }
                    
                } else {
                    
                    if let  imageUrlString = newPosts[(indexPath as NSIndexPath).section]["imageURL"] as? String, let imageUrl = URL(string: imageUrlString), let key = newPosts[(indexPath as NSIndexPath).section]["postChildKey"] as? String {
                        
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoVibeCollectionCell
                        
                        cell.soundOutlet.layer.cornerRadius = 5
                        cell.postKey = key
                        
                        setPlayerTitle(key, cell: cell)
                        
                        cell.vibesController = self
                        
                        cell.videoThumbnailOutlet.sd_setImage(with: imageUrl, completed: { (image, error, cache, url) in
                            
                            print("done loading video thumbnail")
                            
                        })
                        
                        return cell
                        
                    }
                }
            }
            
            
        } else if (indexPath as NSIndexPath).row == 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "buttonsCell", for: indexPath) as! LikeButtonsCollectionCell
            
            cell.vibesController = self
            cell.loadData(newPosts[(indexPath as NSIndexPath).section])
            
            return cell
            
        } else if (indexPath as NSIndexPath).row == 2 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "captionCell", for: indexPath) as! CaptionCell
            cell.loadData(newPosts[(indexPath as NSIndexPath).section])
            return cell
            
        } else if (indexPath as NSIndexPath).row == 3 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeAgoCell", for: indexPath) as! TimeAgoCollectionCell
            cell.loadData(newPosts[(indexPath as NSIndexPath).section])
            return cell
            
        } else if (indexPath as NSIndexPath).row == 4 {
            
            //if incoming -> inCell, else outCell
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if let senderId = globFirstMessages[(indexPath as NSIndexPath).section]["senderId"] as? String {
                    
                    var selfMessage = false
                    
                    if senderId == selfUID {
                        
                        selfMessage = true
                        
                    }
                    
                    if let isMedia = globFirstMessages[(indexPath as NSIndexPath).section]["isMedia"] as? Bool {
                        
                        if !isMedia {
                            
                            if !selfMessage {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMessageCell", for: indexPath) as! IncomingCollectionCell
                                
                                if let secondId = globSecondMessages[(indexPath as NSIndexPath).section]["senderId"] as? String {
                                    
                                    if secondId == senderId {
                                        
                                        cell.loadData(false, data: globFirstMessages[(indexPath as NSIndexPath).section])
                                        
                                    } else {
                                        
                                        cell.loadData(true, data: globFirstMessages[(indexPath as NSIndexPath).section])
                                        
                                    }
                                    
                                } else {
                                    
                                    cell.loadData(true, data: globFirstMessages[(indexPath as NSIndexPath).section])
                                    
                                }
                                
                                return cell
                                
                                
                            } else {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outMessageCell", for: indexPath) as! OutgoingCollectionCell
                                
                                cell.loadData(globFirstMessages[(indexPath as NSIndexPath).section])
                                return cell
                                
                            }
                            
                        } else {
                            
                            if !selfMessage {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMediaCell", for: indexPath) as! InMediaCollectionCell
                                
                                
                                if let secondId = globSecondMessages[(indexPath as NSIndexPath).section]["senderId"] as? String {
                                    
                                    if secondId == senderId {
                                        
                                        cell.loadCell(false, message: globFirstMessages[(indexPath as NSIndexPath).section])
                                        
                                    } else {
                                        
                                        cell.loadCell(true, message: globFirstMessages[(indexPath as NSIndexPath).section])
                                        
                                    }
                                    
                                } else {
                                    
                                    cell.loadCell(true, message: globFirstMessages[(indexPath as NSIndexPath).section])
                                    
                                }
                                
                                if let key = globFirstMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            } else {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outMediaCell", for: indexPath) as! OutMediaCollectionCell
                                
                                cell.loadCell(globFirstMessages[(indexPath as NSIndexPath).section])
                                
                                if let key = globFirstMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            }
                        }
                    }
                }
            }
            
        } else if (indexPath as NSIndexPath).row == 5 {
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if let senderId = globSecondMessages[(indexPath as NSIndexPath).section]["senderId"] as? String {
                    
                    var selfMessage = false
                    
                    if senderId == selfUID {
                        
                        selfMessage = true
                        
                    }
                    
                    if let isMedia = globSecondMessages[(indexPath as NSIndexPath).section]["isMedia"] as? Bool {
                        
                        if !isMedia {
                            
                            if !selfMessage {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMessageCell", for: indexPath) as! IncomingCollectionCell
                                
                                if let thirdId = globThirdMessages[(indexPath as NSIndexPath).section]["senderId"] as? String {
                                    
                                    if thirdId == senderId {
                                        
                                        cell.loadData(false, data: globSecondMessages[(indexPath as NSIndexPath).section])
                                        
                                    } else {
                                        
                                        cell.loadData(true, data: globSecondMessages[(indexPath as NSIndexPath).section])
                                        
                                    }
                                } else {
                                    
                                    cell.loadData(true, data: globSecondMessages[(indexPath as NSIndexPath).section])
                                    
                                }
                                
                                if let key = globSecondMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            } else {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outMessageCell", for: indexPath) as! OutgoingCollectionCell
                                
                                cell.loadData(globSecondMessages[(indexPath as NSIndexPath).section])
                                
                                if let key = globSecondMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            }
                            
                        } else {
                            
                            if !selfMessage {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMediaCell", for: indexPath) as! InMediaCollectionCell
                                
                                if let thirdId = globThirdMessages[(indexPath as NSIndexPath).section]["senderId"] as? String {
                                    
                                    if thirdId == senderId {
                                        
                                        cell.loadCell(false, message: globSecondMessages[(indexPath as NSIndexPath).section])
                                        
                                    } else {
                                        
                                        cell.loadCell(true, message: globSecondMessages[(indexPath as NSIndexPath).section])
                                        
                                    }
                                    
                                } else {
                                    
                                    cell.loadCell(true, message: globSecondMessages[(indexPath as NSIndexPath).section])
                                    
                                }
                                
                                if let key = globSecondMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            } else {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outMediaCell", for: indexPath) as! OutMediaCollectionCell
                                
                                cell.loadCell(globSecondMessages[(indexPath as NSIndexPath).section])
                                
                                if let key = globSecondMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            }
                        }
                    }
                }
            }
            
        } else if (indexPath as NSIndexPath).row == 6 {
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if let senderId = globThirdMessages[(indexPath as NSIndexPath).section]["senderId"] as? String {
                    
                    var selfMessage = false
                    
                    if senderId == selfUID {
                        
                        selfMessage = true
                        
                    }
                    
                    if let isMedia = globThirdMessages[(indexPath as NSIndexPath).section]["isMedia"] as? Bool {
                        
                        if !isMedia {
                            
                            if !selfMessage {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMessageCell", for: indexPath) as! IncomingCollectionCell
                                cell.loadData(true, data: globThirdMessages[(indexPath as NSIndexPath).section])
                                return cell
                                
                            } else {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outMessageCell", for: indexPath) as! OutgoingCollectionCell
                                cell.loadData(globThirdMessages[(indexPath as NSIndexPath).section])
                                return cell
                                
                            }
                            
                        } else {
                            
                            if !selfMessage {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMediaCell", for: indexPath) as! InMediaCollectionCell
                                
                                cell.loadCell(true, message: globThirdMessages[(indexPath as NSIndexPath).section])
                                
                                if let key = globThirdMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            } else {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outMediaCell", for: indexPath) as! OutMediaCollectionCell
                                
                                cell.loadCell(globThirdMessages[(indexPath as NSIndexPath).section])
                                
                                if let key = globThirdMessages[(indexPath as NSIndexPath).section]["key"] as? String {
                                    
                                    setPlayerTitle(key, cell: cell)
                                    
                                }
                                
                                return cell
                                
                            }
                        }
                    }
                }
            }
            
        } else if (indexPath as NSIndexPath).row == 7 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "goToChatCell", for: indexPath) as! GoToChatCell
            cell.vibesController = self
            cell.loadData(newPosts[(indexPath as NSIndexPath).section])
           
            return cell
            
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMessageCell", for: indexPath) as! IncomingCollectionCell
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell", for: indexPath) as! VibeHeaderCollectionCell
            
            cell.vibesController = self
            cell.loadCell(newPosts[(indexPath as NSIndexPath).section])
            
            reusableView = cell
            
        }
        
        return reusableView
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return newPosts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 8
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
 
        let width = self.view.bounds.width

        if (indexPath as NSIndexPath).row == 0 {
            
            return CGSize(width: width, height: width)
            
        } else if (indexPath as NSIndexPath).row == 1 {
            
            return CGSize(width: width, height: 65)
            
        } else if (indexPath as NSIndexPath).row == 2 {
            
            if newPosts[(indexPath as NSIndexPath).section]["caption"] as? String != "" {
                
                return CGSize(width: width, height: 33)
                
            } else {
                
                return CGSize(width: width, height: 0)
                
            }
            
        } else if (indexPath as NSIndexPath).row == 3 {
            
            return CGSize(width: width, height: 25)
            
        } else if (indexPath as NSIndexPath).row == 4 {
            
            if let senderId = globFirstMessages[(indexPath as NSIndexPath).section]["senderId"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                var selfMessage = false
                
                if senderId == selfUID {
                    
                    selfMessage = true
                    
                }
                
                if let isMedia = globFirstMessages[(indexPath as NSIndexPath).section]["isMedia"] as? Bool {
                    
                    if !isMedia {
                        
                        if !selfMessage {
                            
                            if let secondId = globSecondMessages[(indexPath as NSIndexPath).section]["senderId"] as? String {
                                
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
                            
                            if let secondId = globSecondMessages[(indexPath as NSIndexPath).section]["senderID"] as? String {
                                
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
            
        } else if (indexPath as NSIndexPath).row == 5 {
            
            if let senderId = globSecondMessages[(indexPath as NSIndexPath).section]["senderId"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                var selfMessage = false
                
                if senderId == selfUID {
                    
                    selfMessage = true
                    
                }
                
                if let isMedia = globSecondMessages[(indexPath as NSIndexPath).section]["isMedia"] as? Bool {
                    
                    if !isMedia {
                        
                        if !selfMessage {
                            
                            if let thirdId = globThirdMessages[(indexPath as NSIndexPath).section]["senderId"] as? String {
                                
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
                            
                            if let thirdId = globThirdMessages[(indexPath as NSIndexPath).section]["senderId"] as? String {
                                
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
            
        } else if (indexPath as NSIndexPath).row == 6 {
            
            if let senderId = globThirdMessages[(indexPath as NSIndexPath).section]["senderId"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                var selfMessage = false
                
                if senderId == selfUID {
                    
                    selfMessage = true
                    
                }
                
                if let isMedia = globThirdMessages[(indexPath as NSIndexPath).section]["isMedia"] as? Bool {
                    
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
            
        } else if (indexPath as NSIndexPath).row == 7 {
            
            if (indexPath as NSIndexPath).section == newPosts.count - 1 {
                
                return CGSize(width: width, height: 80)
                
            } else {
                
                return CGSize(width: width, height: 36)
                
            }
        }
        
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = self.view.bounds.width
        
        return CGSize(width: width, height: 50)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section <= endedDisplaying {
            
            if scrollingUp {
                
                contentOffsetToShowNavAt = collectionView.contentOffset.y
                beganDisplaying = (indexPath as NSIndexPath).section
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        
        endedDisplaying = (indexPath as NSIndexPath).section
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollingUp && (scrollView.contentOffset.y < 75) {
            
            rootController?.showNav(0.3, completion: { (bool) in
                
                print("nav shown")
                
                self.navHidden = false
                self.showingNav = false
                
            })
        }
        
        
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
    
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
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
        
        self.refresher.endRefreshing()
        
        observingCity = currentCity
        let scopeCity = currentCity
        
        self.rootController?.bottomNavController?.torontoOutlet.text = scopeCity
        
        self.newPosts.removeAll()
        self.addedPosts.removeAll()
        //self.videoPlayers.removeAll()
        
        if scopeCity != "" {
            
            self.rootController?.bottomNavController?.torontoOutlet.text = self.currentCity
            
            let ref = FIRDatabase.database().reference().child("posts").child(self.currentCity)
            
            ref.queryLimited(toLast: 100).observe(.value, with: { (snapshot) in
                
                if !snapshot.exists() {
                    
                    self.noPostsOutlet.alpha = 1
                    
                } else {
                    
                    self.noPostsOutlet.alpha = 0
                    
                }

                var scopeData = [[AnyHashable: Any]]()
                
                if let value = snapshot.value as? [AnyHashable: Any] {
                    
                    if self.observingCity != scopeCity {
                        
                        ref.removeAllObservers()
                        
                    } else {
                        
                        for (_, snapValue) in value {
                            
                            if let valueToAdd = snapValue as? [AnyHashable: Any] {
                                
                                if let uid = valueToAdd["userUID"] as? String, let myReported = self.rootController?.selfData["reportedUsers"] as? [String : Bool] {
                                    
                                    if myReported[uid] == nil {
                                        
                                        scopeData.append(valueToAdd)
                                        
                                    }
                                    
                                } else {
                                    
                                    scopeData.append(valueToAdd)
 
                                }
                            }
                        }
                        
                        scopeData.sort(by: { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
                            
                            if a["timeStamp"] as? TimeInterval > b["timeStamp"] as? TimeInterval {
                                
                                return true
                                
                            } else {
                                
                                return false
                                
                            }
                        })
                        
                        var messages = [[AnyHashable: Any]]()
                        
                        for post in scopeData {
                            
                            if let message = post["messages"] as? [AnyHashable: Any] {
                                
                                messages.append(message)
                                
                            } else {
                                
                                messages.append([AnyHashable: Any]())
                                
                            }
                        }
                        
                        var firstMessages = [[AnyHashable: Any]]()
                        var secondMessages = [[AnyHashable: Any]]()
                        var thirdMessages = [[AnyHashable: Any]]()
                        
                        for message in messages {
                            
                            var messageArray = [[AnyHashable: Any]]()
                            
                            for singleMessage in message {
                                
                                if let messageToAdd = singleMessage.1 as? [AnyHashable: Any] {
                                    
                                    messageArray.append(messageToAdd)
                                    
                                }
                            }
                            
                            messageArray.sort(by: { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
                                
                                if a["timeStamp"] as? TimeInterval > b["timeStamp"] as? TimeInterval {
                                    
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
                                        
                                        firstMessages.append([AnyHashable: Any]())
                                        
                                    }
                                    
                                } else {
                                    
                                    firstMessages.append([AnyHashable: Any]())
                                    secondMessages.append([AnyHashable: Any]())
                                    
                                }
                                
                            } else {
                                
                                firstMessages.append([AnyHashable: Any]())
                                secondMessages.append([AnyHashable: Any]())
                                thirdMessages.append([AnyHashable: Any]())
                                
                            }
                        }
                        
                        self.globFirstMessages = firstMessages
                        self.globSecondMessages = secondMessages
                        self.globThirdMessages = thirdMessages
                        
                        self.newPosts = scopeData
                        
                        self.rootController?.clearVibesPlayers()
                        
                        if self.globCollectionView.contentOffset == CGPoint.zero {
                            
                            self.globCollectionView.reloadData()
                            self.globCollectionView.setContentOffset(CGPoint.zero, animated: true)
                            
                        }
                    }
                }
            })
        }
    }
    
    
    func observePosts(){
        
        self.refresher.endRefreshing()
        
        let scopeCity = observingCity
        
        self.rootController?.bottomNavController?.torontoOutlet.text = scopeCity
        
        self.newPosts.removeAll()
        self.addedPosts.removeAll()
        //self.videoPlayers.removeAll()
        
        if scopeCity != "" {
            
            self.rootController?.bottomNavController?.torontoOutlet.text = scopeCity
            
            let ref = FIRDatabase.database().reference().child("posts").child(scopeCity)
            
            ref.queryLimited(toLast: 100).observe(.value, with: { (snapshot) in
                
                if !snapshot.exists() {
                    
                    self.noPostsOutlet.alpha = 1
                    
                } else {
                    
                    self.noPostsOutlet.alpha = 0
                    
                    var scopeData = [[AnyHashable: Any]]()
                    
                    if let value = snapshot.value as? [AnyHashable: Any] {
                        
                        if self.observingCity != scopeCity {
                            
                            ref.removeAllObservers()
                            
                        } else {
                            
                            for (_, snapValue) in value {
                                
                                if let valueToAdd = snapValue as? [AnyHashable: Any] {
                                    
                                    if let uid = valueToAdd["userUID"] as? String, let myReported = self.rootController?.selfData["reportedUsers"] as? [String : Bool] {
                                        
                                        if myReported[uid] == nil {
                                            
                                            scopeData.append(valueToAdd)
                                            
                                        }
                                        
                                    } else {
                                        
                                        scopeData.append(valueToAdd)
                                        
                                    }
                                }
                                
                            }
                            
                            scopeData.sort(by: { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
                                
                                if a["timeStamp"] as? TimeInterval > b["timeStamp"] as? TimeInterval {
                                    
                                    return true
                                    
                                } else {
                                    
                                    return false
                                    
                                }
                            })
                            
                            var messages = [[AnyHashable: Any]]()
                            
                            for post in scopeData {
                                
                                if let message = post["messages"] as? [AnyHashable: Any] {
                                    
                                    messages.append(message)
                                    
                                } else {
                                    
                                    messages.append([AnyHashable: Any]())
                                    
                                }
                            }
                            
                            var firstMessages = [[AnyHashable: Any]]()
                            var secondMessages = [[AnyHashable: Any]]()
                            var thirdMessages = [[AnyHashable: Any]]()
                            
                            for message in messages {
                                
                                var messageArray = [[AnyHashable: Any]]()
                                
                                for singleMessage in message {
                                    
                                    if let messageToAdd = singleMessage.1 as? [AnyHashable: Any] {
                                        
                                        messageArray.append(messageToAdd)
                                        
                                    }
                                }
                                
                                messageArray.sort(by: { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
                                    
                                    if a["timeStamp"] as? TimeInterval > b["timeStamp"] as? TimeInterval {
                                        
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
                                            
                                            firstMessages.append([AnyHashable : Any]())
                                            
                                        }
                                        
                                    } else {
                                        
                                        firstMessages.append([AnyHashable : Any]())
                                        secondMessages.append([AnyHashable : Any]())
                                        
                                    }
                                    
                                } else {
                                    
                                    firstMessages.append([AnyHashable : Any]())
                                    secondMessages.append([AnyHashable : Any]())
                                    thirdMessages.append([AnyHashable : Any]())
                                    
                                }
                            }
                            
                            
                            self.globFirstMessages = firstMessages
                            self.globSecondMessages = secondMessages
                            self.globThirdMessages = thirdMessages
                            
                            self.newPosts = scopeData
                            
                            self.rootController?.clearVibesPlayers()
                            
                            if self.globCollectionView.contentOffset == CGPoint.zero {
                                
                                self.globCollectionView.reloadData()
                                self.globCollectionView.setContentOffset(CGPoint.zero, animated: true)
                                
                            }
                        }
                    }
                }
            })
        }
    }
    
    func addGestureRecognizers(){
        
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showNav))
        downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.down
        downSwipeGestureRecognizer.delegate = self
        
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showMessages))
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        leftSwipeGestureRecognizer.delegate = self
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showNearby))
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
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
        
        self.globCollectionView.isScrollEnabled = false
        
        rootController?.toggleNearby({ (bool) in
            
            self.globCollectionView.isScrollEnabled = true
            
            self.navHidden = false
            self.transitioning = false
            print("nearby toggled")
            
        })
    }
    
    func showMessages(){
        
        transitioning  = true
        
        self.globCollectionView.isScrollEnabled = false
        
        rootController?.toggleMessages({ (bool) in
            
            self.globCollectionView.isScrollEnabled = true
            
            self.navHidden = false
            self.transitioning = false
            print("messages toggled")
            
        })
    }
    
    func printSomething(){
        
        print("something printed!")
        
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "rate" {
            
            if let player = object as? AVPlayer, let item = player.currentItem {
                
                if CMTimeGetSeconds(player.currentTime()) == CMTimeGetSeconds(item.duration) {
                    
                    player.seek(to: kCMTimeZero)
                    player.play()
                    
                } else if player.rate == 0 {
                    
                    player.play()
                    
                }
            }
        }
    }
    
    func loadData(){
        
        self.refresher.endRefreshing()
        self.globCollectionView.reloadData()
        self.globCollectionView.setContentOffset(CGPoint.zero, animated: true)
        

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        
        
        
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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.vibeController = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(observeCurrentCityPosts), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        
        addGestureRecognizers()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull for more posts")
        refresher.tintColor = UIColor.red
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        globCollectionView.addSubview(refresher)
        globCollectionView.alwaysBounceVertical = true
        
        // Do any additional setup after loading the view.
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
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
