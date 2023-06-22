import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FacebookLogin
import AuthenticationServices

class MainVC: UIViewController, GIDSignInDelegate, LoginButtonDelegate {
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.isHidden = true
        activityIndicator.startAnimating()
        GIDSignIn.sharedInstance()?.delegate = self
        
    }
    
    @IBAction func signInWithGoogleBtnPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
        activityIndicatorView.isHidden = false
    }
    
    @IBAction func signInWithFacebookBtnPressed(_ sender: UIButton) {
        loginButtonClicked()
        activityIndicatorView.isHidden = false
    }
    
    @IBAction func signInWithAppleBtnPressed(_ sender: UIButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        activityIndicatorView.isHidden = false
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            activityIndicatorView.isHidden = true
            guard let data = user.profile else { return }
            guard let profilePictureURL = user.profile.imageURL(withDimension: 200)?.absoluteString else { return }
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyBoard.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
            destinationVC.name = data.name
            destinationVC.userID = user.userID
            destinationVC.email = data.email
            destinationVC.profileUrl = profilePictureURL
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    func fetchFacebookUserProfile() {
        if let accessToken = AccessToken.current, !accessToken.isExpired {
            let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id,name,email,picture"], tokenString: accessToken.tokenString, version: nil, httpMethod: .get)
            graphRequest.start { _, result, error in
                if let error = error {
                    print("Error fetching Facebook user profile: \(error.localizedDescription)")
                } else if let userData = result as? [String: Any] {
                    self.activityIndicatorView.isHidden = true
                    let name = userData["name"] as? String
                    let userID = userData["id"] as? String
                    let email = userData["email"] as? String
                    
                    if let pictureData = userData["picture"] as? [String: Any], let picture = pictureData["data"] as? [String: Any], let profilePictureURL = picture["url"] as? String {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let destinationVC = storyBoard.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
                        destinationVC.name = name
                        destinationVC.userID = userID
                        destinationVC.email = email
                        destinationVC.profileUrl = profilePictureURL
                        self.navigationController?.pushViewController(destinationVC, animated: true)
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // Handle Facebook logout
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
    }
    
    
    func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile"], from: self) { result, error in
            if let error = error {
                print("Encountered Erorr: \(error)")
            } else if let result = result, result.isCancelled {
                print("Cancelled")
            } else {
                print("Logged In")
                self.fetchFacebookUserProfile()
            }
        }
    }
    
    
    
    
}

extension MainVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            activityIndicatorView.isHidden = true
            let userID = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            let name = "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")"
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyBoard.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
            destinationVC.name = name
            destinationVC.userID = userID
            destinationVC.email = email
            destinationVC.profileUrl = nil // Apple sign-in doesn't provide a profile picture
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple sign-in error: \(error.localizedDescription)")
        activityIndicatorView.isHidden = true
    }
}

extension MainVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

