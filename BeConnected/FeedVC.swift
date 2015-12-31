//
//  FeedVC.swift
//  BeConnected
//
//  Created by Noura Rizk on 12/30/15.
//  Copyright © 2015 Noura Rizk. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imagePicker: UIImagePickerController!;
    @IBOutlet weak var tblView: UITableView!;
    var posts = [Post]();
    
    @IBOutlet weak var txtPost: MaterialTextField!
    @IBOutlet weak var imgPost: UIImageView!
    
    static var imgCache = NSCache();
    
    var imgSelected = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.dataSource = self;
        tblView.delegate = self;
        tblView.estimatedRowHeight = 382;
        imagePicker = UIImagePickerController();
        imagePicker.delegate = self;
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: {
            snapshot in
            self.posts = [];
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot]{
                for snap in snapshots {
                    //  print("SNAP== \(snap.value)");
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key;
                        let post = Post(postKey: key, dictionary: postDict);
                        self.posts.append(post);
                        // print("\(self.posts.count)")
                    }
                }
                
            }
            self.tblView.reloadData();
        })
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post  = self.posts[indexPath.row];
        //print(post.desc);
        
        
        if let cell = tblView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell{
            var img: UIImage?;
            if let url = post.imageUrl{
                img = FeedVC.imgCache.objectForKey(url) as? UIImage;
            }
            cell.configureCell(post, img:  img);
            return cell;
        } else {
            return PostCell();
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //  print("\(posts.count)")
        return posts.count;
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post  = self.posts[indexPath.row];
        if  post.imageUrl == nil{
            return 150;
        }else{
            return tblView.estimatedRowHeight;
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil);
        imgPost.image = image;
        imgSelected = true;
    }
    
    @IBAction func imgPostTapped(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnPressed(sender: AnyObject) {
        if let txt = txtPost.text where txt != "" {
            if let img = imgPost.image where img != UIImage(named: "camera") && imgSelected {
                print("IMAGE IS NOT CAMERA");
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
                                            self.postToFirebase(imgLink)
                                        }
                                    }
                                }
                            })
                            
                        case .Failure(let error):
                            print(error)
                            //Maybe show alert to user and let them try again
                        }
                }
                
                
            }else{
                print("IMAGE IS CAMERA");
                postToFirebase(nil);
            }
        }
    }
    
    func postToFirebase(imgLink: String?){
        var uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String;
        var post: Dictionary<String, AnyObject> = [
            "description":txtPost.text!,
            "likes": 0,
            "createdBy": uid
        ]
        
        if imgLink != nil {
            post["imageUrl"] = imgLink!
        }
        
        //Save new post to firebase
        let fbPost = DataService.ds.REF_POSTS.childByAutoId()
        fbPost.setValue(post)
        
        //Clear out fields
        self.txtPost.text = ""
        self.imgPost.image = UIImage(named: "camera")
        imgSelected = false;
        
        tblView.reloadData()
    }
    
    @IBAction func goToProfile(sender: AnyObject) {
       performSegueWithIdentifier("ProfileCV", sender: nil);
    }
}
