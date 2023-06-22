import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FacebookLogin
import AuthenticationServices

class MainVC: UIViewController, GIDSignInDelegate, LoginButtonDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.delegate = self
        
    }
    
    @IBAction func signInWithGoogleBtnPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func signInWithFacebookBtnPressed(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email"], viewController: self) { result in
            switch result {
            case .success(let grantedPermissions, _, _):
                if grantedPermissions.contains("email") {
                    self.fetchFacebookUserProfile()
                    // TODO: Handle publishing content with the "email" permission
                } else {
                    print("Email permission not granted.")
                }
            case .cancelled:
                print("Facebook login cancelled.")
            case .failed(let error):
                print("Facebook login failed: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func signInWithAppleBtnPressed(_ sender: UIButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
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
            let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id,name,email,picture.width(200).height(200)"], tokenString: accessToken.tokenString, version: nil, httpMethod: .get)
            graphRequest.start { _, result, error in
                if let error = error {
                    print("Error fetching Facebook user profile: \(error.localizedDescription)")
                } else if let userData = result as? [String: Any] {
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
        if result != nil {
            if let grantedPermissions = result?.grantedPermissions, grantedPermissions.contains("email") {
                fetchFacebookUserProfile()
                // TODO: Handle publishing content with the "email" permission
            } else {
                print("Email permission not granted.")
            }
        } else if let error = error {
            print("Facebook login failed: \(error.localizedDescription)")
        } else {
            print("Facebook login cancelled.")
        }
    }
    
}

extension MainVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
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
    }
}

extension MainVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

