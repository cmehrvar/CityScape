//
//  CommentCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-08.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SDWebImage

class CommentCell: UITableViewCell {
    
    
    //Properties
    var homeController: HomeController!
    var globPostUIDs = [String]()
    var globPostData = [[NSObject : AnyObject]?]()
    var postUID: String!
    var messageData: [NSObject : AnyObject]?
    
    @IBOutlet weak var Com1TO2Outlet: NSLayoutConstraint!
    @IBOutlet weak var Com2TO3Outlet: NSLayoutConstraint!
    @IBOutlet weak var Com3TOBottomOutlet: NSLayoutConstraint!
    @IBOutlet weak var Com1TOJoinConvoOutlet: NSLayoutConstraint!
    
    
    @IBOutlet weak var joinConvoOutlet: UILabel!
    
    @IBOutlet weak var profile1Outlet: UIImageView!
    @IBOutlet weak var firstName1Outlet: UILabel!
    @IBOutlet weak var comment1Outlet: UILabel!
    @IBOutlet weak var profile2Outlet: UIImageView!
    @IBOutlet weak var name2Outlet: UILabel!
    @IBOutlet weak var comment2Outlet: UILabel!
    @IBOutlet weak var profile3Outlet: UIImageView!
    @IBOutlet weak var name3Outlet: UILabel!
    @IBOutlet weak var comment3Outlet: UILabel!
    
    
    @IBAction func viewCommentsAction(sender: AnyObject) {
        
        let vc = homeController.storyboard?.instantiateViewControllerWithIdentifier("rootChatController") as! ChatRootController
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        homeController.view.window?.layer.addAnimation((transition), forKey: nil)
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference()
            
            ref.child("users").child(selfUID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let userData = snapshot.value as? [NSObject : AnyObject] {
                    
                    var name = ""
                    
                    if let firstName = userData["firstName"] as? String {
                        
                        name = firstName + " "
                        
                    }
                    
                    if let lastName = userData["lastName"] as? String {
                        
                        name += lastName
                        
                    }
                    
                    let id = self.globPostUIDs
                    let post = self.globPostData
                    
                    let refToPass = "posts/\(self.postUID)"
                    
                    let contentOffset = self.homeController.tableView.contentOffset
                    
                    
                    self.homeController.presentViewController(vc, animated: false) {
                        
                        vc.chatController?.senderDisplayName = name
                        vc.chatController?.senderId = selfUID
                        vc.chatController?.passedRef = refToPass
                        
                        vc.chatController?.addMessage()
                        
                        vc.topChatController?.globPostUIDs = id
                        vc.topChatController?.postData = post
                        vc.topChatController?.tableViewOffset = contentOffset
                        
                    }
                    
                }
            })
        }
        
        print("view comments tapped")
        
    }
    
    
    
    
    
    func loadData(){
        
        print(messageData)
        var messageArray = [[String : AnyObject]]()
        var i: Int = 0
        
        if let data = messageData {
            
            let sortedData = data.sort({ (a: (NSObject, AnyObject), b: (NSObject, AnyObject)) -> Bool in
                
                if a.1["timeStamp"] as? NSTimeInterval > b.1["timeStamp"] as? NSTimeInterval {
                    return true
                } else {
                    return false
                }
                
            })
            
            
            for message in sortedData {
                
                if i <= 2 {
                    
                    if let text = message.1["text"] as? String, profile = message.1["profilePicture"] as? String {
                        messageArray.append(["text" : text, "profile" : profile])
                        i += 1
                        
                    }
                }
            }
            
            if messageArray.count == 0 {

                joinConvoOutlet.text = "Start a conversation!"
                
                comment1Outlet.text = ""
                comment2Outlet.text = ""
                comment3Outlet.text = ""
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.Com1TO2Outlet.constant = 0
                    self.Com2TO3Outlet.constant = 0
                    self.Com3TOBottomOutlet.constant = 0

                })

            } else if messageArray.count == 1 {
                
                joinConvoOutlet.text = "Join the conversation!"
                
                comment1Outlet.text = messageArray[0]["text"] as? String
                comment2Outlet.text = ""
                comment3Outlet.text = ""

                dispatch_async(dispatch_get_main_queue(), {
                    
                    if let profileURLString = messageArray[0]["profile"] as? String {

                        self.profile1Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                        
                        self.Com2TO3Outlet.constant = 0
                        self.Com3TOBottomOutlet.constant = 0

                        
                    }
                })

            } else if messageArray.count == 2 {
                
                joinConvoOutlet.text = "Join the conversation!"
                
                comment1Outlet.text = messageArray[0]["text"] as? String
                comment2Outlet.text = messageArray[1]["text"] as? String
                comment3Outlet.text = ""
                
                dispatch_async(dispatch_get_main_queue(), {

                    self.Com3TOBottomOutlet.constant = 0

                })

            } else if messageArray.count == 3 {
                
                joinConvoOutlet.text = "Join the conversation!"
                
                comment1Outlet.text = messageArray[0]["text"] as? String
                comment2Outlet.text = messageArray[1]["text"] as? String
                comment3Outlet.text = messageArray[2]["text"] as? String
                
            }
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
