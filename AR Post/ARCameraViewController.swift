//
//  ARCameraViewController.swift
//  AR Post
//
//  Created by yuchong xiang on 4/26/18.
//  Copyright © 2018 uw. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import FacebookLogin
import FacebookCore

class ARCameraViewController: UIViewController, ARSCNViewDelegate {
    
    var isAdding = false
    var isPainting = false {
        didSet {
            if isPainting {
                
            } else {
                
            }
        }
    }
    var textButton = UIButton()
    var paintButton = UIButton()
    var imageButton = UIButton()
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    @objc func didTapTextButton(sender: UIButton!) {
        print("add sticky notes")
    }
    @objc func didTapPaintButton(sender: UIButton!) {
        isPainting = true
        print("start painting")
    }
    @objc func didTapImageButton(sender: UIButton!) {
        print("insert image")
    }
    
    @IBAction func didTapAddButton(_ sender: UIButton) {
        if isAdding {
            sender.setImage(#imageLiteral(resourceName: "iconpng.png"), for: .normal)
            textButton.removeFromSuperview()
            paintButton.removeFromSuperview()
            imageButton.removeFromSuperview()
        } else {
            sender.setImage(#imageLiteral(resourceName: "close_green.png"), for: .normal)
            self.view.addSubview(textButton)
            self.view.addSubview(paintButton)
            self.view.addSubview(imageButton)
        }
        isAdding = !isAdding
    }
    
    
    @IBAction func didTapLogoutButton(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logOut()
        print("logout success")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    

        textButton.frame = CGRect(x: 60, y: 550, width: 80, height: 50)
        textButton.backgroundColor = UIColor.brown
        textButton.tintColor = UIColor.white
        textButton.setTitle("Text", for: .normal)
        textButton.addTarget(self, action: #selector(didTapTextButton), for: .touchUpInside)
        
        paintButton.frame = CGRect(x: self.view.frame.size.width - 250, y: 550, width: 80, height: 50)
        paintButton.backgroundColor = UIColor.brown
        paintButton.tintColor = UIColor.white
        paintButton.setTitle("Paint", for: .normal)
        paintButton.addTarget(self, action: #selector(didTapPaintButton), for: .touchUpInside)
        
        imageButton.frame = CGRect(x: self.view.frame.size.width - 140, y: 550, width: 80, height: 50)
        imageButton.backgroundColor = UIColor.brown
        imageButton.tintColor = UIColor.white
        imageButton.setTitle("Image", for: .normal)
        imageButton.addTarget(self, action: #selector(didTapImageButton(sender:)), for: .touchUpInside)
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
