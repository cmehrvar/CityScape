//
//  AddToChatController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-28.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
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


class AddToChatController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    weak var rootController: MainRootController?
    
    var chatKey = ""
    var members = [String]()
    
    var squad = [[AnyHashable: Any]]()
    var selectedSquad = [[AnyHashable: Any]]()
    var userSelected = [String : Int]()
    var dataSoruceForSearchResult = [[AnyHashable: Any]]()

    var searchBarActive = false
    
    @IBOutlet weak var globTableViewOutlet: UITableView!
    @IBOutlet weak var globCollectionViewOutlet: UICollectionView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var dismissKeyboardViewOutlet: UIView!
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    
    
    //Actions
    @IBAction func cancel(_ sender: AnyObject) {
        
        rootController?.toggleAddToChat(nil, chatKey: nil, completion: { (bool) in
            
            print("add to chat toggled")
            
        })
    }
    
    @IBAction func add(_ sender: AnyObject) {

        let timeStamp = Date().timeIntervalSince1970
        let scopeKey = chatKey
        let scopeCurrentMembers = members

        var dictMembers = [String : Bool]()
        
        for member in scopeCurrentMembers {
            
            dictMembers[member] = true
            
        }
        
        for member in selectedSquad {
            
            if let uid = member["uid"] as? String {
                
                dictMembers[uid] = true
                
            }
        }

        var chatTitle = ""

        if let scopeTitle = rootController?.topChatController?.chatTitleOutlet.text {
            
            chatTitle = scopeTitle
            
        }
        
        var groupChatItem: [AnyHashable: Any] = [
            
            "key" : scopeKey,
            "read" : false,
            "members" : dictMembers,
            "timeStamp" : timeStamp,
            "title" : chatTitle

        ]

        if let picture = rootController?.topChatController?.groupPicture {
            
            groupChatItem["groupPhoto"] = picture
            
        }
        
        
        FIRDatabase.database().reference().child("groupChats").child(scopeKey).child("members").setValue(dictMembers)
        

        for selectedMember in selectedSquad {

            if let selectedUID = selectedMember["uid"] as? String {
                
                FIRDatabase.database().reference().child("users").child(selectedUID).child("groupChats").child(scopeKey).setValue(groupChatItem)
                
            }
        }
        
        
        for currentMember in scopeCurrentMembers {
            
            FIRDatabase.database().reference().child("users").child(currentMember).child("groupChats").child(scopeKey).child("members").setValue(dictMembers)
            
        }
        
        rootController?.toggleAddToChat(nil, chatKey: nil, completion: { (bool) in
            
            print("members added")
            
        }) 
    }
    
    
    //Functions
    func loadUsers(){

        var scopeSquad = [[AnyHashable: Any]]()
        
        if let selfData = rootController?.selfData {
            
            if let mySquad = selfData["squad"] as? [AnyHashable: Any] {
                
                for (_, value) in mySquad {
                    
                    if let squadMember = value as? [AnyHashable : Any] {
                        
                        if let valueUID = squadMember["uid"] as? String {
                            
                            if let currentGroupMembers = rootController?.topChatController?.members {
                                
                                var isMember = false
                                
                                for member in currentGroupMembers {
                                    
                                    if member == valueUID {
                                        
                                        isMember = true
                                        
                                    }
                                }
                                
                                if !isMember {
                                    
                                    if let valueToAdd = value as? [AnyHashable: Any] {
                                        
                                        scopeSquad.append(valueToAdd)
                                        
                                    }
                                }
                            }
                        }
                    }
                }

                scopeSquad.sort(by: { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
                    
                    if a["lastName"] as? String > b["lastName"] as? String {
                        
                        return true
                        
                    } else {
                        
                        return false
                        
                    }
                })

                self.squad = scopeSquad
                self.globTableViewOutlet.reloadData()
                
                
            }
        }
    }
    
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
        
        dataSoruceForSearchResult = squad.filter({ (user: [AnyHashable: Any]) -> Bool in
            
            if let firstName = user["firstName"] as? String, let lastName = user["lastName"] as? String {
                
                let name = firstName + " " + lastName
                
                return name.contains(searchText)
                
            } else {
                
                return false
            }
        })
    }

    
    
    
    //TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBarActive {
            
            dataSoruceForSearchResult.count
            
        } else {
            
            return squad.count
            
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addToChatCell", for: indexPath) as! AddToChatCell
        
        cell.addToChatController = self
        
        if searchBarActive {
            
            cell.loadCell(dataSoruceForSearchResult[(indexPath as NSIndexPath).row])
            
        } else {
            
            cell.loadCell(squad[(indexPath as NSIndexPath).row])
            
        }

        return cell

    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return selectedSquad.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addToChatCollectionCell", for: indexPath) as! AddToChatCollectionCell
        
        
        cell.loadCell(selectedSquad[(indexPath as NSIndexPath).row])
        
        return cell
 
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButtonOutlet.isEnabled = false
        addButtonOutlet.setTitleColor(UIColor.white, for: UIControlState())
        addButtonOutlet.setTitleColor(UIColor.lightGray, for: .disabled)

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
