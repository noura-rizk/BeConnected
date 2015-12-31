//
//  PostCell.swift
//  BeConnected
//
//  Created by Noura Rizk on 12/30/15.
//  Copyright © 2015 Noura Rizk. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    @IBOutlet weak var imgProfile: UIImageView!;
    @IBOutlet weak var imgScreen: UIImageView!;
    @IBOutlet weak var lblLikes: UILabel!;
    @IBOutlet weak var lblDesc: UITextView!;
    @IBOutlet weak var imgLike: UIImageView!;
    
    var post: Post!;
    var request: Request?
    var likesRef: Firebase!;
    var postsRef: Firebase!;
    static var NSImgCache: NSCache!;
    override func awakeFromNib() {
        super.awakeFromNib();
        let tap = UITapGestureRecognizer(target: self, action: "likedTapped:");
        tap.numberOfTapsRequired = 1;
        imgLike.addGestureRecognizer(tap);
        //P.S NOTE  I HAD TO ENABLE USER INTERACTION ENABLED = TRUE
    }
    
    
    override func drawRect(rect: CGRect) {
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2.0;
        imgProfile.clipsToBounds = true;
        imgScreen.clipsToBounds = true;
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(post: Post, img: UIImage?){
        self.post = post;
        likesRef = DataService.ds.REF_CURRENT_USER.childByAppendingPath("likes").childByAppendingPath(post.postKey);
        // postsRef = DataService.ds.REF_CURRENT_USER.childByAppendingPath("posts").childByAppendingPath(post.postKey); // check if user created this post
        lblDesc.text = post.desc;
        lblLikes.text = "\(post.likes)";
        var imgProf: UIImage?;
        var imgRef: Firebase;
        if(post.username == NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as? String){
            imgRef = DataService.ds.REF_CURRENT_USER.childByAppendingPath("profileImage");

        }else {
            var uid = post.username;
             imgRef = DataService.ds.REF_USERS.childByAppendingPath(uid).childByAppendingPath("profileImage");
        }
        

         imgRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            //print("snapshot=\(snapshot.value)");
            if let x = snapshot.exists() as? Bool{
                if let ur = snapshot.value as? String{
                    if(ur != ""){
                        //let ur = "https://s-media-cache-ak0.pinimg.com/236x/a4/4c/f5/a44cf5306107e21bdbfeaf85900cf5c7.jpg";
                        imgProf = FeedVC.imgCache.objectForKey(ur) as? UIImage;
                        if imgProf != nil {
                            self.imgProfile.image = imgProf;
                        }else{
                            print("here")
                            self.request = Alamofire.request(.GET, ur).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                                if(err == nil){
                                    let img = UIImage(data: data!)!;
                                    self.imgProfile.image = img;
                                    FeedVC.imgCache.setObject(img, forKey: ur);
                                }
                            })
                        }
                    }
                }
            }
        })

        
        
        if post.imageUrl != nil{
            if img != nil {
                self.imgScreen.image = img;
            }else{
                // request from server
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if(err == nil){
                        let img = UIImage(data: data!)!;
                        self.imgScreen.image = img;
                        FeedVC.imgCache.setObject(img, forKey: post.imageUrl!);
                    }
                })
            }
        }else{
            imgScreen.hidden = true;
        }
        // print("LIKE+++=\(likesRef)");
        likesRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if let snap = snapshot.value as? NSNull {
                self.imgLike.image = UIImage(named: "heart-empty");
            }else{
                self.imgLike.image = UIImage(named: "heart-full");
            }
        })
        //print("POSTSS\(postsRef)");
        
        /* postsRef.observeSingleEventOfType(.Value, withBlock: {
        snapshot in
        
        print("SNAppp\(snapshot.value)");
        if let snapf = snapshot.value as? NSNull {}
        else{
        var imgPro = DataService.ds.REF_CURRENT_USER.childByAppendingPath("profileImage");
        imgPro.observeSingleEventOfType(.Value, withBlock: {
        snap in
        
        if let sp = snap.value as? NSNull {
        }else{
        let url = NSURL(string: "https://s-media-cache-ak0.pinimg.com/236x/a4/4c/f5/a44cf5306107e21bdbfeaf85900cf5c7.jpg");
        let data = NSData(contentsOfURL:url!)
        if data != nil {
        self.imgProfile.image = UIImage(data:data!)
        }
        
        }
        })
        }
        })
        */
    }
    
    func getProfileImageURL(ref: Firebase)-> String?{
        //print(ref);
        var url: String!;
        ref.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            //print("snapshot=\(snapshot.value)");
            if let x = snapshot.exists() as? Bool{
                if let ur = snapshot.value as? String{
                    url = ur;
                    print("url==\(url)");
                }else{
                    url = "";
                }
            }
        })
        return url;
    }
    
    
    func likedTapped(sender: UITapGestureRecognizer){
        print("TAPPED");
        likesRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if let snap = snapshot.value as? NSNull {
                self.imgLike.image = UIImage(named: "heart-full");
                self.post.adjustLike(true);
                self.likesRef.setValue(true);
            }else{
                self.imgLike.image = UIImage(named: "heart-empty");
                self.post.adjustLike(false);
                self.likesRef.removeValue();
            }
            
        })
    }
}
