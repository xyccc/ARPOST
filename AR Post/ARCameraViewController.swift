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

class ARCameraViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var isAdding = false
//    var isPainting = false {
//        didSet {
//            if isPainting {
//
//            } else {
//
//            }
//        }
//    }
    var isPainting = false;
    var textButton = UIButton()
    var paintButton = UIButton()
    var imageButton = UIButton()
    
    
    @IBOutlet var sceneView: ARSCNView!
    let vertBrush = VertBrush()
    var buttonDown = false
    var addPointButton : UIButton!
    var frameIdx = 0
    var splitLine = false
    var lineRadius : Float = 0.001
    var metalLayer: CAMetalLayer! = nil
    var hasSetupPipeline = false
    
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
    
    @objc func didTapTextButton(sender: UIButton!) {
        print("add sticky notes")
    }
    @objc func didTapPaintButton(sender: UIButton!) {
        isPainting = !isPainting
        if (isPainting) {
            print("start painting")
        } else {
            print("end painting")
        }
    }
    @objc func didTapImageButton(sender: UIButton!) {
        print("insert image")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController()
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose from Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.view.addSubview(actionSheet)
        self.present(actionSheet, animated: true, completion: nil)
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("convert to image success")
            let imageMaterial = SCNMaterial()
            imageMaterial.isDoubleSided = false
            imageMaterial.diffuse.contents = image
            let cube: SCNGeometry? = SCNBox(width: 1.0, height: 1.0, length: 1, chamferRadius: 0)
            let node = SCNNode(geometry: cube)
            node.geometry?.materials = [imageMaterial]
        }
        
        picker.dismiss(animated: true, completion: nil)
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
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        metalLayer = self.sceneView.layer as! CAMetalLayer
    

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
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.minimumPressDuration = 0
        tap.cancelsTouchesInView = false
        tap.delegate = self
        self.sceneView.addGestureRecognizer(tap)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
    
    // called by gesture recognizer
    @objc func tapHandler(gesture: UITapGestureRecognizer) {

        // handle touch down and touch up events separately
        if gesture.state == .began {
            // do something...
            buttonTouchDown()
        } else if gesture.state == .ended { // optional for touch up event catching
            // do something else...
            buttonTouchUp()
        }
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
    
    @objc func clearDrawing() {
        vertBrush.clear()
    }
    
    @objc func buttonTouchDown() {
        splitLine = true
        buttonDown = true
    }
    @objc func buttonTouchUp() {
        buttonDown = false
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if (isPainting) {
            if ( buttonDown ) {
                
                let pointer = getPointerPosition()
                if ( pointer.valid ) {
                    
                    if ( vertBrush.points.count == 0 || (vertBrush.points.last! - pointer.pos).length() > 0.001 ) {
                        
                        var radius : Float = 0.001
                        
                        
                        if ( splitLine || vertBrush.points.count < 2 ) {
                            lineRadius = 0.001
                        } else {
                            
                            let i = vertBrush.points.count-1
                            let p1 = vertBrush.points[i]
                            let p2 = vertBrush.points[i-1]
                            
                            radius = 0.001 + min(0.015, 0.005 * pow( ( p2-p1 ).length() / 0.005, 2))
                            
                        }
                        
                        lineRadius = lineRadius - (lineRadius - radius)*0.075
                        vertBrush.addPoint(pointer.pos, radius: lineRadius, splitLine:splitLine)
                        
                        if ( splitLine ) { splitLine = false }
                        
                    }
                    
                }
                
            }
            
            
            if ( frameIdx % 100 == 0 ) {
                print(vertBrush.points.count, " points")
            }
            
            frameIdx = frameIdx + 1
            
            //if ( frameIdx % 2 == 0 ) {
            vertBrush.updateBuffers()
            //}
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        if ( !hasSetupPipeline ) {
            // pixelFormat is different if called at viewWillAppear
            hasSetupPipeline = true
            vertBrush.setupPipeline(device: sceneView.device!, pixelFormat: self.metalLayer.pixelFormat )
        }
        
        if let commandQueue = self.sceneView?.commandQueue {
            if let encoder = self.sceneView.currentRenderCommandEncoder {
                
                let projMat = float4x4.init((self.sceneView.pointOfView?.camera?.projectionTransform)!)
                let modelViewMat = float4x4.init((self.sceneView.pointOfView?.worldTransform)!).inverse
                
                vertBrush.render(commandQueue, encoder, parentModelViewMatrix: modelViewMat, projectionMatrix: projMat)
                
            }
        }
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func getPointerPosition() -> (pos : SCNVector3, valid: Bool, camPos : SCNVector3 ) {
        
        guard let pointOfView = sceneView.pointOfView else { return (SCNVector3Zero, false, SCNVector3Zero) }
        guard let currentFrame = sceneView.session.currentFrame else { return (SCNVector3Zero, false, SCNVector3Zero) }
        
        let mat = SCNMatrix4.init(currentFrame.camera.transform)
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        
        let currentPosition = pointOfView.position + (dir * 0.12)
        
        return (currentPosition, true, pointOfView.position)
        
    }
}
