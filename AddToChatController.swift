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

class AddToChatController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    weak var rootController: MainRootController?
    
    var chatKey = ""
    var members = [String]()
    
    var squad = [[NSObject : AnyObject]]()
    var selectedSquad = [[NSObject : AnyObject]]()
    var userSelected = [String : Int]()
    var dataSoruceForSearchResult = [[NSObject : AnyObject]]()

    var searchBarActive = false
    
    @IBOutlet weak var globTableViewOutlet: UITableView!
    @IBOutlet weak var globCollectionViewOutlet: UICollectionView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var dismissKeyboardViewOutlet: UIView!
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    
    
    //Actions
    @IBAction func cancel(sender: AnyObject) {
        
        rootController?.toggleAddToChat(nil, chatKey: nil, completion: { (bool) in
            
            print("add to chat toggled")
            
        })
    }
    
    @IBAction func add(sender: AnyObject) {

        let timeStamp = NSDate().timeIntervalSince1970
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
        
        var groupChatItem: [NSObject : AnyObject] = [
            
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

        var scopeSquad = [[NSObject : AnyObject]]()
        
        if let selfData = rootController?.selfData {
            
            if let mySquad = selfData["squad"] as? [NSObject : AnyObject] {
                
                for (_, value) in mySquad {
                    
                    if let valueUID = value["uid"] as? String {
                        
                        if let currentGroupMembers = rootController?.topChatController?.members {
                            
                            var isMember = false
                            
                            for member in currentGroupMembers {
                                
                                if member == valueUID {
                                    
                                    isMember = true
                                    
                                }
                            }
                            
                            if !isMember {
                                
                                if let valueToAdd = value as? [NSObject : AnyObject] {
                                    
                                    scopeSquad.append(valueToAdd)
                                    
                                }
                            }
                        }
                    }
                }

                scopeSquad.sortInPlace({ (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
                    
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
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0 {
            
            self.searchBarActive = true
            
            self.filterContentForSearchText(searchText)
            
            globTableViewOutlet.reloadData()
            
        } else {
            
            self.searchBarActive = false
            
            globTableViewOutlet.reloadData()
            
        }
    }
    
    func filterContentForSearchText(searchText: String){
        
        dataSoruceForSearchResult = squad.filter({ (user: [NSObject : AnyObject]) -> Bool in
            
            if let firstName = user["firstName"] as? String, lastName = user["lastName"] as? String {
                
                let name = firstName + " " + lastName
                
                return name.containsString(searchText)
                
            } else {
                
                return false
            }
        })
    }

    
    
    
    //TableView Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBarActive {
            
            dataSoruceForSearchResult.count
            
        } else {
            
            return squad.count
            
        }
        
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("addToChatCell", forIndexPath: indexPath) as! AddToChatCell
        
        cell.addToChatController = self
        
        if searchBarActive {
            
            cell.loadCell(dataSoruceForSearchResult[indexPath.row])
            
        } else {
            
            cell.loadCell(squad[indexPath.row])
            
        }

        return cell

    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return selectedSquad.count
        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("addToChatCollectionCell", forIndexPath: indexPath) as! AddToChatCollectionCell
        
        
        cell.loadCell(selectedSquad[indexPath.row])
        
        return cell
 
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButtonOutlet.enabled = false
        addButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        addButtonOutlet.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)

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
