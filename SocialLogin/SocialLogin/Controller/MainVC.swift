//
//  ViewController.swift
//  SocialLogin
//
//  Created by IPS-161 on 21/06/23.
//

import UIKit
import GoogleSignIn

class MainVC: UIViewController , GIDSignInDelegate {
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.delegate = self
        // Do any additional setup after loading the view.
    }

    
    @IBAction func signInWithGoogleBtnPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
        
    }
    
    
    @IBAction func signInWithFacebookBtnPressed(_ sender: UIButton) {
        
    }
    
    
    @IBAction func signInWithAppleBtnPressed(_ sender: UIButton) {
        
        
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error == nil {
            print(user.userID!)
        }
    }
    
}

