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
//            print("User ID: \(user.userID ?? "")")
//            print("User Full Name: \(user.profile.name ?? "")")
//            print("User Given Name: \(user.profile.givenName ?? "")")
//            print("User Family Name: \(user.profile.familyName ?? "")")
//            print("User Email: \(user.profile.email ?? "")")
            guard let data = user.profile else {return}
            guard let profilePictureURL = user.profile.imageURL(withDimension: 200)?.absoluteString  else { return }
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyBoard.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
            destinationVC.name = data.name
            destinationVC.userID = user.userID
            destinationVC.email = data.email
            destinationVC.profileUrl = profilePictureURL
            navigationController?.pushViewController(destinationVC, animated: true)
            
        }
        
        
    }

    
}

