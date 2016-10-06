//
//  SquadCountController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-21.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SquadCountController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    weak var rootController: MainRootController?
    
    var searchBarActive:Bool = false
    
    
    var uid = ""
    var selfSquad = false
    
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var globTableViewOutlet: UITableView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var dismissKeyboardView: UIView!
    
    
    @IBAction func back(sender: AnyObject) {
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            var selfProfile = false
            
            if selfUID == uid {
                
                selfProfile = true
                
            }
            
            rootController?.toggleProfile(uid, selfProfile: selfProfile, completion: { (bool) in
                
                print("profile toggled")
                
            })
        } 
    }
    
    
    
    var squad = [[NSObject : AnyObject]]()
    var dataSourceForSearchResult = [[NSObject : AnyObject]]()
    
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
    
 
    //TableView Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBarActive {
            
            return dataSourceForSearchResult.count
            
        } else {
            
            return squad.count
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("squadTableViewCell", forIndexPath: indexPath) as! SquadTableViewCell
        
        cell.squadCountController = self
        cell.selfSquad = selfSquad
        
        if self.searchBarActive {
            
            cell.loadCell(dataSourceForSearchResult[indexPath.row])
            
        } else {
            
            cell.loadCell(squad[indexPath.row])
            
        }

        return cell
    }
    
    func keyboardDidShow(){
        
        print("keyboard shown")
        dismissKeyboardView.alpha = 1
        
    }
    
    
    func keyboardDidHide(){
        
        print("keyboard hid")
        dismissKeyboardView.alpha = 0
        
    }
    
    func tapHandler(){
        
        view.endEditing(true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidHide), name: UIKeyboardWillHideNotification, object: nil)
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        self.view.addGestureRecognizer(tapGesture)
        
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
