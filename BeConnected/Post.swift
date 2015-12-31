//
//  Post.swift
//  stayConnected
//
//  Created by Noura Rizk on 12/30/15.
//  Copyright © 2015 Noura Rizk. All rights reserved.
//

import Foundation
import Firebase
class Post {
    private var _desc: String!;
    private var _imageUrl: String?
    private var _likes: Int!;
    private var _username: String!;
    private var _postKey: String!;
    private var postRef: Firebase!;
    
    var desc: String{
        return _desc;
    }
    var imageUrl: String?{
        return _imageUrl;
    }
    var username: String{
        return _username;
    }
    var likes: Int{
        return _likes;
    }
    var postKey: String{
        return _postKey;
    }
    
    init (descrition: String, image: String? , username: String){
        self._desc = descrition;
        self._imageUrl = image;
        self._username = username;
    }
    init(postKey: String, dictionary: Dictionary<String, AnyObject>){
        self._postKey = postKey;
        if let likes = dictionary["likes"] as? Int{
            self._likes = likes;
        }
        if let descs = dictionary["description"] as? String{
            self._desc = descs;
        }
        if let imageUrl = dictionary["imageUrl"] as? String{
            self._imageUrl = imageUrl;
        }
        if let username = dictionary["createdBy"] as? String{
            self._username = username;
        }
        self.postRef = DataService.ds.REF_POSTS.childByAppendingPath(_postKey);
        
    }
    func adjustLike(addLike: Bool){
        if addLike{
            _likes = _likes + 1;
        }else{
            _likes = _likes - 1;
        }
        self.postRef.childByAppendingPath("likes").setValue(_likes)
    }
}