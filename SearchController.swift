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
    @IBAction func cityAction(_ sender: AnyObject) {
        
        toggleColour(1)
        
    }
    
    
    @IBAction func userAction(_ sender: AnyObject) {
        
        toggleColour(2)
        
    }
    

    //Functions
    func toggleColour(_ button: Int) {
        
        cityController?.globCollectionView.isScrollEnabled = false
        userController?.globCollectionView.isScrollEnabled = false
        
        rootController?.showNav(0.3, completion: { (bool) in
            
            print("nav shown", terminator: "")
            
        })

        if button == 1 {
            
            searchBarOutlet.placeholder = "Search for cities worldwide"
            
            cityViewOutlet.backgroundColor = UIColor.white
            cityButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), for: UIControlState())
            
            userViewOutlet.backgroundColor = UIColor.clear
            userButtonOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
            UIView.animate(withDuration: 0.45, animations: {
                
                self.centerConstOutlet.constant = 0
                self.view.layoutIfNeeded()

                }, completion: { (bool) in
                    
                    self.searchIsCity = true
                    
                    self.cityController?.globCollectionView.isScrollEnabled = true
                    self.userController?.globCollectionView.isScrollEnabled = true
                    
                    
            })

        } else if button == 2 {
            
            searchBarOutlet.placeholder = "Search for users worldwide"
            
            userViewOutlet.backgroundColor = UIColor.white
            userButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), for: UIControlState())

            cityViewOutlet.backgroundColor = UIColor.clear
            cityButtonOutlet.setTitleColor(UIColor.white, for: UIControlState())
            
            UIView.animate(withDuration: 0.45, animations: {
                
                self.centerConstOutlet.constant = -self.view.bounds.width
                self.view.layoutIfNeeded()

                }, completion: { (bool) in
                    
                    self.searchIsCity = false
                    
                    self.cityController?.globCollectionView.isScrollEnabled = true
                    self.userController?.globCollectionView.isScrollEnabled = true
     
            })
        }
    }
    
    
    func filterContentForSearchText(_ searchText: String){
        
        if searchIsCity {
            
            if let globCities = cityController?.globCities {
                
                cityController?.dataSourceForSearchResult = globCities.filter({ (city: [AnyHashable: Any]) -> Bool in
                    
                    if let key = city["city"] as? String {
                        
                        return key.contains(searchText)
                        
                    } else {
                        
                        return false
                    }
                })
 
            }
            
        } else {
            
            if let globUsers = userController?.globUsers {
                
                userController?.dataSourceForSearchResult = globUsers.filter({ (user: [AnyHashable: Any]) -> Bool in
                    
                    if let firstName = user["firstName"] as? String, let lastName =  user["lastName"] as? String {
                        
                        let name = firstName + " " + lastName
                        return name.contains(searchText)
                        
                    } else {
                        
                        return false
                    }
                })
            }
        }
    }
    
    
    //Search Bar Delegates
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
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
        
        print("search bar active: \(searchBarActive)", terminator: "")
        
    }
    
    
    
    //CollectionView Delegates
        
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHid), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
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
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  
        if segue.identifier == "citySegue" {
            
            let city = segue.destination as? CityController
            cityController = city
            cityController?.searchController = self

        } else if segue.identifier == "userSegue" {
            
            let user = segue.destination as? UserController
            userController = user
            userController?.searchController = self
            
        }
        
        
        
        
        
        
        
        
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
    
    
}
