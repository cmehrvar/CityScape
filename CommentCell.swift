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
    weak var rootController: MainRootController?
    weak var chatRootController: ChatRootController?
    var globPostUIDs = [String]()
    var globPostData = [[NSObject : AnyObject]?]()
    var postUID: String!
    var messageData: [NSObject : AnyObject]?
    
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
    @IBOutlet weak var profile4Outlet: UIImageView!
    @IBOutlet weak var name4Outlet: UILabel!
    @IBOutlet weak var comment4Outlet: UILabel!
    @IBOutlet weak var profile5Outlet: UIImageView!
    @IBOutlet weak var name5Outlet: UILabel!
    @IBOutlet weak var comment5Outlet: UILabel!
    
    
    @IBAction func viewCommentsAction(sender: AnyObject) {

        let mainRootController = rootController

        let ref = FIRDatabase.database().reference()
        let id = self.globPostUIDs
        let post = self.globPostData
        guard let selfUID = FIRAuth.auth()?.currentUser?.uid else {return}
        
        let refToPass = "posts/\(self.postUID)"

        let contentOffset = self.rootController?.homeController?.tableView.contentOffset
       
        let vc = rootController?.storyboard?.instantiateViewControllerWithIdentifier("rootChatController") as! ChatRootController
            
            self.rootController?.presentViewController(vc, animated: true) {
                
                ref.child("users").child(selfUID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                    if let userData = snapshot.value as? [NSObject : AnyObject] {
                        
                        var name = ""
                        
                        if let firstName = userData["firstName"] as? String {
                            
                            name = firstName + " "
                            vc.chatController?.firstName = firstName
                            
                        }
                        
                        if let lastName = userData["lastName"] as? String {
                            
                            name += lastName
                            vc.chatController?.lastName = lastName
                            
                        }
                        
                        if let profile = userData["profilePicture"] as? String {
                            vc.chatController?.profileUrl = profile
                        }
                        
                        vc.chatController?.senderDisplayName = name
                        vc.chatController?.senderId = selfUID
                        vc.chatController?.passedRef = refToPass
                        vc.chatController?.observeMessages()
                        
                        vc.topChatController?.globPostUIDs = id
                        vc.topChatController?.postData = post
                        vc.topChatController?.mainRootController = mainRootController
                        
                        
                        if let offset = contentOffset {
                            vc.topChatController?.tableViewOffset = offset
                        }                    
                    }
                    
                })

            
        
        
                }
        
                print("view comments tapped")
        
    }
    
            
            
            
            
            func loadData(){
                
                print(messageData)
                var messageArray = [[String : AnyObject]]()
                
                if let data = messageData {
                    
                    let sortedData = data.sort({ (a: (NSObject, AnyObject), b: (NSObject, AnyObject)) -> Bool in
                        
                        if a.1["timeStamp"] as? NSTimeInterval > b.1["timeStamp"] as? NSTimeInterval {
                            return true
                        } else {
                            return false
                        }
                        
                    })
                    
                    
                    for message in sortedData {
                        
                        
                        
                        if let text = message.1["text"] as? String, profile = message.1["profilePicture"] as? String, name = message.1["firstName"] as? String {
                            messageArray.append(["text" : text, "profile" : profile, "firstName" : name + ":"])
                            
                            
                        }
                        
                    }
                    
                    print("message count")
                    print(sortedData.count)
                    
                    if messageArray.count == 0 {
                        
                        joinConvoOutlet.text = "Start a conversation!"
                        
                        comment1Outlet.text = ""
                        comment2Outlet.text = ""
                        comment3Outlet.text = ""
                        comment4Outlet.text = ""
                        comment5Outlet.text = ""
                        
                        firstName1Outlet.text = ""
                        name2Outlet.text = ""
                        name3Outlet.text = ""
                        name4Outlet.text = ""
                        name5Outlet.text = ""
                        
                        profile1Outlet.image = nil
                        profile2Outlet.image = nil
                        profile3Outlet.image = nil
                        profile4Outlet.image = nil
                        profile5Outlet.image = nil
                        
                    } else if messageArray.count == 1 {
                        
                        joinConvoOutlet.text = "Join the conversation!"
                        
                        firstName1Outlet.text = messageArray[0]["firstName"] as? String
                        name2Outlet.text = ""
                        name3Outlet.text = ""
                        name4Outlet.text = ""
                        name5Outlet.text = ""
                        
                        
                        comment1Outlet.text = messageArray[0]["text"] as? String
                        comment2Outlet.text = ""
                        comment3Outlet.text = ""
                        comment4Outlet.text = ""
                        comment5Outlet.text = ""
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            if let profileURLString = messageArray[0]["profile"] as? String {
                                
                                self.profile1Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                                
                            }
                        })
                        
                        self.profile2Outlet.image = nil
                        self.profile3Outlet.image = nil
                        self.profile4Outlet.image = nil
                        self.profile5Outlet.image = nil
                        
                        
                        
                    } else if messageArray.count == 2 {
                        
                        joinConvoOutlet.text = "Join the conversation!"
                        
                        comment1Outlet.text = messageArray[0]["text"] as? String
                        comment2Outlet.text = messageArray[1]["text"] as? String
                        comment3Outlet.text = ""
                        comment4Outlet.text = ""
                        comment5Outlet.text = ""
                        
                        firstName1Outlet.text = messageArray[0]["firstName"] as? String
                        name2Outlet.text = messageArray[1]["firstName"] as? String
                        name3Outlet.text = ""
                        name4Outlet.text = ""
                        name5Outlet.text = ""
                        
                        
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            if let profileURLString = messageArray[0]["profile"] as? String {
                                
                                self.profile1Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                                
                            }
                            
                            
                            if let profileURLString = messageArray[1]["profile"] as? String {
                                
                                self.profile2Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                                
                            }
                            
                            self.profile3Outlet.image = nil
                            self.profile4Outlet.image = nil
                            self.profile5Outlet.image = nil
                            
                            
                        })
                        
                    } else if messageArray.count == 3 {
                        
                        joinConvoOutlet.text = "Join the conversation!"
                        
                        comment1Outlet.text = messageArray[0]["text"] as? String
                        comment2Outlet.text = messageArray[1]["text"] as? String
                        comment3Outlet.text = messageArray[2]["text"] as? String
                        comment4Outlet.text = ""
                        comment5Outlet.text = ""
                        
                        
                        
                        firstName1Outlet.text = messageArray[0]["firstName"] as? String
                        name2Outlet.text = messageArray[1]["firstName"] as? String
                        name3Outlet.text = messageArray[2]["firstName"] as? String
                        name4Outlet.text = ""
                        name5Outlet.text = ""
                        
                        if let profileURLString = messageArray[0]["profile"] as? String {
                            
                            self.profile1Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                            
                        }
                        
                        
                        if let profileURLString = messageArray[1]["profile"] as? String {
                            
                            self.profile2Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                            
                        }
                        
                        if let profileURLString = messageArray[2]["profile"] as? String {
                            
                            self.profile3Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                            
                        }
                        
                        self.profile4Outlet.image = nil
                        self.profile5Outlet.image = nil
                        
                        
                        
                    } else if messageArray.count == 4 {
                        
                        joinConvoOutlet.text = "Join the conversation!"
                        
                        comment1Outlet.text = messageArray[0]["text"] as? String
                        comment2Outlet.text = messageArray[1]["text"] as? String
                        comment3Outlet.text = messageArray[2]["text"] as? String
                        comment4Outlet.text = messageArray[3]["text"] as? String
                        comment5Outlet.text = ""
                        
                        firstName1Outlet.text = messageArray[0]["firstName"] as? String
                        name2Outlet.text = messageArray[1]["firstName"] as? String
                        name3Outlet.text = messageArray[2]["firstName"] as? String
                        name4Outlet.text = messageArray[3]["firstName"] as? String
                        name5Outlet.text = ""
                        
                        if let profileURLString = messageArray[0]["profile"] as? String {
                            
                            self.profile1Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                            
                        }
                        
                        
                        if let profileURLString = messageArray[1]["profile"] as? String {
                            
                            self.profile2Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                            
                        }
                        
                        if let profileURLString = messageArray[2]["profile"] as? String {
                            
                            self.profile3Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                            
                        }
                        
                        if let profileURLString = messageArray[3]["profile"] as? String {
                            
                            self.profile4Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                            
                        }
                        
                        self.profile5Outlet.image = nil
                        
                        
                        
                        
                        
                    } else if messageArray.count == 5 {
                        
                        joinConvoOutlet.text = "Join the conversation!"
                        
                        comment1Outlet.text = messageArray[0]["text"] as? String
                        comment2Outlet.text = messageArray[1]["text"] as? String
                        comment3Outlet.text = messageArray[2]["text"] as? String
                        comment4Outlet.text = messageArray[3]["text"] as? String
                        comment5Outlet.text = messageArray[4]["text"] as? String
                        
                        firstName1Outlet.text = messageArray[0]["firstName"] as? String
                        name2Outlet.text = messageArray[1]["firstName"] as? String
                        name3Outlet.text = messageArray[2]["firstName"] as? String
                        name4Outlet.text = messageArray[3]["firstName"] as? String
                        name5Outlet.text = messageArray[4]["firstName"] as? String
                        
                        if let profileURLString = messageArray[0]["profile"] as? String {
                            
                            self.profile1Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                            
                        }
                        
                        
                        if let profileURLString = messageArray[1]["profile"] as? String {
                            
                            self.profile2Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                            
                        }
                        
                        if let profileURLString = messageArray[2]["profile"] as? String {
                            
                            self.profile3Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                            
                        }
                        
                        if let profileURLString = messageArray[3]["profile"] as? String {
                            
                            self.profile4Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                            
                        }
                        
                        if let profileURLString = messageArray[4]["profile"] as? String {
                            
                            self.profile5Outlet.sd_setImageWithURL(NSURL(string: profileURLString), placeholderImage: nil)
                            
                        }
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
