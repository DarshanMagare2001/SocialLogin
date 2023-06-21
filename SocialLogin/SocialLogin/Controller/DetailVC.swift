//
//  DetailVC.swift
//  SocialLogin
//
//  Created by IPS-161 on 21/06/23.
//

import UIKit
import Kingfisher

class DetailVC: UIViewController {
    var name: String?
    var email: String?
    var userID: String?
    var profileUrl: String?
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameTxtLbl: UILabel!
    
    @IBOutlet weak var emailTxtLbl: UILabel!
    
    @IBOutlet weak var userIDTxtLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTxtLbl.text = name
        emailTxtLbl.text = email
        userIDTxtLbl.text = userID
        
        if let url = URL(string: profileUrl ?? "") {
            profileImageView.kf.setImage(with: url)
        }
    }
}

