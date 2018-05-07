//
//  LoginViewController.swift
//  AR Post
//
//  Created by yuchong xiang on 4/26/18.
//  Copyright © 2018 uw. All rights reserved.
//

import FacebookLogin
import FacebookCore
import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
//        let loginButton = LoginButton
//        loginButton.center = view.center
//
//        let loginManager = LoginManager()
//        loginManager.logIn(readPermissions: [ .publicProfile, .email, .userFriends ], viewController: nil, completion: didLogin)
        
//         FBSDKAccessTokenDidChangeNotification
//        let loginResult = LoginResult()
//
//        loginManager.logIn(readPermissions: readPermissions, viewController: self, completion: didReceiveFacebookLoginResult)
//
//        view.addSubview(loginButton)
        
//         NSNotificationCenter.defaultCenter().addObserver(self, selector:"checkLogIn", name: FBSDKAccessTokenDidChangeNotification, object: nil)

    }
//     override func FBSDKAccessTokenDidChangeNotification()
    
    @IBAction func didTapLoginButton(_ sender: FacebookLoginButton) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ .publicProfile, .email, .userFriends ], viewController: nil, completion: didLogin)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("disapper!!!")
    }
    
    private func didLogin(loginResult: LoginResult) {
        switch loginResult {
        case .success:
            self.dismiss(animated: true, completion: nil)
        default:
            print("failed to login")
        }
    }
    
    // Use this method whenever you want to present your Login Screen
    private func presentARCameraViewController() {
        let storyboard = UIStoryboard(name: "ARCamera", bundle: nil)
        let arCam = storyboard.instantiateViewController(withIdentifier: "ARCameraViewControllerIdentifier")
        self.present(arCam, animated: true, completion: nil)
    }

}
