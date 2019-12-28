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
    
    @IBOutlet weak var loadModel: UIImageView!
    @IBOutlet weak var saveModel: UIImageView!
    @IBOutlet weak var clearSpace: UIImageView!
    
    //for presenting view to select saved designs (and removing that view)
    var table: MenuViewController?
    
    
    var time = 0.0
    let edgeLength: Float = 0.04
    var rootPosition: SCNVector3? = nil
    let texturesPerCategory = 8
    
    var currentDesign: String = ""
    
    let chars64: [Character] = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "+", "/"]
    
    //array of all available textures
    let textures: [String] = [ "art.scnassets/RedPaint.png", "art.scnassets/OrangePaint.png", "art.scnassets/YellowPaint.png", "art.scnassets/GreenPaint.png", "art.scnassets/BluePaint.png", "art.scnassets/PurplePaint.png", "art.scnassets/WhitePaint.png", "art.scnassets/BlackPaint.png", "art.scnassets/brick.png", "art.scnassets/WhiteBrick.png", "art.scnassets/Concrete.png", "art.scnassets/stone.png", "art.scnassets/mosaicStone.png", "art.scnassets/SmoothStone.png", "art.scnassets/Gravel.png", "art.scnassets/Sand.png", "art.scnassets/NiceWood.png", "art.scnassets/WoodBoards.png", "art.scnassets/BarnWood.png", "art.scnassets/WeatheredWood.png", "art.scnassets/DarkWood.png", "art.scnassets/GreyWood.png", "art.scnassets/wood.png", "art.scnassets/SmoothWood.png"]
    var selectedTexture: Int = 0
    var designToPlace = ""
    
    @IBOutlet weak var currentBlock: UIImageView!
    @IBOutlet weak var textureBelow: UIImageView!
    @IBOutlet weak var textureRight: UIImageView!
    @IBOutlet weak var textureAbove: UIImageView!
    @IBOutlet weak var textureLeft: UIImageView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //lighting stuff
