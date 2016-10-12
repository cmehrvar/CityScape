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

class MessagesController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    weak var rootController: MainRootController?
    
    var tableViewMessages = [[NSObject : AnyObject]]()
    
    var globMatches = [[NSObject : AnyObject]]()

    //Outlets
    @IBOutlet weak var globCollectionViewOutlet: UICollectionView!
    @IBOutlet weak var matchesHeightConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var globTableView: UITableView!
    @IBOutlet weak var noMatchesOutlet: UILabel!
    @IBOutlet weak var noMessagesOutlet: UILabel!

    //Actions
    @IBAction func composeMessage(sender: AnyObject) {

        self.rootController?.composeChat(true, completion: { (bool) in
            
            print("compose revealed")
            
        })
    }
    
    //Functions
    func loadMatches(data: [NSObject : AnyObject]){

        var matches = [[NSObject : AnyObject]]()

        for (_, value) in data {
            
            if let valueToAdd = value as? [NSObject : AnyObject] {
                
                matches.append(valueToAdd)

            }
        }
        
        matches.sortInPlace { (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
            
            if a["lastActivity"] as? NSTimeInterval > b["lastActivity"] as? NSTimeInterval {
                
                return true
                
            } else {
                
                return false
                
            }
        }
        
        
        
        
        globMatches = matches
        globCollectionViewOutlet.reloadData()
 
    }

    func sortMessages(selfData: [NSObject : AnyObject]) {

        var allMessages = [[NSObject : AnyObject]]()

        if let mySquad = selfData["squad"] as? [NSObject : AnyObject] {
            
            for (_, value) in mySquad {
                
                var read = false
                
                if let readValue = value["read"] as? Bool {
                    
                    read = readValue
                    
                }

                if let messages = value["messages"] as? [NSObject : AnyObject] {
                    
                let sortedMessages = messages.sort({ (a: (NSObject, AnyObject), b: (NSObject, AnyObject)) -> Bool in
                        
                        if a.1["timeStamp"] as? NSTimeInterval > b.1["timeStamp"] as? NSTimeInterval {
                            
                            return true
                            
                        } else {
                            
                            return false
                            
                        }
                    })

                    if let first = sortedMessages.first?.1 as? [NSObject : AnyObject] {

                        var toAppend = first
                        toAppend["type"] = "squad"
                        toAppend["read"] = read
                        allMessages.append(toAppend)
                        
                    }
                }
            }
        }

        if let myMatches = selfData["matches"] as? [NSObject : AnyObject] {
            
            for (_, value) in myMatches {
                
                var read = false
                
                if let readValue = value["read"] as? Bool {
                    
                    read = readValue
                    
                }
                
                if let messages = value["messages"] as? [NSObject : AnyObject] {
                    
                    let sortedMessages = messages.sort({ (a: (NSObject, AnyObject), b: (NSObject, AnyObject)) -> Bool in
                        
                        if a.1["timeStamp"] as? NSTimeInterval > b.1["timeStamp"] as? NSTimeInterval {
                            
                            return true
                            
                        } else {
                            
                            return false
                            
                        }
                    })
                    
                    if let first = sortedMessages.first?.1 as? [NSObject : AnyObject] {
                        
                        var toAppend = first
                        toAppend["type"] = "matches"
                        toAppend["read"] = read
                        allMessages.append(toAppend)
                        
                    }
                }
            }
        }
        
        
        if let myGroupChats = selfData["groupChats"] as? [NSObject : AnyObject] {
            
            for (_, value) in myGroupChats {
                
                if let valueToAdd = value as? [NSObject : AnyObject] {
                    
                    var toAppend = valueToAdd
                    toAppend["type"] = "groupChats"
                    allMessages.append(toAppend)
                    
                }
            }
        }
        
        

        allMessages.sortInPlace { (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
            
            if a["timeStamp"] as? NSTimeInterval > b["timeStamp"] as? NSTimeInterval {
                
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
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        rightSwipeGestureRecognizer.delegate = self
        
        self.globTableView.addGestureRecognizer(rightSwipeGestureRecognizer)
        
    }
    
    
    func showVibes(){
        
        rootController?.toggleVibes({ (bool) in
            
            print("vibes toggled")
            
        })
    }
    
    
    
    
    //TableView Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewMessages.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.allowsSelection = false
        
        let cell = tableView.dequeueReusableCellWithIdentifier("messageTableCell", forIndexPath: indexPath) as! MessageTableCell
        
        cell.messagesController = self
        
        cell.loadCell(tableViewMessages[indexPath.row])
        
        return cell
        
    }
    

    
    //Collection View Delegates
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return globMatches.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("matchCell", forIndexPath: indexPath) as! MatchCollectionViewCell
        
        
        var diameter: CGFloat!
        
        if let rootHeight = rootController?.view.bounds.height {
            
            let screenSize = (rootHeight - 120)
            
            diameter = (screenSize * 0.33) - ((screenSize * 0.33) * 0.3)
            
        }
        
        cell.profileOutlet.layer.cornerRadius = (((diameter - 20) / 2) - 1)
        
        cell.indicatorOutlet.layer.cornerRadius = 8
        cell.indicatorOutlet.layer.borderWidth = 2
        cell.indicatorOutlet.layer.borderColor = UIColor.whiteColor().CGColor
        
        cell.messagesController = self
        
        cell.loadCell(globMatches[indexPath.row])
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var diameter: CGFloat = 0.0
        
        if let rootHeight = rootController?.view.bounds.height {
            
            let screenSize = (rootHeight - 120)
            
            diameter = (screenSize * 0.33) - ((screenSize * 0.33) * 0.3)
            
        }
        
        let size = CGSize(width: (diameter), height: diameter)
        
        return size
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        
        print("view did appear")
        if let rootHeight = rootController?.view.bounds.height {
            self.matchesHeightConstOutlet.constant = rootHeight * 0.25
        }
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

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
        
        view.frame = CGRect(origin: CGPointZero, size: CGSize(width: self.view.bounds.width
            , height: 50))
        
        view.backgroundColor = UIColor.whiteColor()
        
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
