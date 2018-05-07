//
//  ViewController.swift
//  AR Post
//
//  Created by yuchong xiang on 4/24/18.
//  Copyright © 2018 uw. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FacebookLogin
import FacebookCore

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // Presenting the Login Screen View Controller
        if (AccessToken.current == nil) {
            self.presentLoginViewController()
        } else {
            self.presentARCameraViewController()
        }
    }

    // Use this method whenever you want to present your Login Screen
    private func presentLoginViewController() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewControllerIdentifier")
        self.present(loginVC, animated: true, completion: nil)
    }

    private func pushLoginViewController() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewControllerIdentifier")
        self.navigationController?.pushViewController(loginVC, animated: true)
    }

    private func presentARCameraViewController() {
        let storyboard = UIStoryboard(name: "ARCamera", bundle: nil)
        let arCam = storyboard.instantiateViewController(withIdentifier: "ARCameraViewControllerIdentifier")
        self.present(arCam, animated: true, completion: nil)
    }
    
    private func pushARCameraViewController() {
        let storyboard = UIStoryboard(name: "ARCamera", bundle: nil)
        let arCam = storyboard.instantiateViewController(withIdentifier: "ARCameraViewControllerIdentifier")
        self.navigationController?.pushViewController(arCam, animated: true)
    }

}