//        sceneView.autoenablesDefaultLighting = false;
        
    //Tap Gestures:
        //start recognizing tap gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        //add longTap detection for deleting
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongTap(_:)))
        longTapGesture.allowableMovement = 5
        sceneView.addGestureRecognizer(longTapGesture)
        
    //Swiping to change textures:
        //add right swipe detection for changing block material to the right
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight(_:)))
        sceneView.addGestureRecognizer(swipeGestureRight)
        
        //add left swipe detection for changing block material to the left
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft(_:)))
        swipeGestureLeft.direction = UISwipeGestureRecognizer.Direction.left
        sceneView.addGestureRecognizer(swipeGestureLeft)
        
        //add up swipe detection for changing block material set up
        let swipeGestureUp = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeUp(_:)))
        swipeGestureUp.direction = UISwipeGestureRecognizer.Direction.up
        sceneView.addGestureRecognizer(swipeGestureUp)
        
        //add down swipe detection for changing block material set down
        let swipeGestureDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeDown(_:)))
        swipeGestureDown.direction = UISwipeGestureRecognizer.Direction.down
        sceneView.addGestureRecognizer(swipeGestureDown)
        
    //Texture of Blocks Desplay
        //current block
        currentBlock.image = UIImage(named: textures[selectedTexture])
        currentBlock.isUserInteractionEnabled = true
        //surrounding textures
        textureBelow.isUserInteractionEnabled = true
        textureRight.isUserInteractionEnabled = true
        textureAbove.isUserInteractionEnabled = true
        textureLeft.isUserInteractionEnabled = true
        let changeTextureDownRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeTextureDown(_:)))
        let changeTextureUpRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeTextureUp(_:)))
        let changeTextureRightRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeTextureRight(_:)))
        let changeTextureLeftRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeTextureLeft(_:)))
        textureBelow.addGestureRecognizer(changeTextureDownRecognizer)
        textureAbove.addGestureRecognizer(changeTextureUpRecognizer)
        textureRight.addGestureRecognizer(changeTextureRightRecognizer)
        textureLeft.addGestureRecognizer(changeTextureLeftRecognizer)
        showTextures()
        
        
    //set up buttons
        let loadNModelRecognizer = UITapGestureRecognizer(target: self, action: #selector(loadNewModel(_:)))
        loadModel.isUserInteractionEnabled = true
        loadModel.addGestureRecognizer(loadNModelRecognizer)
        let saveThisCreationRecognizer = UITapGestureRecognizer(target: self, action: #selector(saveThatModel(_:)))
        saveModel.isUserInteractionEnabled = true
        saveModel.addGestureRecognizer(saveThisCreationRecognizer)
        let clearSpaceRecognizer = UITapGestureRecognizer(target: self, action: #selector(clearTheSpace(_:)))
        clearSpace.isUserInteractionEnabled = true
        clearSpace.addGestureRecognizer(clearSpaceRecognizer)
        
    }
    //change texture to texture in category below
    @objc
    func changeTextureDown(_ gesture: UITapGestureRecognizer){
        if(selectedTexture - texturesPerCategory >= 0 && designToPlace == ""){
            selectedTexture -= texturesPerCategory
            //adjust images shown
            showTextures()
        }
    }
    //change texture to texture in category above
    @objc
    func changeTextureUp(_ gesture: UITapGestureRecognizer){
        if(selectedTexture + texturesPerCategory < textures.count && designToPlace == ""){
            selectedTexture += texturesPerCategory
            //adjust images shown
            showTextures()
        }
    }
    //change texture to texture to right
    @objc
    func changeTextureRight(_ gesture: UITapGestureRecognizer){
        if(selectedTexture + 1 < textures.count && designToPlace == ""){
            selectedTexture += 1
            //adjust images shown
            showTextures()
        }
    }
    //change texture to texture to left
    @objc
    func changeTextureLeft(_ gesture: UITapGestureRecognizer){
        if(selectedTexture - 1 >= 0 && designToPlace == ""){
            selectedTexture -= 1
            //adjust images shown
            showTextures()
        }
    }
    //set all block images based on new selected index
    func showTextures(){
        currentBlock.image = UIImage(named: textures[selectedTexture])
        //above
        if(selectedTexture + texturesPerCategory < textures.count){
            textureAbove.image = UIImage(named: textures[selectedTexture + texturesPerCategory])
        } else {
            textureAbove.image = nil
        }
        //below
        if(selectedTexture - texturesPerCategory >= 0){
            textureBelow.image = UIImage(named: textures[selectedTexture - texturesPerCategory])
        } else {
            textureBelow.image = nil
        }
        //right
        if(selectedTexture + 1 < textures.count){
            textureRight.image = UIImage(named: textures[selectedTexture + 1])
        } else {
            textureRight.image = nil
        }
        //left
        if(selectedTexture - 1 >= 0){
            textureLeft.image = UIImage(named: textures[selectedTexture - 1])
        } else {
            textureLeft.image = nil
        }
    }
    
    //button configuration
    @objc
    func loadNewModel(_ gesture: UITapGestureRecognizer) {
        //open table view here
        table = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
        //prepare
        table?.theDelegate = self
        
        //transition
        self.present(table!, animated: true, completion: nil)
    }
    //model returned
    func innerDesignSelected(design: String, folder: String) {
        print("The Current Design is empty: ", Bool(design == ""))
        //design is now the String for the returned design
//        print("Design Received: " + design)
//        print("At Folder: \(folder)")
        //reading the file of name 'design' in 'folder'
        do {
            let contents = try String(contentsOfFile: FileManager.documentDirectoryURL.appendingPathComponent(folder).appendingPathComponent(design + ".txt").path)
//            print("Contents of File: " + contents)
            designToPlace = contents
            } catch {
                //failed to read from file
//                print("Failed to read from file:")
//                print("ERROR: \(error)")
            }
        currentBlock.image = UIImage(named: "art.scnassets/plus.png")
        //Ask to save, then clear the prior design from the workspace
            //first, dismiss table view so alert asking to save can be displayed
        table?.dismiss(animated: true, completion: nil)
        actuallyClearTheSpace()
    }
    @objc
    func clearTheSpace(_ gesture: UITapGestureRecognizer) {
        //call helper function to clear the workspace
        actuallyClearTheSpace()
    }
    //actually clears the space
    func actuallyClearTheSpace() {
        print("cur Des: \(currentDesign)")
        if currentDesign != "" {
            //set up Alert to ask user if they want to save the design
            let askSave = UIAlertController(title: "Save Design?", message: "Press 'Save' to Save. Otherwise, data will be lost", preferredStyle: UIAlertController.Style.alert)
            askSave.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction!) in
                    //Code here is for if user presses save. Clear after
                    self.save(clearAfter: true)
              }))
            askSave.addAction(UIAlertAction(title: "Don't Save", style: .cancel, handler: { (action: UIAlertAction!) in
                    //Code here is for if user wants to not save design. Just clear the space
                    self.clearMyWorkspace()
              }))

            present(askSave, animated: true, completion: nil)
        } else {
            //merely clear the root position. No design placed
            rootPosition = nil
        }
    }
    //helper function clears workspace
    func clearMyWorkspace(){
        //clear previous designs
        for childNode in sceneView.scene.rootNode.childNodes {
            if ((childNode.geometry?.description.contains("SCNBox")) ?? false) {
                childNode.removeFromParentNode()
            }
        }
        //delete root to be reset at placing
        rootPosition = nil
        currentDesign = ""
    }
    @objc
    func saveThatModel(_ gesture: UITapGestureRecognizer) {
        //call function below to save when button is pressed
        save(clearAfter: false)
    }
    //Save model
    func save(clearAfter shouldClearWorkspaceAfter: Bool){
        //ask for name to save under
                if(currentDesign != ""){
                    let alert = UIAlertController(title: "Saving", message: "Enter Design Name", preferredStyle: .alert)
                        alert.addTextField { (textField) in
                            textField.placeholder = "Type here"
                        }

                        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
                            guard let textField = alert?.textFields?[0], let userText = textField.text else { return }
                            //here there is user inputted text
        //                    print("Inputted Name: ", userText)
                            if(userText != ""){
                                var name = userText
                                //remove all unsafe url characters
                                let unsafeURLCharacters = ["/", ":", ";", "|"]
                                //Safeing url
                                name.removeAll(where: { unsafeURLCharacters.contains(String($0)) })
        //                        print("Safe Name: ", name)
                                if(name == ""){
                                    //alert if removing safe characters brought name to an empty string
                                    let alert2 = UIAlertController(title: "Unsafe Name", message: "Try using more standard characters in name", preferredStyle: .alert)
                                    let OK2 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
        //                                print("Pressed OK 2")
                                    }
                                    alert2.addAction(OK2)
                                    self.present(alert2, animated: true, completion: nil)
                                    //abort saving
                                    return
                                }
                                
                                //get all filenames already taken
                                var arrayOfFileNames: [String] = []
                                do {
                                    let items = try FileManager.default.contentsOfDirectory(at: FileManager.documentDirectoryURL.appendingPathComponent("My Designs"), includingPropertiesForKeys: nil)
        //                            print("Listing Files: ")
                                    for item in items {
        //                                print("Found: ", item)
                                        let shorterArr = item.path.split(separator: "/")
                                        var shorter = shorterArr.last!
        //                                print("Shorter: ", shorter)
                                        shorter.removeLast(4)
                                        arrayOfFileNames.append(String(shorter))
                                    }
                                } catch {
                                    // failed to read directory – bad permissions, perhaps?
        //                            print("2- Failed to read File name in Directory: ")
        //                            print("Error info: \(error)")
                                }
        //                        print("Array of File names: ", arrayOfFileNames)

                                //fix duplicates
                                let holder = name
                                var i = 1
                                while arrayOfFileNames.contains(name) {
                                    name = holder
                                    name += "("
                                    name += String(i)
                                    name += ")"
                                    i += 1
                                }
        //                        print("Unique Name: ", name)
                                //name is now unique
                                
                                //check if local folder has been created, if not create it
                                let folderPath = FileManager.documentDirectoryURL.appendingPathComponent("My Designs")
                                let folderExists = (try? folderPath.checkResourceIsReachable()) ?? false
                                if !folderExists {
                                    do {
                                        try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: false)
        //                                print("Created My Designs Directory")
                                    } catch {
                                        //failed to create Directory
        //                                print("Failed to create My Designs directory")
                                        //abort
                                        return
                                    }
                                }
                                
                                //STORE currentDesign to file in My Designs
                                let filename = FileManager.documentDirectoryURL.appendingPathComponent("My Designs").appendingPathComponent(name + ".txt")
                                //attempt to make and write to file
                                do {
                                    try self.currentDesign.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                                    if(shouldClearWorkspaceAfter){
                                        //delete design now if requested
                                        self.clearMyWorkspace()
                                    }
                                } catch {
                                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        //                            print("Failed to write to file")
                                    //show user the failure
                                    let alert = UIAlertController(title: "Save Failed", message: "Try again with a different name", preferredStyle: .alert)
                                    let OK = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
        //                                print("Pressed OK")
                                    }
                                    alert.addAction(OK)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }))

                    self.present(alert, animated: true, completion: nil)
                }
    }
    //receive file of model from another app
    func incomingDesignURL(url: URL){
        //File path is here: (e.g. file:///private/var/mobile/Containers/Data/Application/340448CA-7E9F-4B19-92DE-7F99EF11DAA8/Documents/Inbox/stairs-7.txt)
        do {
//            print("PATH: \(url.path)")
            let theDesign = try String(contentsOfFile: url.path)
//            print("Contents of File: \(theDesign)")
            
            //Check for Shared Designs folder, or create it
            let folderPath = FileManager.documentDirectoryURL.appendingPathComponent("Shared Designs")
            let folderExists = (try? folderPath.checkResourceIsReachable()) ?? false
            if !folderExists {
                do {
                    try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: false)
//                    print("Created Shared Designs Directory")
                } catch {
                    //failed to create Directory
//                    print("Failed to create Shared Designs directory")
                    //abort
                    return
                }
            }
            //check for available name for file (so nothing is overwriten)
            //  get all filenames already taken
            var arrayOfFileNames: [String] = []
            do {
                let items = try FileManager.default.contentsOfDirectory(at: FileManager.documentDirectoryURL.appendingPathComponent("Shared Designs"), includingPropertiesForKeys: nil)
//                print("Listing Files: ")
                for item in items {
//                    print("Found: ", item)
                    let shorterArr = item.path.split(separator: "/")
                    var shorter = shorterArr.last!
//                    print("Shorter: ", shorter)
                    shorter.removeLast(4)
                    arrayOfFileNames.append(String(shorter))
                }
            } catch {
                // failed to read directory – bad permissions, perhaps?
//                print("2- Failed to read File name in Directory: ")
//                print("Error info: \(error)")
            }
            //fix file name so it is unique
            let fileNameArr = url.path.split(separator: "/")
            let startingName = fileNameArr.last!
            var name = String(startingName)
            name.removeLast(4)
            //  remove unsafe characters from name
            let unsafeURLCharacters = ["/", ":", ";", "|"]
            //      safeing url
            name.removeAll(where: { unsafeURLCharacters.contains(String($0)) })
            if name == "" {
                name = "shared design"
            }
            //  make name unique
            let holder = name
            var i = 1
            while arrayOfFileNames.contains(name) {
                name = holder
                name += "("
                name += String(i)
                name += ")"
                i += 1
            }
//            print("Unique Name: ", name)
            
            //Save the file to Shared Designs Folder
            let filename = FileManager.documentDirectoryURL.appendingPathComponent("Shared Designs").appendingPathComponent(name + ".txt")
            do {
                try theDesign.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                //make call to allow design to be placed
                innerDesignSelected(design: name, folder: "Shared Designs")
            } catch {
                // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
//                print("Failed to write to file")
            }
            
        } catch {
//            print("Error reading File: \(error)")
        }
        
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
                    return
                }
            } else {
                //set root
                rootPosition = position
                if(designToPlace != ""){
                    //build loaded object in area
                    loadCreationFromString(design: designToPlace, rPos: rootPosition!)
                    //Go back to normal blocks
                    currentBlock.image = UIImage(named: textures[selectedTexture])
                    //prepare for ordinary actions
                    currentDesign = designToPlace
                    designToPlace = ""
                    return
                } else {
                    currentDesign += "YYY"
                    currentDesign += String(chars64[selectedTexture])
                }
            }
                
            //call method to add item
            addItemToPosition(position: position, texture: selectedTexture)
            return
        }
        
        //ADDS CUBE ADJACENT TO FACE OF PRESSED BLOCK
        
        //get description of which box face based off of faceIndex's of a cube
        enum BoxFace: Int{
        case Front = 0, Right = 2, Back = 4, Left = 6, Top = 8, Bottom = 10
        }
        
        if let faceIndex = BoxFace(rawValue: hitTestResult.first?.faceIndex ?? -1){
            //faceIndex now equals one of the values of the enum BoxFace above
            var position = hitTestResult.first?.node.position
            switch faceIndex{
                case .Front: position?.z += edgeLength
                case .Right: position?.x += edgeLength
                case .Back: position?.z -= edgeLength
                case .Left: position?.x -= edgeLength
                case .Top: position?.y += edgeLength
                case .Bottom: position?.y -= edgeLength
            }
            //if cube is within bounds of area, add to view
            var checkerString: String = getStringOfPosition(position!)
            checkerString.removeLast()
            if(!containsInFrame(design: currentDesign, subStr: checkerString)){
                if(storeNewCubePosition(position!)){
                    addItemToPosition(position: position!, texture: selectedTexture)
                }
            } else {
                //Add print statements here for testing purposes
            }
        }
    
    }
    //put objects into the scene
    func addItemToPosition(position: SCNVector3, texture: Int) {
        //make box
        let box = SCNBox(width: CGFloat(edgeLength), height: CGFloat(edgeLength), length: CGFloat(edgeLength), chamferRadius: 0)
        //set correct material
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: textures[texture])
        box.materials = [material]
        //set node as box at position
        let node = SCNNode(geometry: box)
        node.position = position
        //lighting
