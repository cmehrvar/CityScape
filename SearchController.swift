//
//  SearchController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-12.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class SearchController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    weak var rootController: MainRootController?
    
    weak var cityController: CityController?
    weak var userController: UserController?

    var searchIsCity = false
    
    var firstLoad = false
    var searchBarActive:Bool = false

    @IBOutlet weak var dismissViewOutlet: UIView!
    
    @IBOutlet weak var searchBarOutlet: UISearchBar!

    @IBOutlet weak var cityViewOutlet: NavButtonView!
    @IBOutlet weak var cityButtonOutlet: UIButton!
    
    
    @IBOutlet weak var userViewOutlet: NavButtonView!
    @IBOutlet weak var userButtonOutlet: UIButton!
    
    
    @IBOutlet weak var centerConstOutlet: NSLayoutConstraint!
    
    
    //Actions
    @IBAction func cityAction(sender: AnyObject) {
        
        toggleColour(1)
        
    }
    
    
    @IBAction func userAction(sender: AnyObject) {
        
        toggleColour(2)
        
    }
    

    //Functions
    func toggleColour(button: Int) {
        
        rootController?.showNav(0.3, completion: { (bool) in
            
            print("nav shown")
            
        })
        
        
        if button == 1 {
            
            searchBarOutlet.placeholder = "Search for cities worldwide"
            
            cityViewOutlet.backgroundColor = UIColor.whiteColor()
            cityButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), forState: .Normal)
            
            userViewOutlet.backgroundColor = UIColor.clearColor()
            userButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            UIView.animateWithDuration(0.45, animations: {
                
                self.centerConstOutlet.constant = 0
                self.view.layoutIfNeeded()

                }, completion: { (bool) in
                    
                    self.searchIsCity = true
                    
                    
            })

        } else if button == 2 {
            
            searchBarOutlet.placeholder = "Search for users worldwide"
            
            userViewOutlet.backgroundColor = UIColor.whiteColor()
            userButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), forState: .Normal)

            cityViewOutlet.backgroundColor = UIColor.clearColor()
            cityButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            UIView.animateWithDuration(0.45, animations: {
                
                self.centerConstOutlet.constant = -self.view.bounds.width
                self.view.layoutIfNeeded()

                }, completion: { (bool) in
                    
                    self.searchIsCity = false
     
            })
        }
    }
    
    
    func filterContentForSearchText(searchText: String){
        
        if searchIsCity {
            
            if let globCities = cityController?.globCities {
                
                cityController?.dataSourceForSearchResult = globCities.filter({ (city: [NSObject : AnyObject]) -> Bool in
                    
                    if let key = city["city"] as? String {
                        
                        return key.containsString(searchText)
                        
                    } else {
                        
                        return false
                    }
                })
 
            }
            
        } else {
            
            if let globUsers = userController?.globUsers {
                
                userController?.dataSourceForSearchResult = globUsers.filter({ (user: [NSObject : AnyObject]) -> Bool in
                    
                    if let firstName = user["firstName"] as? String, lastName =  user["lastName"] as? String {
                        
                        let name = firstName + " " + lastName
                        return name.containsString(searchText)
                        
                    } else {
                        
                        return false
                    }
                })
            }
        }
    }
    
    
    //Search Bar Delegates
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0 {
            
            self.searchBarActive = true
            
            self.filterContentForSearchText(searchText)
            
            cityController?.globCollectionView.reloadData()
            userController?.globCollectionView.reloadData()
            
        } else {
            
            self.searchBarActive = false
            
            cityController?.globCollectionView.reloadData()
            userController?.globCollectionView.reloadData()
            
        }
        
        print("search bar active: \(searchBarActive)")
        
    }
    
    
    
    //CollectionView Delegates
        
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
    }
    
    func tapHandler(){
        
        self.view.endEditing(true)
        
    }
    
    func keyboardDidShow(){
        
        self.dismissViewOutlet.alpha = 1
 
        
    }
    
    
    func keyboardHid(){
        
        self.dismissViewOutlet.alpha = 0

        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHid), name: UIKeyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.delegate = self
        self.dismissViewOutlet.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  
        if segue.identifier == "citySegue" {
            
            let city = segue.destinationViewController as? CityController
            cityController = city
            cityController?.searchController = self

        } else if segue.identifier == "userSegue" {
            
            let user = segue.destinationViewController as? UserController
            userController = user
            userController?.searchController = self
            
        }
        
        
        
        
        
        
        
        
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
    
    
}
