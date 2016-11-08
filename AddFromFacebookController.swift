//
//  AddFromFacebookController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-10-20.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class AddFromFacebookController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    weak var mainRootController: MainRootController?
    
    @IBOutlet weak var globTableViewOutlet: UITableView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var dismissKeyboardView: UIView!
    
    var globUsers = [[AnyHashable : Any]]()
    var dataSourceForSearchResult = [[AnyHashable : Any]]()
    
    var searchBarActive = false
    
    @IBAction func back(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        
        mainRootController?.toggleAddFromFacebook(completion: { (bool) in
            
            print("add from facebook closed")
            
        })
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
        
        dataSourceForSearchResult = globUsers.filter({ (user: [AnyHashable: Any]) -> Bool in
            
            if let firstName = user["firstName"] as? String, let lastName = user["lastName"] as? String {
                
                let name = firstName + " " + lastName
                
                return name.contains(searchText)
                
            } else {
                
                return false
            }
        })
    }
    
    func loadFacebookFriends(){
        
        globUsers.removeAll()
        dataSourceForSearchResult.removeAll()
        
        let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        
        request?.start(completionHandler: { (connection, result, error) in
            
            if error == nil {
                
                if let dictResult = result as? [AnyHashable : Any], let data = dictResult["data"] as? [[String : Any]] {
                    
                    for value in data {
                        
                        if let name = value["name"] as? String, let id = value["id"] as? String {

                                let nameComponents = name.components(separatedBy: " ")
                                
                                FIRDatabase.database().reference().child("facebookUIDs").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
  
                                        if let uid = snapshot.value as? String {
                                            
                                            var userValue = [AnyHashable : Any]()
                                            userValue["firstName"] = nameComponents[0]
                                            userValue["lastName"] = nameComponents[1]
                                            userValue["uid"] = uid
                                            self.globUsers.append(userValue)
                                            self.globTableViewOutlet.reloadData()
                                            
                                    }
                                })
                            }
                        
                    }
                }
                
            } else {
                
                print(error)
                
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBarActive {
            
            return dataSourceForSearchResult.count
            
        } else {
            
            return globUsers.count
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.allowsSelection = false
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "facebookCell", for: indexPath) as! AddFromFacebookCell
        
        cell.addFromFaceookController = self
        
        if searchBarActive {
            
            cell.loadCell(dataSourceForSearchResult[indexPath.row])
            
        } else {
            
            cell.loadCell(globUsers[indexPath.row])
            
        }
        
        return cell
        
    }
    
    func keyboardShown(){
        
        self.dismissKeyboardView.alpha = 1
        
    }
    
    func keyboardHid(){
        
        self.dismissKeyboardView.alpha = 0
        
        
    }
    
    func dismissKeyboard(){
        
        view.endEditing(true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        dismissKeyboardView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHid), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
