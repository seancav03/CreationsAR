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
    
    let chars64: [Character] = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "+", "/"]
    
    //array of all available textures
    let textures: [String] = ["art.scnassets/brick.png", "art.scnassets/RedPaint.png", "art.scnassets/GreenPaint.png", "art.scnassets/BluePaint.png"]
    var selectedTexture: Int = 0
    
    @IBOutlet weak var currentBlock: UIImageView!
    
    
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
        
        //add right swipe detection for changing block material to the right
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight(_:)))
        sceneView.addGestureRecognizer(swipeGestureRight)
        
        //add left swipe detection for changing block material to the left
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft(_:)))
        swipeGestureLeft.direction = UISwipeGestureRecognizer.Direction.left
        sceneView.addGestureRecognizer(swipeGestureLeft)
        
        //Current Block Desplay
        currentBlock.image = UIImage(named: textures[selectedTexture])
        
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
                let diffX = Xoffset.truncatingRemainder(dividingBy: edgeLength)
                //use diff and offset to move position to nearest latice point
                position.x -= diffX
                //round if closer to the father latice point
                if(abs(diffX) > edgeLength/2){
                    if(diffX < 0){
                        position.x -= edgeLength
                    } else {
                        position.x += edgeLength
                    }
                }
                //MOVE Y into coordinate latice
                let Yoffset = position.y - rPos.y
                let diffY = Yoffset.truncatingRemainder(dividingBy: edgeLength)
                //use diff and offset to move position to nearest latice point
                position.y -= diffY
                //round if closer to the father latice point
                if(abs(diffY) > edgeLength/2){
                    if(diffY < 0){
                        position.y -= edgeLength
                    } else {
                        position.y += edgeLength
                    }
                }
                //MOVE Z into coordinate latice
                let Zoffset = position.z - rPos.z
                let diffZ = Zoffset.truncatingRemainder(dividingBy: edgeLength)
                //use diff and offset to move position to nearest latice point
                position.z -= diffZ
                //round if closer to the father latice point
                if(abs(diffZ) > edgeLength/2){
                    if(diffZ < 0){
                        position.z -= edgeLength
                    } else {
                        position.z += edgeLength
                    }
                }
                //STORE position in String
                let storeStr: String = getStringOfPosition(position)
                var checkerString2: String = getStringOfPosition(position)
                checkerString2.removeLast()
                if(storeStr != "ERROR: OUT OF RANGE" && !containsInFrame(design: currentDesign, subStr: checkerString2)){
                    currentDesign += storeStr
                } else {
//                    if(currentDesign.contains(storeStr)){
//                        print("In a block: " + storeStr)
//                    } else {
//                        print("Error: OUT OF RANGE")
//                    }
                    return
                }
            } else {
                rootPosition = position
                
                currentDesign += "YYY0"
            }
                
            //call method to add item
            addItemToPosition(position: position, texture: selectedTexture)
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
            var checkerString: String = getStringOfPosition(position!)
            checkerString.removeLast()
            if(!containsInFrame(design: currentDesign, subStr: checkerString)){
                if(storeNewCubePosition(position!)){
                    addItemToPosition(position: position!, texture: selectedTexture)
                }
            } else {
//                print("In Block (adding on face): " + getStringOfPosition(position!))
            }
        }
    
    }
    //put objects into the scene
    func addItemToPosition(position: SCNVector3, texture: Int) {
        
        let box = SCNBox(width: CGFloat(edgeLength), height: CGFloat(edgeLength), length: CGFloat(edgeLength), chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: textures[texture])
        box.materials = [material]
        
        let node = SCNNode(geometry: box)
        node.position = position
        self.sceneView.scene.rootNode.addChildNode(node)
            
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
//            print("Cube out of range: (x/y/z)")
//            print(intX)
//            print(intY)
//            print(intZ)
            return "ERROR: OUT OF RANGE"
        }
        //convert to String with base64 string characters
        var str: String = ""
        str += String(chars64[intX])
        str += String(chars64[intY])
        str += String(chars64[intZ])
        str += String(selectedTexture)
        return str
    }
    //finds if the design string contains the subStr in a 4 character frame
    func containsInFrame(design: String, subStr: String) -> Bool {
        var contains: Bool = false
        var i = 0
        var sub: String = ""
        for char in design {
            sub += String(char)
            if(i % 4 == 3) {
                if(sub == subStr){
                    contains = true
                    break
                }
                sub.removeLast()
                if(sub == subStr){
                    contains = true
                    break
                }
                sub.removeAll()
            }
            i+=1
        }
        return contains
    }
    //finds if the design string contains the subStr in a 4 character frame, and removes all occurences
    func removeInFrame(design: String, subStr: String) -> String {
        var newString: String = ""
        var i = 0
        var sub: String = ""
        for char in design {
            sub += String(char)
            newString += String(char)
            if(i % 4 == 3) {
                sub.removeLast()
                if(sub == subStr){
                    //remove that chunk of four
                    newString.removeLast()
                    newString.removeLast()
                    newString.removeLast()
                    newString.removeLast()
                }
                sub.removeAll()
            }
            i+=1
        }
        return newString
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
            
            //check if box if being deleted
            if(node.description.contains("SCNBox")){
                //remove node from string storage
                let position: SCNVector3 = node.position
                var str: String = getStringOfPosition(position)
                str.removeLast()
                //remove all occurences (within 4 char frame)
                currentDesign = removeInFrame(design: currentDesign, subStr: str)
                
            }
            
            node.removeFromParentNode()
        }
        
    }
    @objc
    func didSwipeRight(_ gesture: UISwipeGestureRecognizer) {
//        print("Swiped Left")
        if(selectedTexture != textures.count - 1){
            selectedTexture += 1;
            //update image
            currentBlock.image = UIImage(named: textures[selectedTexture])
        }
    }
    @objc
    func didSwipeLeft(_ gesture: UISwipeGestureRecognizer) {
//        print("Swiped Right")
        if(selectedTexture != 0){
            selectedTexture -= 1;
            //update image
            currentBlock.image = UIImage(named: textures[selectedTexture])
        }
    }
    //build creations from String
    func loadCreationFromString(design: String, rPos: SCNVector3){
//        print("Loading")
        var four: [Int] = [ 0, 0, 0, 0]
        var cntr: Int = 0
        for char in design {
            for i in 0..<chars64.count {
                if(char == chars64[i]){
                    four[cntr] = i
//                    print("Mod: ", cntr, ", " , i)
                    break
                }
            }
            if(cntr == 3){
//                print("Placing at: ")
//                print(rPos.x, " ", rPos.y, " ", rPos.z)
                //str hold the 4 char string. Convert to position
                let posX: Float = rPos.x + Float(four[0]-31)*edgeLength
                let posY: Float = rPos.y + Float(four[1]-31)*edgeLength
                let posZ: Float = rPos.z + Float(four[2]-31)*edgeLength
//                print("x/y/z: ", String(posX), ", ", String(posY), ", ", String(posZ))
                let material = four[3]
//                print("material", material)
                let vexy: SCNVector3 = SCNVector3(CGFloat(posX), CGFloat(posY), CGFloat(posZ))
                //Try to add item to space
                addItemToPosition(position: vexy, texture: material)
                cntr = 0
            } else {
                cntr+=1
            }
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
