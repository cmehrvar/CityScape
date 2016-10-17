//
//  ComposeChatController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-26.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import NYAlertViewController
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


class ComposeChatController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var rootController: MainRootController?
    
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var getTalkinOutlet: UIButton!
    @IBOutlet weak var globTableViewOutlet: UITableView!
    @IBOutlet weak var globCollectionViewOutlet: UICollectionView!
    @IBOutlet weak var dismissKeyboardView: UIView!
    
    var userSelected = [String : Int]()
    
    var squad = [[AnyHashable: Any]]()
    var selectedSquad = [[AnyHashable: Any]]()
    var dataSourceForSearchResult = [[AnyHashable: Any]]()
    
    var searchBarActive = false
    
    //Actions
    @IBAction func getTalkin(_ sender: AnyObject) {
        
        if selectedSquad.count == 1 {
            
            if let first = selectedSquad.first, let uid = first["uid"] as? String, let firstName = first["firstName"] as? String, let lastName = first["lastName"] as? String {
                
                let ref = FIRDatabase.database().reference().child("users").child(uid)
                
                ref.child("profilePicture").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let profileString = snapshot.value as? String {
                        
                        self.rootController?.composeChat(false, completion: { (bool) in
                            
                            self.rootController?.toggleChat("squad", key: uid, city: nil, firstName: firstName, lastName: lastName, profile: profileString, completion: { (bool) in
                                
                                print("chat toggled")
                                
                            })
                        })
                    }
                })
            }
            
        } else {
            
            //CREATE GROUPCHAT
            let scopeSelectedSquad = selectedSquad
            let alertConroller = NYAlertViewController()
            var scopeTextField = UITextField()
            
            alertConroller.title = "Squad Chat"
            alertConroller.message = "Give a name to your squad!"
            
            alertConroller.backgroundTapDismissalGestureEnabled = true
            
            alertConroller.titleColor = UIColor.red
            alertConroller.buttonColor = UIColor.red
            alertConroller.buttonTitleColor = UIColor.white
            
            alertConroller.addTextField(configurationHandler: { (textField) in
                
                textField?.textAlignment = .center
                textField?.autocorrectionType = .no
                scopeTextField = textField!
                
            })
            
            let cancelAction = NYAlertAction(title: "Create Chat", style: .default, handler: { (action) in
                
                if let chatTitle = scopeTextField.text {
                    
                    if chatTitle != "" {
                        
                        //Create chat
                        print("create chat with title: \(chatTitle)")
                        
                        var memberUIDs = [String : Bool]()
                        
                        for member in scopeSelectedSquad {
                            
                            if let uid = member["uid"] as? String {
                                
                                memberUIDs[uid] = true
                                
                            }
                        }
                        
                        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                            
                            memberUIDs[selfUID] = true
                            
                        }
                        
                        let ref = FIRDatabase.database().reference().child("groupChats")
                        let chatKey = ref.childByAutoId().key
                        let timeStamp = Date().timeIntervalSince1970
                        
                        let chatItem = [
                            
                            "title" : chatTitle,
                            "members" : memberUIDs,
                            "key" : chatKey,
                            "timeStamp" : timeStamp
                            
                        ] as [String : Any]
                        
                        ref.child(chatKey).setValue(chatItem)
                        
                        let userChatItem = [
                            
                            "title" : chatTitle,
                            "key" : chatKey,
                            "timeStamp" : timeStamp,
                            "members" : memberUIDs,
                            "read" : false
                            
                            
                        ] as [String : Any]
                        
                        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                            FIRDatabase.database().reference().child("users").child(selfUID).child("groupChats").child(chatKey).setValue(userChatItem)
                            
                        }
                        
                        for (key, _) in memberUIDs {
                            
                            FIRDatabase.database().reference().child("users").child(key).child("groupChats").child(chatKey).setValue(userChatItem)
                            
                        }
                        
                        self.dismiss(animated: true, completion: {
                            
                            self.rootController?.composeChat(false, completion: { (bool) in
                                
                                self.rootController?.toggleChat("groupChats", key: chatKey, city: nil, firstName: nil, lastName: nil, profile: nil, completion: { (bool) in
                                    
                                    print("group chat toggled")
                                    
                                })
                            })
                        })
                    }
                }
            })

            alertConroller.addAction(cancelAction)
            
            // Present the alert view controller
            self.present(alertConroller, animated: true, completion: nil)
            
            
        }
    }
    
    
    @IBAction func cancel(_ sender: AnyObject) {
        
        rootController?.composeChat(false, completion: { (bool) in
            
            print("compose closed")
            
        })
    }
    
    
    //Functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0 {
            
            self.searchBarActive = true
            
            self.filterContentForSearchText(searchText)
            
            globTableViewOutlet.reloadData()
            
        } else {
            
            self.searchBarActive = false
            
            globTableViewOutlet.reloadData()
            
        }
    }
    
    func filterContentForSearchText(_ searchText: String){
        
        dataSourceForSearchResult = squad.filter({ (user: [AnyHashable: Any]) -> Bool in
            
            if let firstName = user["firstName"] as? String, let lastName = user["lastName"] as? String {
                
                let name = firstName + " " + lastName
                
                return name.contains(searchText)
                
            } else {
                
                return false
            }
        })
    }
    
    func loadTableView(_ data: [AnyHashable: Any]){
        
        var scopeSquad = [[AnyHashable: Any]]()
        
        for (_, value) in data {
            
            if let valueToAdd = value as? [AnyHashable: Any] {
                
                scopeSquad.append(valueToAdd)
                
            }
        }
        
        scopeSquad.sort { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
            
            if a["lastName"] as? String > b["lastName"] as? String {
                
                return false
                
            } else {
                
                return true
                
            }
        }
        
        self.squad = scopeSquad
        self.globTableViewOutlet.reloadData()
        
    }
    
    
    //CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return selectedSquad.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "squadChatCell", for: indexPath) as! ComposeChatCollectionCell

        cell.composeController = self
        
        if let userUid = selectedSquad[(indexPath as NSIndexPath).row]["uid"] as? String {
            
            cell.loadData(userUid)
            
        }

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 96, height: 103)
    }
    
    
    
    //TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBarActive {
            
            return dataSourceForSearchResult.count
            
        } else {
            
            return squad.count
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "squadSelectCell", for: indexPath) as! ComposeTableViewCell
        
        cell.composeController = self
        
        if searchBarActive {
            
            cell.loadData(dataSourceForSearchResult[(indexPath as NSIndexPath).row])
            
        } else {
            
            cell.loadData(squad[(indexPath as NSIndexPath).row])
            
        }
        
        return cell
    }
    
    
    
    func showKeyboard(){
        
        self.dismissKeyboardView.alpha = 1
        
    }
    
    
    func hideKeyboard(){
        
        self.dismissKeyboardView.alpha = 0
        
    }
    
    func dismissKeyboard(){
        
        self.view.endEditing(true)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        getTalkinOutlet.isEnabled = false
        getTalkinOutlet.setTitleColor(UIColor.white, for: UIControlState())
        getTalkinOutlet.setTitleColor(UIColor.lightGray, for: .disabled)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.dismissKeyboardView.addGestureRecognizer(tapGesture)
        
        
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
