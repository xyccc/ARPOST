//
//  ViewController.swift
//  EditWorld
//
//  Created by Student User on 5/21/18.
//  Copyright © 2018 EditWorld. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import SpriteKit


class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    let session = ARSession()
    let defaults = UserDefaults.standard
    let config = ARWorldTrackingConfiguration()
    
    var textNode:SCNNode?
    var textSize:CGFloat = 5
    var textDistance:Float = 15
    private var drawingNodes = [DynamicGeometryNode]()
    var previousPoint: SCNVector3?
    //let vecBrush = VecBrush()
    var addPointButton : UIButton!
    var frameIdx = 0
    var splitLine = false
    var lineRadius : Float = 0.001
    var isDrawing = false
    
    /*
    var infoButton:UIButton = {
        let image = UIImage(named: "information.png") as? UIImage?
        let btn = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        btn.center = CGPoint(x: UIScreen.main.bounds.width * 0.75, y: UIScreen.main.bounds.height * 0.12)
        btn.setImage(image!, for: .normal)
        btn.alpha = 0.8
        return btn
    }()
    */
    
    var drawButton:UIButton = {
        let image = UIImage(named: "Group 1.png") as? UIImage?
        let btn = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 68, height: 68)
        btn.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height*0.88)
        btn.layer.cornerRadius = btn.bounds.height/2
        btn.setImage(image!, for: .normal)
        //btn.alpha = 0.8
        btn.tag = 0
        return btn
    }()
    
    var emojiButton:UIButton = {
        let image = UIImage(named: "Group 3.png") as? UIImage?
        let btn = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 68, height: 68)
        btn.center = CGPoint(x: UIScreen.main.bounds.width * 0.77, y: UIScreen.main.bounds.height * 0.9)
        btn.layer.cornerRadius = btn.bounds.height/2
        btn.setImage(image!, for: .normal)
        //btn.alpha = 0.8
        return btn
    }()
    
    var imageButton:UIButton = {
        let image = UIImage(named: "Group 2.png") as? UIImage?
        let btn = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 68, height: 68)
        btn.center = CGPoint(x: UIScreen.main.bounds.width * 0.23, y: UIScreen.main.bounds.height * 0.9)
        btn.layer.cornerRadius = btn.bounds.height/2
        btn.setImage(image!, for: .normal)
        //btn.alpha = 0.8
        return btn
    }()
    
    //test with random emoji
    var randoMoji:String {
        let emojis = ["👾", "🤓", "🔥", "😜", "😇", "🤣", "🤗", "🧐", "🛰", "🚀"]
        return emojis[Int(arc4random_uniform(UInt32(emojis.count)))]
    }
    
    @objc func tapEmojiButton(sender: UIButton!) {
        self.showText(text: randoMoji)
    }
    
    private func isReadyForDrawing(trackingState: ARCamera.TrackingState) -> Bool {
        switch trackingState {
        case .normal:
            return true
        default:
            return false
        }
    }
    
    @objc func tapDrawButton(sender: UIButton!) {
        guard let frame = sceneView.session.currentFrame else {return}
        guard isReadyForDrawing(trackingState: frame.camera.trackingState) else {return}
        //call lineNode function to draw
        let drawingNode = DynamicGeometryNode(color: UIColor.white, lineWidth: 0.005)
        sceneView.scene.rootNode.addChildNode(drawingNode)
        drawingNodes.append(drawingNode)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.sceneView.showsStatistics = false
        self.sceneView.session.run(config)
        self.sceneView.delegate = self
        self.view.addSubview(drawButton)
        self.view.addSubview(imageButton)
        self.view.addSubview(emojiButton)
        //self.view.addSubview(infoButton)
        
        // Add buttons' targets to handle user button selections
        drawButton.addTarget(self, action: #selector(tapDrawButton(sender:)), for: .touchUpInside)
        imageButton.addTarget(self, action: #selector(tapImageButton(sender:)), for: .touchUpInside)
        emojiButton.addTarget(self, action: #selector(tapEmojiButton(sender:)), for: .touchUpInside)
        //infoButton.addTarget(self, action: #selector(tapInfoButton(sender:)), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.pause()
    }
    
    func setupScene() {
        sceneView.delegate = self
        sceneView.session = session
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = false
        
        sceneView.preferredFramesPerSecond = 60
        sceneView.contentScaleFactor = 1.3
        
        enableEnvironmentMapWithIntensity(25.0)
        
        DispatchQueue.main.async {
            //center the view
        }
        
        if let camera = sceneView.pointOfView?.camera {
            camera.wantsHDR = true
        }
        
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    private func worldPositionForScreenCenter() -> SCNVector3 {
        let screenBounds = UIScreen.main.bounds
        let center = CGPoint(x: screenBounds.midX, y: screenBounds.midY)
        let centerVec3 = SCNVector3Make(Float(center.x), Float(center.y), 0.99)
        return sceneView.unprojectPoint(centerVec3)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        //guard let pointOfView = sceneView.pointOfView else {return}
        guard let currentDrawing = drawingNodes.last else {return}
        
        /* get
         let transform = pointOfView.transform
         let cameraOrientation = SCNVector3(-0.02 * transform.m31, -0.02 * transform.m32, -0.02 * transform.m33)
         let cameraLocation = SCNVector3(transform.m41, transform.m42, transform.m43)
         let cameraCurrentPosition = cameraOrientation + cameraLocation
         */
        
        DispatchQueue.main.async(execute: {
            if self.drawButton.isHighlighted {
                let vertice = self.worldPositionForScreenCenter()
                currentDrawing.addVertice(vertice)
            }
        })
        
         /*
         // draw cubes
         let t2 = pointOfView.transform
         let direction = SCNVector3(-0.02 * t2.m31, -0.02 * t2.m32, -0.02 * t2.m33)
         let currentPosition = pointOfView.position + direction
         
         
         if self.draw.isHighlighted {
         if let previousPoint = previousPoint {
         let line = drawLine(vector: previousPoint, toVector: currentPosition)
         let lineNode = SCNNode(geometry: line)
         lineNode.geometry?.firstMaterial?.diffuse.contents = generateRandomColor()
         sceneView.scene.rootNode.addChildNode(lineNode)
         }
         }
         previousPoint = currentPosition
         */
        
        /*
         DispatchQueue.main.async {
         
         if self.drawButton.isHighlighted{
         let box = SCNNode(geometry: SCNBox(width: 0.006, height: 0.006, length: 0.006, chamferRadius: 0))
         box.position = cameraCurrentPosition
         self.sceneView.scene.rootNode.addChildNode(box)
         box.geometry?.firstMaterial?.diffuse.contents = UIColor.white
         print("Draw Button is Pressed")
         } else {
         let pointer = SCNNode(geometry: SCNSphere(radius: 0.00025))
         pointer.name = "center"
         pointer.position = cameraCurrentPosition
         self.sceneView.scene.rootNode.enumerateChildNodes({(node,_) in
         if node.name == "center"{
         node.removeFromParentNode()
         }
         })
         
         self.sceneView.scene.rootNode.addChildNode(pointer)
         pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
         }
         }
         */
    }
    
    @objc func tapImageButton(sender: UIButton!) {
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
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("convert to image success")
            
            let box = SCNBox(width: image.size.width / 40000, height: image.size.height / 40000, length: 0.0001, chamferRadius: 0.000)
            let imageMaterial = SCNMaterial()
            imageMaterial.isDoubleSided = false
            imageMaterial.diffuse.contents = image
            box.materials = [imageMaterial]
            
            let boxNode = SCNNode(geometry: box)
            //boxNode.rotation = SCNVector4(Double.pi / 2 , 1, 0, 0)
            boxNode.position = getPointerPosition().pos
            sceneView.scene.rootNode.addChildNode(boxNode)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func getPointerPosition() -> (pos : SCNVector3, valid: Bool, camPos : SCNVector3 ) {
        
        guard let pointOfView = sceneView.pointOfView else { return (SCNVector3Zero, false, SCNVector3Zero) }
        
        // Transform Matrix
        let transform = pointOfView.transform
        let cameraOrientation = SCNVector3(-0.02 * transform.m31, -0.02 * transform.m32, -0.02 * transform.m33)
        let cameraLocation = SCNVector3(transform.m41, transform.m42, transform.m43)
        let cameraCurrentPosition = cameraOrientation + cameraLocation
        
        return (cameraCurrentPosition, true, cameraOrientation)
        
    }
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        let labelNode = SKLabelNode(text: randoMoji)
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        return labelNode;
    }
    
    func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
        if sceneView.scene.lightingEnvironment.contents == nil {
            if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
                sceneView.scene.lightingEnvironment.contents = environmentMap
            }
        }
        sceneView.scene.lightingEnvironment.intensity = intensity
    }
    
    func showText(text:String) -> Void{
        let textScn = ARText(text: text, font: UIFont .systemFont(ofSize: 20), depth: 2)
        let textNode = TextNode(distance: textDistance/10, scntext: textScn, sceneView: self.sceneView, scale: 1/100.0)
        self.sceneView.scene.rootNode.addChildNode(textNode)
    }
}

func generateRandomColor() -> UIColor {
    let hue : CGFloat = CGFloat(arc4random() % 256) / 256
    let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5
    let brightness : CGFloat = CGFloat(arc4random() & 128) / 256 + 0.5
    
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
}

func drawLine(vector v1: SCNVector3, toVector v2: SCNVector3) -> SCNGeometry {
    
    let indices: [Int32] = [0, 1]
    
    let source = SCNGeometrySource(vertices: [v1, v2])
    let element = SCNGeometryElement(indices: indices, primitiveType: .line)
    
    return SCNGeometry(sources: [source], elements: [element])
    
}
/*
func +(left:SCNVector3,right:SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
*/

