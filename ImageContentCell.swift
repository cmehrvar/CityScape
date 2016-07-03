//
//  ImageContentCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-02.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import SDWebImage

class ImageContentCell: UITableViewCell {
    
    //Variables
    var data: [NSObject : AnyObject]!
    
    //Outlets
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var likeDisplayOutlet: UILabel!
    @IBOutlet weak var dislikeDisplayOutlet: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var cityOutlet: UILabel!
    @IBOutlet weak var captionOutlet: UILabel!
    @IBOutlet weak var cityRankOutlet: UILabel!
    @IBOutlet weak var viewsOutlet: UILabel!
    @IBOutlet weak var commentName1Outlet: UILabel!
    @IBOutlet weak var comment1Outlet: UILabel!
    @IBOutlet weak var commentName2Outlet: UILabel!
    @IBOutlet weak var comment2Outlet: UILabel!
    @IBOutlet weak var viewHowManyCommentsOutlet: UIButton!
    
    
    
    
    
    //Actions
    @IBAction func viewCommentsAction(sender: AnyObject) {
        
        print("view comments tapped")
        
    }
    
    
    @IBAction func viewAllCommentsAction(sender: AnyObject) {
        
        print("view all comments tapped")
        
    }
    
    
    func loadData() {
        
        if let actualLike = data["like"] as? Int, actualDislike = data["dislike"] as? Int, actualFirstName = data["firstName"] as? String, actualLastName = data["lastName"] as? String, actualCaption = data["caption"] as? String ,actualContent = data["contentURL"] as? String, actualProfile = data["profilePicture"] as? String, actualCity = data["city"] as? String {
            
            captionOutlet.text = actualCaption
            nameOutlet.text = actualFirstName + " " + actualLastName
            dislikeDisplayOutlet.text = "Likes: " + String(actualDislike)
            likeDisplayOutlet.text = "Likes: " + String(actualLike)
            cityOutlet.text = actualCity
            
            if let actualURL = NSURL(string: actualContent), actualProfileURL = NSURL(string: actualProfile) {
                
                imageOutlet.sd_setImageWithURL(actualURL, placeholderImage: nil)
                profilePictureOutlet.sd_setImageWithURL(actualProfileURL, placeholderImage: nil)
            
            }
        }
    }
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if data != nil {
            print(data)
        } else {
            print("no data on start")
        }
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
