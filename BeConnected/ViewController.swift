//
//  ViewController.swift
//  BeConnected
//
//  Created by Noura Rizk on 12/28/15.
//  Copyright © 2015 Noura Rizk. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var txtEmail: MaterialTextField!
    @IBOutlet weak var txtPassword: MaterialTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil{
           self.performSegueWithIdentifier(SEGUE_LOGGEDIN, sender: nil);
        }
    }

    @IBAction func fbBtnPressed(sender: AnyObject) {        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"], handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID);
                            let dict = ["provider" : authData.provider!, "blah": "test"];
                            DataService.ds.createFirebaseUser(authData.uid, user: dict);
                            self.performSegueWithIdentifier(SEGUE_LOGGEDIN, sender: nil);
                        }
                        
                })
            }
        })
        
        
    }
    
    
    @IBAction func attemptBtnPressed(sender: AnyObject) {
        if let email = txtEmail.text where email != "", let pwd = txtPassword.text where pwd != ""{
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {err, authData in // try to login
                if err != nil{ // couldn't login
                    print(err);
                    if err.code ==  STATUS_ACOUNT_NONEXIST{ // EMAIL not exist create user
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            if error !=  nil{
                                self.showAlertMessages("Error", msg: "Couldn't create Account")
                            }else{
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID);
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {
                                errd, authData in
                                    
                                    let dict = ["provider" : authData.provider!, "blah": "email Test"];
                                    DataService.ds.createFirebaseUser(authData.uid, user: dict);
                                }); // LOGIN with email and pawword after create new user
                                self.performSegueWithIdentifier(SEGUE_LOGGEDIN, sender: nil);
                            }
                        })
                    } else{
                      self.showAlertMessages("Error", msg: "Couldn't login, Invalid Email or Password")
                    }
                }else{ // logged noramlly
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID);
                    self.performSegueWithIdentifier(SEGUE_LOGGEDIN, sender: nil);
                }
            })
        
        }else{
            showAlertMessages("Athuntecation Failed", msg: "Please enter your email, and password");
        }
    }
    
    
    func showAlertMessages(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert);
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil);
        alert.addAction(action);
        presentViewController(alert, animated: true, completion: nil);
    }
    
    

}

