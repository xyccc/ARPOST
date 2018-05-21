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
import UserNotifications
import CoreLocation

class ViewController: UIViewController, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // less batery ussage
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("NotificationCenter Authorization Granted!")
            }
        }
        locationManager.startUpdatingLocation()

        // Presenting the Login Screen View Controller
        if (AccessToken.current == nil) {
            self.presentLoginViewController()
        } else {
            self.presentARCameraViewController()
        }
    }
    
    @IBAction func ScheduleNotification(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        
        center.removeAllPendingNotificationRequests() // deletes pending scheduled notifications, there is a schedule limit qty
        
        let content = UNMutableNotificationContent()
        content.title = "Try out AR POST here!"
        content.body = "Post something here using AR POST."
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default()
        
        let centerLoc = CLLocationCoordinate2D(latitude: 47.6650898, longitude: -122.2989735)
        let region = CLCircularRegion(center: centerLoc, radius: 100.0, identifier: UUID().uuidString) // radius in meters
        region.notifyOnEntry = true
        region.notifyOnExit = false
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]
        let latitude = String(latestLocation.coordinate.latitude)
        let longitude = String(latestLocation.coordinate.longitude)
        print("\(latitude) \(longitude)")
    }
    
    // Use this method whenever you want to present your Login Screen
    private func presentLoginViewController() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewControllerIdentifier")
        self.present(loginVC, animated: true, completion: nil)
    }

    private func presentARCameraViewController() {
        let storyboard = UIStoryboard(name: "ARCamera", bundle: nil)
        let arCam = storyboard.instantiateViewController(withIdentifier: "ARCameraViewControllerIdentifier")
        self.present(arCam, animated: true, completion: nil)
    }
    

}
