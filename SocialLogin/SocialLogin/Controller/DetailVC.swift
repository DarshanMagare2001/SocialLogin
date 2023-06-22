import UIKit
import Kingfisher
import GoogleSignIn
import FBSDKLoginKit
import FacebookLogin
import AuthenticationServices

class DetailVC: UIViewController {
    var name: String?
    var email: String?
    var userID: String?
    var profileUrl: String?
    var nameOfSocialmedia: String?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTxtLbl: UILabel!
    @IBOutlet weak var emailTxtLbl: UILabel!
    @IBOutlet weak var userIDTxtLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        DispatchQueue.main.async { [weak self] in
            self?.nameTxtLbl.text = self?.name
            self?.emailTxtLbl.text = self?.email
            self?.userIDTxtLbl.text = self?.userID
            
            if let profileUrl = self?.profileUrl, let url = URL(string: profileUrl) {
                self?.profileImageView.kf.setImage(with: url)
            }
        }
    }
    
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        // Logout from different social media platforms
        logOut()
        // Perform any other necessary cleanup or navigation
    }
    
    // Helper method to show logout success alert and pop the view controller
    private func showLogoutSuccessAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            var message = "You have been successfully logged out."
            
            if let nameOfSocialmedia = self.nameOfSocialmedia {
                message += "From \(nameOfSocialmedia)"
            }
            
            let alertController = UIAlertController(title: "Logout Successful", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                // Pop the current view controller from the navigation stack
                self?.navigationController?.popViewController(animated: true)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    
    // Helper method to show logout failure alert
    private func showLogoutFailureAlert() {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Logout Failed", message: "Failed to logout. Please try again.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func logOut() {
        guard let nameOfSocialmedia = nameOfSocialmedia else {
            // Social media name is not available, handle the logout accordingly
            return
        }
        
        switch nameOfSocialmedia {
        case "Google":
            GIDSignIn.sharedInstance()?.signOut()
            showLogoutSuccessAlert()
            
        case "FaceBook":
            let loginManager = LoginManager()
            loginManager.logOut()
            showLogoutSuccessAlert()
            
        case "Apple":
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userID!) { [weak self] credentialState, error in
                guard let self = self else { return }
                
                switch credentialState {
                case .authorized:
                    let appleIDProvider = ASAuthorizationAppleIDProvider()
                    let request = appleIDProvider.createRequest()
                    request.requestedOperation = .operationLogout
                    
                    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                    authorizationController.delegate = self
                    authorizationController.performRequests()
                    
                case .notFound, .revoked:
                    // User is already logged out or revoked
                    self.showLogoutSuccessAlert()
                    
                case .transferred:
                    // Credential transferred to a different device
                    self.showLogoutFailureAlert()
                    
                default:
                    // Unknown state
                    self.showLogoutFailureAlert()
                }
            }
            
        default:
            // Handle logout for other social media platforms if needed
            break
        }
        
        // Perform any other necessary cleanup or navigation
    }
}

extension DetailVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // Logout succeeded
        showLogoutSuccessAlert()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Logout failed
        showLogoutFailureAlert()
    }
}

