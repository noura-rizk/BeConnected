//
//  ProfileVC.swift
//  BeConnected
//
//  Created by Noura Rizk on 12/31/15.
//  Copyright © 2015 Noura Rizk. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class ProfileVC: UIViewController {

    @IBOutlet weak var lblUernamse: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!;
    override func viewDidLoad() {
        super.viewDidLoad()
       let imgRef = DataService.ds.REF_CURRENT_USER.childByAppendingPath("profileImage");
        var imgProf: UIImage?;
        lblUernamse.text = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String;
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
                           // print("here")
                            var request = Alamofire.request(.GET, ur).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
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

        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2.0;
        imgProfile.clipsToBounds = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
