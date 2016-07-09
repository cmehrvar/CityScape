//
//  CommentController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-04.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase
import FirebaseAuth

class CommentController: JSQMessagesViewController {

    weak var rootController: ChatRootController?
    
    
    //JSQData
    var passedRef = ""
    var messages = [JSQMessage]()
    var avatarDataSource = [JSQMessageAvatarImageDataSource]()
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    
    
    func beganTyping(){
        
        let ref = FIRDatabase.database().reference()
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            ref.child(passedRef).child("isTyping").child(selfUID).setValue(true)
            
        }
    }
    
    func endedTyping(){
        
        let ref = FIRDatabase.database().reference()
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            ref.child(passedRef).child("isTyping").child(selfUID).setValue(false)
            
        }
    }

    private func setUpBubbles() {
        
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())

    }
    
    
    override func textViewDidChange(textView: UITextView) {
        
        super.textViewDidChange(textView)
        
        if textView.text != "" {
            
            beganTyping()
            
        } else {
            
            endedTyping()
            
        }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
        
    }

    

    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return nil
    }
    
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            
            cell.textView.textColor = UIColor.whiteColor()
            
        } else {
            
            cell.textView.textColor = UIColor.blackColor()
            
        }
        
        return cell
 
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let ref = FIRDatabase.database().reference()
        let scopePassedRef = passedRef
        
        ref.child("users").child(senderId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let value = snapshot.value as? [NSObject:AnyObject] {
                
                let timeStamp = NSDate().timeIntervalSince1970
                
                if let profile = value["profilePicture"] as? String, first = value["firstName"] as? String, last = value["lastName"] as? String {
                    
                    let messageItem = [
                        "text" : text,
                        "senderId":senderId,
                        "profilePicture" : profile,
                        "timeStamp" : timeStamp,
                        "firstName" : first,
                        "lastName" : last
                        
                    ]
                    
                    ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                    ref.child("users").child(senderId).child("posts").child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                    
                }
            }
        })
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        endedTyping()
        
        finishSendingMessage()

    }
    
    func observeMessages() {
        
        let refString = "/" + passedRef
        
        let ref = FIRDatabase.database().reference().child(refString).child("messages")
        
        ref.observeEventType(.ChildAdded, withBlock:  { (snapshot) in
            
            if let actualValue = snapshot.value as? [NSObject : AnyObject] {
                
                if let id = actualValue["senderId"] as? String, text = actualValue["text"] as? String {
                    
                    self.addMessage(id, text: text)
                    self.finishReceivingMessage()
                    
                }
            }
        })
    }

    
    
    
    
    func addMessage(id: String, text: String) {
        
        let message = JSQMessage(senderId: id, displayName: senderDisplayName, text: text)
        messages.append(message)
        
        
    }
    
    func addMessage() {
        
        print(senderId)
        print(senderDisplayName)
        
        addMessage("some user", text: "Hey person!")
        addMessage(senderId, text: "Yo!")
        addMessage(senderId, text: "I like turtules!")
        
        print(passedRef)
        
        
        finishReceivingMessage()

        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        

    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpBubbles()
        
        
        //no avatars
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
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
