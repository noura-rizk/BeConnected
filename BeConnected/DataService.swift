//
//  DataService.swift
//  BeConnected
//
//  Created by Noura Rizk on 12/29/15.
//  Copyright © 2015 Noura Rizk. All rights reserved.
//

import Foundation
import Firebase
let URL_BASE = "https://beconnected.firebaseio.com";

class DataService {
    static let ds = DataService();
    private var _REF_BASE = Firebase(url: "\(URL_BASE)");
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts");
    private var _REF_LIKES = Firebase(url: "\(URL_BASE)/likes");
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users");
    
    var REF_BASE: Firebase{
    return _REF_BASE
    }
    var REF_POSTS: Firebase{
        return _REF_POSTS
    }
    var REF_LIKES: Firebase{
        return _REF_LIKES
    }
    var REF_USERS: Firebase{
        return _REF_USERS
    }
    var REF_CURRENT_USER: Firebase{
        var uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String;
        var user = _REF_USERS.childByAppendingPath(uid);
        return user;
    }
    func createFirebaseUser(uid: String, user: Dictionary<String, String>){
        DataService.ds._REF_USERS.childByAppendingPath(uid).setValue(user);
    }
}