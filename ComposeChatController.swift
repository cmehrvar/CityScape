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

class ComposeChatController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var rootController: MainRootController?

    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var getTalkinOutlet: UIButton!
    @IBOutlet weak var globTableViewOutlet: UITableView!
    @IBOutlet weak var globCollectionViewOutlet: UICollectionView!
    @IBOutlet weak var dismissKeyboardView: UIView!

    var userSelected = [String : Int]()

    var squad = [[NSObject : AnyObject]]()
    var selectedSquad = [[NSObject : AnyObject]]()
    var dataSourceForSearchResult = [[NSObject : AnyObject]]()
    
    var searchBarActive = false

    //Actions
    @IBAction func getTalkin(sender: AnyObject) {
        
        if selectedSquad.count == 1 {

            if let first = selectedSquad.first, uid = first["uid"] as? String, firstName = first["firstName"] as? String, lastName = first["lastName"] as? String {
                
                let ref = FIRDatabase.database().reference().child("users").child(uid)
                
                ref.child("profilePicture").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                    if let profileString = snapshot.value as? String {
                        
                        self.rootController?.composeChat(false, completion: { (bool) in
                            
                            self.rootController?.toggleChat("squad", userUID: uid, postUID: nil, city: nil, firstName: firstName, lastName: lastName, profile: profileString, completion: { (bool) in
                                
                                print("chat toggled")
                                
                            })
                        })
                    }
                })
            }
            
        } else {

            //CREATE GROUPCHAT
            let alertController = UIAlertController(title: nil, message: "Enter a title for your chat!", preferredStyle: .Alert)
            
            var scopeField = UITextField()
            
            
            alertController.addTextFieldWithConfigurationHandler({ (textField) in
                
                scopeField = textField

            })
            
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) in
                
                print("cancel")
                self.view.endEditing(true)
                
                
            }))
            
            
            alertController.addAction(UIAlertAction(title: "Create Chat", style: .Cancel, handler: { (action) in
                
                print("create chat")
                

            }))

            
            self.presentViewController(alertController, animated: true, completion: {
                
                print("controller presented")
                
            })
            
        }
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        
        rootController?.composeChat(false, completion: { (bool) in
            
            print("compose closed")
            
        })
    }

    
    //Functions
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
        
        dataSourceForSearchResult = squad.filter({ (user: [NSObject : AnyObject]) -> Bool in
            
            if let firstName = user["firstName"] as? String, lastName = user["lastName"] as? String {
                
                let name = firstName + " " + lastName
                
                return name.containsString(searchText)
                
            } else {
                
                return false
            }
        })
    }

    func loadTableView(data: [NSObject : AnyObject]){
        
        var scopeSquad = [[NSObject : AnyObject]]()

        for (_, value) in data {
            
            if let valueToAdd = value as? [NSObject : AnyObject] {
                
                scopeSquad.append(valueToAdd)
                
            }
        }
        
        scopeSquad.sortInPlace { (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
            
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
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return selectedSquad.count
        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("squadChatCell", forIndexPath: indexPath) as! ComposeChatCollectionCell
        
        
        cell.composeController = self
        cell.loadData(selectedSquad[indexPath.row])
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return CGSize(width: 96, height: 103)
    }
    
    
    
    //TableView Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBarActive {
            
            return dataSourceForSearchResult.count
            
        } else {
            
            return squad.count
            
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("squadSelectCell", forIndexPath: indexPath) as! ComposeTableViewCell

        cell.composeController = self
        
        if searchBarActive {
            
            cell.loadData(dataSourceForSearchResult[indexPath.row])
            
        } else {
            
            cell.loadData(squad[indexPath.row])
            
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showKeyboard), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(hideKeyboard), name: UIKeyboardWillHideNotification, object: nil)
        
        getTalkinOutlet.enabled = false
        getTalkinOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        getTalkinOutlet.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        
        
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