//        node.castsShadow = true
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
            return "ERROR: OUT OF RANGE"
        }
        //convert to String with base64 string characters
        var str: String = ""
        str += String(chars64[intX])
        str += String(chars64[intY])
        str += String(chars64[intZ])
        str += String(chars64[selectedTexture])
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
        if(selectedTexture != 0 && designToPlace == ""){
            selectedTexture -= 1;
            //update textures
            showTextures()
        }
    }
    @objc
    func didSwipeLeft(_ gesture: UISwipeGestureRecognizer) {
        if(selectedTexture != textures.count - 1 && designToPlace == ""){
            selectedTexture += 1;
            //update textures
            showTextures()
        }
    }
    @objc
    func didSwipeUp(_ gesture: UISwipeGestureRecognizer) {
        if(selectedTexture - texturesPerCategory >= 0 && designToPlace == ""){
            selectedTexture -= texturesPerCategory;
            //update textures
            showTextures()
        }
    }
    @objc
    func didSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        if(selectedTexture + texturesPerCategory < textures.count && designToPlace == ""){
            selectedTexture += texturesPerCategory;
            //update textures
            showTextures()
        }
    }
    //build creations from String
    func loadCreationFromString(design: String, rPos: SCNVector3){
        var four: [Int] = [ 0, 0, 0, 0]
        var cntr: Int = 0
        for char in design {
            for i in 0..<chars64.count {
                if(char == chars64[i]){
                    four[cntr] = i
                    break
                }
            }
            if(cntr == 3){
                //str hold the 4 char string. Convert to position
                let posX: Float = rPos.x + Float(four[0]-31)*edgeLength
                let posY: Float = rPos.y + Float(four[1]-31)*edgeLength
                let posZ: Float = rPos.z + Float(four[2]-31)*edgeLength
                let material = four[3]
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
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

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
        
        //FOR TESTING: SHOWS DETECTED PLANES IN WORLD
//        if let planeAnchor = anchor as? ARPlaneAnchor {
//            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.5)
//
//            let planeNode = SCNNode(geometry: plane)
//            planeNode.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.x, planeAnchor.center.z)
//            planeNode.eulerAngles.x = -.pi / 2
//
//            node.addChildNode(planeNode)
//        }
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

//receive information back from the tableView view controller
extension ViewController: LoadDesignDelegate {
    //call function within to work with information
    func designSelected(design: String, folder: String) {
        innerDesignSelected(design: design, folder: folder)
    }
}
