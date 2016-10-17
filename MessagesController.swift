//
//  MessagesController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-06.
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


class MessagesController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    weak var rootController: MainRootController?
    
    var tableViewMessages = [[AnyHashable: Any]]()
    
    var globMatches = [[AnyHashable: Any]]()

    //Outlets
    @IBOutlet weak var globCollectionViewOutlet: UICollectionView!
    @IBOutlet weak var matchesHeightConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var globTableView: UITableView!
    @IBOutlet weak var noMatchesOutlet: UILabel!
    @IBOutlet weak var noMessagesOutlet: UILabel!

    //Actions
    @IBAction func composeMessage(_ sender: AnyObject) {

        self.rootController?.composeChat(true, completion: { (bool) in
            
            print("compose revealed")
            
        })
    }
    
    //Functions
    func loadMatches(_ data: [AnyHashable: Any]){

        var matches = [[AnyHashable: Any]]()

        for (_, value) in data {
            
            if let valueToAdd = value as? [AnyHashable: Any] {
                
                matches.append(valueToAdd)

            }
        }
        
        matches.sort { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
            
            if a["lastActivity"] as? TimeInterval > b["lastActivity"] as? TimeInterval {
                
                return true
                
            } else {
                
                return false
                
            }
        }
        
        
        
        
        globMatches = matches
        globCollectionViewOutlet.reloadData()
 
    }

    func sortMessages(_ selfData: [AnyHashable: Any]) {

        var allMessages = [[AnyHashable: Any]]()

        if let mySquad = selfData["squad"] as? [AnyHashable: Any] {
            
            for (_, someValue) in mySquad {
                
                if let value = someValue as? [AnyHashable : Any] {
                    
                    var read = false
                    
                    if let readValue = value["read"] as? Bool {
                        
                        read = readValue
                        
                    }
                    
                    if let messages = value["messages"] as? [AnyHashable : Any] {
                        
                        let sortedMessages = messages.sorted(by: { (a: (key: AnyHashable, value: Any), b: (key: AnyHashable, value: Any)) -> Bool in
                            
                            if let aValue = a.value as? [AnyHashable : Any], let bValue = b.value as? [AnyHashable : Any] {
                                
                                if aValue["timeStamp"] as? TimeInterval > bValue["timeStamp"] as? TimeInterval {
                                    
                                    return true
                                    
                                } else {
                                    
                                    return false
                                    
                                }
                            }
                            
                            return false

                        })
                        
                        if let first = sortedMessages.first?.1 as? [AnyHashable: Any] {
                            
                            var toAppend = first
                            toAppend["type"] = "squad"
                            toAppend["read"] = read
                            allMessages.append(toAppend)
                            
                        }
                    }
                }
            }
        }

        if let myMatches = selfData["matches"] as? [AnyHashable: Any] {
            
            for (_, someValue) in myMatches {
                
                if let value = someValue as? [AnyHashable : Any] {
                    
                    var read = false
                    
                    if let readValue = value["read"] as? Bool {
                        
                        read = readValue
                        
                    }
                    
                    if let messages = value["messages"] as? [AnyHashable: Any] {
                        
                        let sortedMessages = messages.sorted(by: { (a: (key: AnyHashable, value: Any), b: (key: AnyHashable, value: Any)) -> Bool in
                            
                            if let aValue = a.value as? [AnyHashable : Any], let bValue = b.value as? [AnyHashable : Any] {
                                
                                if aValue["timeStamp"] as? TimeInterval > bValue["timeStamp"] as? TimeInterval {
                                    
                                    return true
                                    
                                } else {
                                    
                                    return false
                                    
                                }
                            }
                            
                            return false
                            
                        })
                        
                        if let first = sortedMessages.first?.1 as? [AnyHashable: Any] {
                            
                            var toAppend = first
                            toAppend["type"] = "matches"
                            toAppend["read"] = read
                            allMessages.append(toAppend)
                            
                        }
                    }
                }
            }
        }
        
        
        if let myGroupChats = selfData["groupChats"] as? [AnyHashable: Any] {
            
            for (_, value) in myGroupChats {
                
                if let valueToAdd = value as? [AnyHashable: Any] {
                    
                    var toAppend = valueToAdd
                    toAppend["type"] = "groupChats"
                    allMessages.append(toAppend)
                    
                }
            }
        }
        
        

        allMessages.sort { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
            
            if a["timeStamp"] as? TimeInterval > b["timeStamp"] as? TimeInterval {
                
                return true
                
            } else {
                
                return false
                
            }
        }
        
        self.tableViewMessages = allMessages
        self.globTableView.reloadData()
        
        if allMessages.count == 0 {
            
            self.noMessagesOutlet.alpha = 1
            
        } else {
            
            self.noMessagesOutlet.alpha = 0
            
        }

    }
    
    
    
    
    func addGestureRecognizers(){
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showVibes))
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        rightSwipeGestureRecognizer.delegate = self
        
        self.globTableView.addGestureRecognizer(rightSwipeGestureRecognizer)
        
    }
    
    
    func showVibes(){
        
        rootController?.toggleVibes({ (bool) in
            
            print("vibes toggled")
            
        })
    }
    
    
    
    
    //TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewMessages.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.allowsSelection = false
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageTableCell", for: indexPath) as! MessageTableCell
        
        cell.messagesController = self
        
        cell.loadCell(tableViewMessages[(indexPath as NSIndexPath).row])
        
        return cell
        
    }
    

    
    //Collection View Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return globMatches.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "matchCell", for: indexPath) as! MatchCollectionViewCell
        
        
        var diameter: CGFloat!
        
        if let rootHeight = rootController?.view.bounds.height {
            
            let screenSize = (rootHeight - 120)
            
            diameter = (screenSize * 0.33) - ((screenSize * 0.33) * 0.3)
            
        }
        
        cell.profileOutlet.layer.cornerRadius = (((diameter - 20) / 2) - 1)
        
        cell.indicatorOutlet.layer.cornerRadius = 8
        cell.indicatorOutlet.layer.borderWidth = 2
        cell.indicatorOutlet.layer.borderColor = UIColor.white.cgColor
        
        cell.messagesController = self
        
        cell.loadCell(globMatches[(indexPath as NSIndexPath).row])
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var diameter: CGFloat = 0.0
        
        if let rootHeight = rootController?.view.bounds.height {
            
            let screenSize = (rootHeight - 120)
            
            diameter = (screenSize * 0.33) - ((screenSize * 0.33) * 0.3)
            
        }
        
        let size = CGSize(width: (diameter), height: diameter)
        
        return size
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("view did appear")
        if let rootHeight = rootController?.view.bounds.height {
            self.matchesHeightConstOutlet.constant = rootHeight * 0.25
        }
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        print(velocity.y)
        
        if velocity.y > 1 {
            
            if tableViewMessages.count > 3 {
                
                rootController?.hideAllNav({ (bool) in
                    
                    print("nav hid")
                    
                })
            }

        } else if velocity.y < -1 {
            
            rootController?.showNav(0.3, completion: { (bool) in
                
                print("nav shown")
                
            })
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = UIView()
        
        view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.bounds.width
            , height: 50))
        
        view.backgroundColor = UIColor.white
        
        globTableView.tableFooterView = view
        
        addGestureRecognizers()
        
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
