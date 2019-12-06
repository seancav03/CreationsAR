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
    let edgeLength: Float = 0.04
    var rootPosition: SCNVector3? = nil
    
    var currentDesign: String = ""
    
    let chars64 = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "+", "/"]
    
    
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
        print(currentDesign)
        
        
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
                let diffX = Xoffset.truncatingRemainder(dividingBy: edgeLength)
                //use diff and offset to move position to nearest latice point
                position.x -= diffX
                //MOVE Y into coordinate latice
                let Yoffset = position.y - rPos.y
                let diffY = Yoffset.truncatingRemainder(dividingBy: edgeLength)
                //use diff and offset to move position to nearest latice point
                position.y -= diffY
                //MOVE Z into coordinate latice
                let Zoffset = position.z - rPos.z
                let diffZ = Zoffset.truncatingRemainder(dividingBy: edgeLength)
                //use diff and offset to move position to nearest latice point
                position.z -= diffZ
                //STORE position in String
                let storeStr: String = getStringOfPosition(position)
                if(storeStr != "ERROR: OUT OF RANGE" && !currentDesign.contains(storeStr)){
                    currentDesign += storeStr
                } else {
                    if(currentDesign.contains(storeStr)){
//                        print("In a block: " + storeStr)
                    } else {
                        print("Error: OUT OF RANGE")
                    }
                    return
                }
            } else {
                rootPosition = position
                currentDesign += "YYY0"
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
//            print("Adding to Face: ")
            //faceIndex now equals one of the values of the enum BoxFace above
            var position = hitTestResult.first?.node.position
            switch faceIndex{
                case .Front: position?.z += edgeLength
//                print("Front")
                case .Right: position?.x += edgeLength
//                print("Right")
                case .Back: position?.z -= edgeLength
//                print("Back")
                case .Left: position?.x -= edgeLength
//                print("Left")
                case .Top: position?.y += edgeLength
//                print("Top")
                case .Bottom: position?.y -= edgeLength
//                print("Bottom")
            }
            //if cube is within bounds of area, add to view
            if(!currentDesign.contains(getStringOfPosition(position!))){
                if(storeNewCubePosition(position!)){
                    addItemToPosition(position!)
                }
            } else {
//                print("In Block (adding on face): " + getStringOfPosition(position!))
            }
        }
    
    }
    //put objects into the scene
    func addItemToPosition(_ position: SCNVector3) {
        
        let box = SCNBox(width: CGFloat(edgeLength), height: CGFloat(edgeLength), length: CGFloat(edgeLength), chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/brick.png")
        box.materials = [material]
        
        let node = SCNNode(geometry: box)
        node.position = position
        self.sceneView.scene.rootNode.addChildNode(node)
        
//        print(currentDesign)
            
    }
    //find integer latice position of the new cube
    func storeNewCubePosition(_ position: SCNVector3) -> Bool {
        
        let str = getStringOfPosition(position)
        if(str != "ERROR: OUT OF RANGE"){
            //store positions with string from getStringOfPosition()
            currentDesign += str
            //done
            return true
        } else {
            //cube was out of range
            return false
        }
        
    }
    //get String representation of position
    func getStringOfPosition(_ position: SCNVector3) -> String {
        
        //UNWRAP optional vector: rootPosition
        let rPos = rootPosition! //force unwrap won't fail as it cannot be null to get to this point
        //GET relative X position
        let Xoffset = position.x - rPos.x
        //GET relative Y position
        let Yoffset = position.y - rPos.y
        //GET relative Z position
        let Zoffset = position.z - rPos.z
        //Calculate and store position in String
        //get distance
        var laticeNumX=Xoffset
        var laticeNumY=Yoffset
        var laticeNumZ=Zoffset
        //standardize units tall to integers (edge length --> 1)
        laticeNumX *= 1.0/edgeLength
        laticeNumY *= 1.0/edgeLength
        laticeNumZ *= 1.0/edgeLength
        //cast all to ints - Round them though
        var intX = Int(round(laticeNumX))
        var intY = Int(round(laticeNumY))
        var intZ = Int(round(laticeNumZ))
        //add 31 to make everything positive (-31 --> 0)
        intX += 31
        intY += 31
        intZ += 31
        if(intX < 0 || intX > 63 || intY < 0 || intY > 63 || intZ < 0 || intZ > 63){
            //don't make cube if it is outside of of the build space
            print("Cube out of range: (x/y/z)")
//            print(intX)
//            print(intY)
//            print(intZ)
            return "ERROR: OUT OF RANGE"
        }
        //convert to String with base64 string characters
        var str: String = ""
        str += chars64[intX]
        str += chars64[intY]
        str += chars64[intZ]
        str += "0"
        return str
    }
    //delete SCNNode longPressed on
    @objc
    func didLongTap(_ gesture: UILongPressGestureRecognizer) {
        
        if(/*gesture.state == UIGestureRecognizer.State.began && */NSDate().timeIntervalSince1970 - 0.25 > time){
            time = NSDate().timeIntervalSince1970
            
            let sceneViewTappedOn = gesture.view as! ARSCNView
            let touchCoordinates = gesture.location(in: sceneViewTappedOn)
            let hitTestResult = sceneView.hitTest(touchCoordinates, options: nil)
            
            guard let node = hitTestResult.first?.node else { return }
            
            //remove node from string storage
            let position: SCNVector3 = node.position
            let str: String = getStringOfPosition(position)
//            print("Str: " + str)
            if(currentDesign.contains(str)){
                currentDesign = currentDesign.replacingOccurrences(of: str, with: "")
            }
            
            node.removeFromParentNode()
        }
        
    }
    //build creations from String
    func loadCreationFromString(_ design: String){
        for char in design {
            
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
