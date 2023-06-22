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
        
        if let provider = GIDSignIn.sharedInstance()?.currentUser?.authentication?.idToken,
           provider == GIDSignIn.sharedInstance()?.currentUser?.authentication?.idToken {
            GIDSignIn.sharedInstance()?.signOut()
        } else if let accessToken = AccessToken.current, !accessToken.isExpired {
            let loginManager = LoginManager()
            loginManager.logOut()
        } else if let userID = userID {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userID) { [weak self] (credentialState: ASAuthorizationAppleIDProvider.CredentialState, error: Error?) -> Void in
                guard let self = self else { return }
                switch credentialState {
                case .authorized:
                    // Perform Apple logout
                    let appleIDProvider = ASAuthorizationAppleIDProvider()
                    let request = appleIDProvider.createRequest()
                    request.requestedOperation = .operationLogout
                    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                    authorizationController.performRequests()
                    
                case .notFound, .revoked:
                    // User is already logged out or revoked
                    self.showLogoutSuccessAlert()
                    
                case .transferred:
                    // Credential transferred to a different device
                    self.showLogoutFailureAlert()
                    
                @unknown default:
                    self.showLogoutFailureAlert()
                }
            }
        }
        
        // Perform any other necessary cleanup or navigation
    }
    
  
    // Helper method to show logout success alert and pop the view controller
    private func showLogoutSuccessAlert() {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Logout Successful", message: "You have been successfully logged out.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                // Pop the current view controller from the navigation stack
                self?.navigationController?.popViewController(animated: true)
            }))
            self?.present(alertController, animated: true, completion: nil)
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
}

