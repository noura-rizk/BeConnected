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

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var txtUsername: MaterialTextField!
    @IBOutlet weak var lblUernamse: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!;
    
    var imgPicker: UIImagePickerController!;
    var imgSelected = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        imgPicker = UIImagePickerController();
        imgPicker.delegate = self;
        let imgRef = DataService.ds.REF_CURRENT_USER.childByAppendingPath("profileImage");
        var imgProf: UIImage?;
        lblUernamse.text = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String;
        imgRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            //print("snapshot=\(snapshot.value)");
            if let x = snapshot.exists() as? Bool{
                if let ur = snapshot.value as? String{
                    if(ur != ""){
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
    
    @IBAction func changeUserName(sender: AnyObject) {
        lblUernamse.hidden = true;
        btnChange.hidden = true;
        txtUsername.hidden = false;
    }
    
    @IBAction func btnPressed(sender: AnyObject) {
        presentViewController(imgPicker, animated: true, completion: nil);
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imgPicker.dismissViewControllerAnimated(true, completion: nil);
        imgProfile.image = image;
        imgSelected = true;
    }
    
    
    @IBAction func update(sender: AnyObject) {
        
        var user: Dictionary<String, AnyObject>! ;
        if let txt = txtUsername.text where txt != "" {
            user = ["username": txt];
        }
        if  imgSelected {
            let img = imgProfile.image!;
            let urlStr = "https://post.imageshack.us/upload_api.php";
            let url = NSURL(string: urlStr)!;
            let imgData = UIImageJPEGRepresentation(img, 0.2)!;
            let keyData = "GMIPLUZ95b977612139505c0f1aced207d4dacbe".dataUsingEncoding(NSUTF8StringEncoding)! // convert string into data
            let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
            Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: imgData, name:"fileupload", fileName:"image", mimeType: "image/jpg")
                multipartFormData.appendBodyPart(data: keyData, name: "key")
                multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                
                }) { encodingResult in // when request is done
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON(completionHandler: {response in
                            if let info = response.result.value as? Dictionary<String, AnyObject> {
                                if let links = info["links"] as? Dictionary<String, AnyObject> {
                                    print(links)
                                    if let imgLink = links["image_link"] as? String {
                                        print("imgLINK=\(imgLink)");
                                        user["profileImage"] = imgLink;
                                        if user.count > 0{
                                            DataService.ds.REF_CURRENT_USER.updateChildValues(user);
                                        }
                                    }
                                }
                            }
                        })
                    case .Failure(let error):
                        print(error)
                        //Maybe show alert to user and let them try again
                    }// switch
            }// result
        }else{
            if user.count > 0{
                DataService.ds.REF_CURRENT_USER.updateChildValues(user);
            }
        }
        
        
        lblUernamse.hidden = false;
        txtUsername.hidden = true;
        txtUsername.text = "";
        btnChange.hidden = false;
        
        
    }
}
