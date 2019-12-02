//
//  ViewController.swift
//  ARProject1
//
//  Created by Sean Cavalieri on 11/21/19.
//  Copyright © 2019 SeanCoding. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var time = 0.0
    var rootPosition: SCNVector3? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //start recognizing tap gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        //add longTap detection for deleting
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongTap(_:)))
        longTapGesture.allowableMovement = 5
        sceneView.addGestureRecognizer(longTapGesture)
        
    }
    //didTap function for when gestures are regonized byU ITapGestureRecognizer above
    @objc
    func didTap(_ gesture: UITapGestureRecognizer) {
        
        let sceneViewTappedOn = gesture.view as! ARSCNView
        let touchCoordinates = gesture.location(in: sceneViewTappedOn)
        
        //check for pressed cube
        let hitTestResult = sceneView.hitTest(touchCoordinates, options: nil)
        
        
        if !(hitTestResult.first?.node.geometry?.description.contains("SCNBox") ?? false) {
            
            
            //if no cube pressed and none are placed already, look for surface for new anchor block
            let hitTest = sceneViewTappedOn.hitTest(touchCoordinates, types: .existingPlaneUsingExtent)
            

            guard !hitTest.isEmpty, let hitTestResult = hitTest.first else {
                return
            }
            //vector for 3D position of tap ( to know where to put object)
            var position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
                                      hitTestResult.worldTransform.columns.3.y,
                                      hitTestResult.worldTransform.columns.3.z)
            
            //if a node has been placed, make new nodes conform to lattice positioning system already set
            if(rootPosition != nil){
                //UNWRAP optional vector: rootPosition
                let rPos = rootPosition!
                //MOVE X into coordinate latice
                let Xoffset = position.x - rPos.x
                let diffX = Xoffset.truncatingRemainder(dividingBy: 0.1)
                //use diff and offset to move position to nearest latice point
                position.x -= diffX
                //MOVE Y into coordinate latice
                let Yoffset = position.y - rPos.y
                let diffY = Yoffset.truncatingRemainder(dividingBy: 0.1)
                //use diff and offset to move position to nearest latice point
                position.y -= diffY
                //MOVE Z into coordinate latice
                let Zoffset = position.z - rPos.z
                let diffZ = Zoffset.truncatingRemainder(dividingBy: 0.1)
                //use diff and offset to move position to nearest latice point
                position.z -= diffZ
            } else {
                rootPosition = position
            }
                
            //call method to add item
            addItemToPosition(position)
            return
        }
        
        //ADDS CUBE ADJACENT TO FACE OF PRESSED BLOCK
        
//      get description of which box face based off of faceIndex's of a cube
        enum BoxFace: Int{
        case Front = 0, Right = 2, Back = 4, Left = 6, Top = 8, Bottom = 10
        }
        
        if let faceIndex = BoxFace(rawValue: hitTestResult.first?.faceIndex ?? -1){
            //faceIndex now equals one of the values of the enum BoxFace above
            var position = hitTestResult.first?.node.position
            switch faceIndex{
                case .Front: position?.z += 0.1
                case .Right: position?.x += 0.1
                case .Back: position?.z -= 0.1
                case .Left: position?.x -= 0.1
                case .Top: position?.y += 0.1
                case .Bottom: position?.y -= 0.1
            }
            addItemToPosition(position!)
        }
    
    }
    //put objects into the scene
    func addItemToPosition(_ position: SCNVector3) {
        
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/brick.png")
        box.materials = [material]
        
        let node = SCNNode(geometry: box)
        node.position = position
        self.sceneView.scene.rootNode.addChildNode(node)
        
    }
    //delete SCNNode longPressed on
    @objc
    func didLongTap(_ gesture: UILongPressGestureRecognizer) {
        
        if(NSDate().timeIntervalSince1970 - 0.25 > time){
            time = NSDate().timeIntervalSince1970
            
            let sceneViewTappedOn = gesture.view as! ARSCNView
            let touchCoordinates = gesture.location(in: sceneViewTappedOn)
            let hitTestResult = sceneView.hitTest(touchCoordinates, options: nil)
            
            guard let node = hitTestResult.first?.node else { return }
            
            node.removeFromParentNode()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //Enable detection of horizontal planes
        configuration.planeDetection = .horizontal
        
        //Show feature points - CAN TURN ON FOR TESTING
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    //show horizontal planes found
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.75)

            let planeNode = SCNNode(geometry: plane)
            planeNode.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.x, planeAnchor.center.z)
            planeNode.eulerAngles.x = -.pi / 2
            
            node.addChildNode(planeNode)
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
}
