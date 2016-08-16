//
//  TopChatController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-05.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit


class TopChatController: UIViewController {
    
    weak var rootController: ChatRootController?
    weak var mainRootController: MainRootController?
    
    var globPostUIDs = [String]()
    var postData = [[NSObject:AnyObject]?]()
    var hasLiked = [Bool?]()
    var tableViewOffset = CGPoint()
    var postIndex = 0

    @IBAction func back(sender: AnyObject) {
        
        var postUID = ""
        
        
        if let actualUID = rootController?.chatController?.postUID {
            postUID = actualUID
        }
        
        let loadedMessageData = rootController?.chatController?.messageData
        
        let post = postData
        let id = globPostUIDs
        let liked = hasLiked
        let scopePostIndex = postIndex
        
        let offset = tableViewOffset
        
        let vc = mainRootController
        
        self.dismissViewControllerAnimated(true) {
            
            /*
            vc?.vibesFeedController?.loadedMessageData[postUID] = loadedMessageData
            
            if let actualData = loadedMessageData {
                
                let count = actualData.count
                
                if count - 1 >= 0 {
                    
                    vc?.vibesFeedController?.thirdMessageData[scopePostIndex]["name"] = actualData[count - 1]["senderDisplayName"] as? String
                    vc?.vibesFeedController?.thirdMessageData[scopePostIndex]["text"] = actualData[count - 1]["text"] as? String
                    vc?.vibesFeedController?.thirdMessageData[scopePostIndex]["profilePic"] = actualData[count - 1]["profilePicture"] as? String
                    vc?.vibesFeedController?.thirdMessageData[scopePostIndex]["isMedia"] = actualData[count - 1]["isMedia"] as? Bool
                    vc?.vibesFeedController?.thirdMessageData[scopePostIndex]["isImage"] = actualData[count - 1]["isImage"] as? Bool
                    vc?.vibesFeedController?.thirdMessageData[scopePostIndex]["senderId"] = actualData[count - 1]["senderId"] as? String
                    
                    if let offlineImage = actualData[count - 1]["offlineImage"] as? UIImage {
                        vc?.vibesFeedController?.thirdMessageData[scopePostIndex]["offlineImage"] = offlineImage
                    }
                }
                
                if count - 2 >= 0 {
                    
                    vc?.vibesFeedController?.secondMessageData[scopePostIndex]["name"] = actualData[count - 2]["senderDisplayName"] as? String
                    vc?.vibesFeedController?.secondMessageData[scopePostIndex]["text"] = actualData[count - 2]["text"] as? String
                    vc?.vibesFeedController?.secondMessageData[scopePostIndex]["profilePic"] = actualData[count - 2]["profilePicture"] as? String
                    vc?.vibesFeedController?.secondMessageData[scopePostIndex]["isMedia"] = actualData[count - 2]["isMedia"] as? Bool
                    vc?.vibesFeedController?.secondMessageData[scopePostIndex]["isImage"] = actualData[count - 2]["isImage"] as? Bool
                    vc?.vibesFeedController?.secondMessageData[scopePostIndex]["senderId"] = actualData[count - 2]["senderId"] as? String
                    
                    if let offlineImage = actualData[count - 2]["offlineImage"] as? UIImage {
                        vc?.vibesFeedController?.secondMessageData[scopePostIndex]["offlineImage"] = offlineImage
                    }
                    
                }
                
                if count - 3 >= 0 {
                    
                    vc?.vibesFeedController?.firstMessageData[scopePostIndex]["name"] = actualData[count - 3]["senderDisplayName"] as? String
                    vc?.vibesFeedController?.firstMessageData[scopePostIndex]["text"] = actualData[count - 3]["text"] as? String
                    vc?.vibesFeedController?.firstMessageData[scopePostIndex]["profilePic"] = actualData[count - 3]["profilePicture"] as? String
                    vc?.vibesFeedController?.firstMessageData[scopePostIndex]["isMedia"] = actualData[count - 3]["isMedia"] as? Bool
                    vc?.vibesFeedController?.firstMessageData[scopePostIndex]["isImage"] = actualData[count - 3]["isImage"] as? Bool
                    vc?.vibesFeedController?.firstMessageData[scopePostIndex]["senderId"] = actualData[count - 3]["senderId"] as? String
                    
                    if let offlineImage = actualData[count - 3]["offlineImage"] as? UIImage {
                        vc?.vibesFeedController?.firstMessageData[scopePostIndex]["offlineImage"] = offlineImage
                    }
                }
            }

            vc?.vibesFeedController?.observeData(id, postData: post, hasLiked: liked)
            vc?.vibesFeedController?.tableView.contentOffset = offset
            vc?.vibesFeedController?.tableView.reloadData()
             */

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
