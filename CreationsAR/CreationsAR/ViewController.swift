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
    @IBOutlet weak var modelName: UILabel!
    @IBOutlet weak var startGame: UIImageView!
    
    //for presenting view to select saved designs (and removing that view)
    var table: MenuViewController?
    
    //for presenting view to select a material (and removing that view)
    var grid: MaterialsCollectionViewController?
    
    
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
    var designToPlaceName = ""
    
    //games
    var timer = Timer()
    

    @IBOutlet weak var currentMaterial: UIButton!
    
    
    /**
     This function sets up everything graphical when the view loads
     */
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //lighting stuff
        sceneView.autoenablesDefaultLighting = false
        sceneView.automaticallyUpdatesLighting = true
//        sceneView.autoenablesDefaultLighting = true
        
        //coaching user to find a plane to place stuff, if on iOS 13
        if #available(iOS 13.0, *) {
            let coachingOverlay = ARCoachingOverlayView()
            
            //size correctly
            coachingOverlay.frame = sceneView.frame
            coachingOverlay.autoresizingMask = [
              .flexibleWidth, .flexibleHeight
            ]
            sceneView.addSubview(coachingOverlay)
            //look for horizontal planes
            coachingOverlay.goal = .horizontalPlane
            //match session with AR view
            coachingOverlay.session = sceneView.session
        } else {
            // Fallback on earlier versions
            //No current ideas for this.
        }
        
    //Tap Gestures:
        //start recognizing tap gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        //add longTap detection for deleting
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongTap(_:)))
        longTapGesture.allowableMovement = 5
        sceneView.addGestureRecognizer(longTapGesture)
        
    //Swipe Gestures
        let swipeGestureUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp(_:)))
        swipeGestureUp.direction = UISwipeGestureRecognizer.Direction.up
        let swipeGestureDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown(_:)))
        swipeGestureDown.direction = UISwipeGestureRecognizer.Direction.down
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft(_:)))
        swipeGestureLeft.direction = UISwipeGestureRecognizer.Direction.left
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight(_:)))
        swipeGestureRight.direction = UISwipeGestureRecognizer.Direction.right
        sceneView.addGestureRecognizer(swipeGestureUp)
        sceneView.addGestureRecognizer(swipeGestureDown)
        sceneView.addGestureRecognizer(swipeGestureLeft)
        sceneView.addGestureRecognizer(swipeGestureRight)
        
    //Set current Material Image
        currentMaterial.setBackgroundImage(UIImage(named: textures[selectedTexture]), for: UIControl.State.normal)
        
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
        let startGameRecognizer = UITapGestureRecognizer(target: self, action: #selector(startTheGame(_:)))
        startGame.isUserInteractionEnabled = true
        startGame.addGestureRecognizer(startGameRecognizer)
        
    //Set up model title
        self.modelName.text = "Untitled Design"
        self.modelName.textColor = UIColor.red
        self.modelName.backgroundColor = UIColor.darkGray
        self.modelName.layer.cornerRadius = 5
        self.modelName.alpha = 0.8
        self.modelName.font = UIFont.boldSystemFont(ofSize: 25.0)
        
        
    }
    
    //MARK: MINI GAMES
    
    @objc
    func startTheGame(_ gesture: UITapGestureRecognizer){
        startSnake()
    }
    
    var blockModificationAllowed = true
    
    var snakeParts: [Block] = []
    var targetLength: Int = 5
    var length: Int = 0
    //Front = 0 - Top = 1 - Right = 2 - Back = 3 - Bottom = 4 - Left = 5
    var direction = 0
//    var startingOrientation: [Int] = [0, 1, 2, 3, 4, 5]
    
    func startSnake(){
        
        if blockModificationAllowed {
            //Game isn't already started, so start game
            direction = 1
            targetLength = 5
            length = 0
            snakeParts = []
            
            blockModificationAllowed = false
            setRootToCamera(blocksAway: 10)
//            startingOrientation = deviceOrientation()
            snakeParts.append(Block(x: 31, y: 31, z: 31, texture: 1))
            placeBlockObj(block: snakeParts.last!)
            length += 1
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(snakeTimer), userInfo: nil, repeats: true)
            
        } else {
            //end game
            for b in snakeParts {
                removeBlockObj(block: b)
            }
            snakeParts = []
            
            timer.invalidate()
            timer = Timer()
            blockModificationAllowed = true
        }
        

        
    }
    
    //directions: Up = 0 - Right = 1 - Down = 2 - Left = 3
    func swiped(dir: Int) {
        //Front = 0 - Top = 1 - Right = 2 - Back = 3 - Bottom = 4 - Left = 5
        let rotation = deviceOrientation()
        let cam = rotation.firstIndex(of: 0)!
        let top = rotation.firstIndex(of: 1)!
//        print("Cam:", cam, " Top:", top)
        
        let keys = [0: [1: 0, 5: 1, 4: 2, 2: 3], 3: [1: 0, 5: 3, 4: 2, 2: 1], 2: [1: 0, 0: 1, 4: 2, 3: 3], 5: [1: 0, 0:  3, 4: 2, 3: 1]]
        
        let val = keys[cam]?[top]
        //if not a valid orientation, (aka up or down) do nothing
        if val == nil { return }
        
        let lookup = [0: [0: 2, 1: 1, 2: 5, 3: 4], 3: [0: 5, 1: 1, 2: 2, 3: 4], 2: [0: 3, 1: 1, 2: 0, 3: 4], 5: [0: 0, 1: 1, 2: 3, 3: 4]]
        
        let adjusted = (val! + dir) % 4
        
        let output = (lookup[cam]?[adjusted])!
        
        //make sure the snake can turn in this direction
        if output != direction && (output + 3) % 6 != direction {
            direction = output
        }
        
    }
    
    @objc
    func snakeTimer(){
        //entered in reverse order to match cube orientations
        var spot: [Int] = [snakeParts.last!.z, snakeParts.last!.y, snakeParts.last!.x]
        var tempDir = direction
        var mag = 1
        if [0, 2, 4].contains(tempDir) {
            mag = -1
        }
        if tempDir >= 3 {
            tempDir -= 3
        }
        spot[tempDir] += mag
        //flipped to undo reverse order from above
        snakeParts.append(Block(x: spot[2], y: spot[1], z: spot[0], texture: 1))
        placeBlockObj(block: snakeParts.last!)
        length += 1
        
        while length > targetLength {
            removeBlockObj(block: snakeParts.first!)
            snakeParts.removeFirst()
            length -= 1
        }
        
    }
    
    func deviceOrientation() -> [Int] {
        //Round angles to orthogonal directions
        var pitch = sceneView.session.currentFrame?.camera.eulerAngles.x ?? 0
        var yaw = sceneView.session.currentFrame?.camera.eulerAngles.y ?? 0
        var roll = sceneView.session.currentFrame?.camera.eulerAngles.z ?? 0
//        print("---Pitch:", pitch, "Yaw:", yaw , "Roll:", roll)
        if(pitch == 0 || yaw == 0 || roll == 0) { print("Failed") }
        if(pitch < 0){ pitch = pitch + (2 * Float.pi) }
        if(yaw < 0){ yaw = yaw + (2 * Float.pi) }
        if(roll < 0){ roll = roll + (2 * Float.pi) }
        pitch = (pitch / Float.pi) * 2.0
        yaw = (yaw / Float.pi) * 2.0
        roll = (roll / Float.pi) * 2.0
        pitch = pitch.rounded()
        yaw = yaw.rounded()
        roll = roll.rounded()
        if(pitch == 4.0) { pitch = 0.0 }
        if(yaw == 4.0) { yaw = 0.0 }
        if(roll == 4.0) { roll = 0.0 }
//        print("Pitch:", pitch.rounded(), "Yaw:", yaw.rounded() , "Roll:", roll.rounded())
//        print("Camera:", calcCameraOrientation(pitch: Int(pitch), yaw: Int(yaw), roll: Int(roll)))
        return calcDeviceOrientation(pitch: Int(pitch), yaw: Int(yaw), roll: Int(roll))
    }
    
    func calcDeviceOrientation(pitch p: Int, yaw y: Int, roll r: Int) -> [Int]{
        
        //Works for Every Case except Camera Pointed Upwards/Downwards, for some reason I'm not sure
        
        
        var pitch = p
        var yaw = y
        var roll = r
        
        //Front = 0 - Top = 1 - Right = 2 - Back = 3 - Bottom = 4 - Left = 5
        
        //                 Front Top Right Back Bottom Left
        var cube: [Int] = [ 0,    1,   2,   3,    4,    5  ]
        while roll > 0 {
            cube = rollCube(cube: cube)
//            print("error")
            roll -= 1
        }
        while yaw > 0 {
            cube = yawCube(cube: cube)
//            print("error")
            yaw -= 1
        }
        while pitch > 0 {
            cube = pitchCube(cube: cube)
//            print("error")
            pitch -= 1
        }
        return cube
    }
    func pitchCube(cube: [Int]) -> [Int] {
//        let newCube: [Int] = [cube[4], cube[0], cube[2], cube[1], cube[3], cube[5]]
        let newCube: [Int] = [cube[4], cube[0], cube[2], cube[1], cube[3], cube[5]]
        return newCube
    }
    func yawCube(cube: [Int]) -> [Int] {
        let newCube: [Int] = [cube[5], cube[1], cube[0], cube[2], cube[4], cube[3]]
        return newCube
    }
    func rollCube(cube: [Int]) -> [Int] {
        let newCube: [Int] = [cube[0], cube[5], cube[1], cube[3], cube[2], cube[4]]
//        let newCube: [Int] = [cube[0], cube[2], cube[4], cube[3], cube[5], cube[1]]
        return newCube
    }
    
    class Block {
        var x: Int
        var y: Int
        var z: Int
        var texture: Int
        init(x xIn: Int, y yIn: Int, z zIn: Int, texture textureIn: Int){
            x = xIn
            y = yIn
            z = zIn
            texture = textureIn
        }
    }
    
    //MARK: - Buttons -> 2nd V Controller
    @IBAction func toMaterialsView(_ sender: Any) {
         
        //open grid view here
        grid = self.storyboard!.instantiateViewController(withIdentifier: "MaterialsCollectionViewController") as? MaterialsCollectionViewController
        //prepare
        grid?.thisDelegate = self

        //transition
        self.present(grid!, animated: true, completion: nil)
    }
    
    /**
     Open table of saved designs to be loaded into the workspace, shared, or deleted
    - Parameter gesture: The tap guesture of the user
    */
    @objc
    func loadNewModel(_ gesture: UITapGestureRecognizer) {
        //open table view here
        table = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
        //prepare
        table?.theDelegate = self
        
        //transition
        self.present(table!, animated: true, completion: nil)
    }
    
    //MARK: - Buttons/Gestures
    
    //For Games
    @objc
    func swipedUp(_ gesture: UISwipeGestureRecognizer){
        swiped(dir: 0)
    }
    @objc
    func swipedDown(_ gesture: UISwipeGestureRecognizer){
        swiped(dir: 2)
    }
    @objc
    func swipedLeft(_ gesture: UISwipeGestureRecognizer){
        swiped(dir: 3)
    }
    @objc
    func swipedRight(_ gesture: UISwipeGestureRecognizer){
        swiped(dir: 1)
    }
    
    /**
     This function detects when the user has tapped on the Augmented Reality view. This function will place a block where the user pressed if they have tapped on a detected surface in the real world. If no blocks had been place before, this function also sets up the latice which makes every block places afterwards allign with this first block, and it sets the 64 block cubed workspace centered at this first block.
     - Parameter gesture: The tap guesture of the user
     */
    @objc
    func didTap(_ gesture: UITapGestureRecognizer) {
        if blockModificationAllowed {
            let sceneViewTappedOn = gesture.view as! ARSCNView
            let touchCoordinates = gesture.location(in: sceneViewTappedOn)
            
            placeBlock(sceneViewTappedOn: sceneViewTappedOn, touchCoordinates: touchCoordinates)
        }
    }
    
    /**
     This function detects when a user long taps on a block and deletes that block from the view and the storing design string
     - Parameter gesture: The user long press gesture
     */
    @objc
    func didLongTap(_ gesture: UILongPressGestureRecognizer) {
        if blockModificationAllowed {
            if(NSDate().timeIntervalSince1970 - 0.25 > time){
                    time = NSDate().timeIntervalSince1970
                    let sceneViewTappedOn = gesture.view as! ARSCNView
                    let touchCoordinates = gesture.location(in: sceneViewTappedOn)
            
                    removeBlock(sceneViewTappedOn: sceneViewTappedOn, touchCoordinates: touchCoordinates)
                }
        }
    }
    
    //MARK: - LOGIC
    
    func removeBlock(sceneViewTappedOn: ARSCNView, touchCoordinates: CGPoint) {
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
        self.modelName.textColor = UIColor.red
    }
    
    func placeBlock(sceneViewTappedOn: ARSCNView, touchCoordinates: CGPoint) {
        
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
                    currentMaterial.setBackgroundImage(UIImage(named: textures[selectedTexture]), for: UIControl.State.normal)
                    //prepare for ordinary actions
                    currentDesign = designToPlace
                    designToPlace = ""
                    self.modelName.textColor = UIColor.green
                    self.modelName.text = designToPlaceName
                    designToPlaceName = ""
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
//            print("Face Index: \(hitTestResult.first?.faceIndex)")
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
    
    func innerChangeMaterial(index: Int){
        selectedTexture = index
        currentMaterial.setBackgroundImage(UIImage(named: textures[selectedTexture]), for: UIControl.State.normal)
        grid?.dismiss(animated: true, completion: nil)
    }
    
    /**
     The function receives direction for a creation file which was selected in the table view, pulls out the design from the file, and prepares for it to be placed by the user into the view.
    - Parameter design: The file name for the design of the creation the user selected in the table view
    - Parameter folder: The folder of designs which the wanted file is stored in
    */
    func innerDesignSelected(design: String, folder: String) {
//        print("The Current Design is empty: ", Bool(design == ""))
        //design is now the String for the returned design
//        print("Design Received: " + design)
//        print("At Folder: \(folder)")
        //reading the file of name 'design' in 'folder'
        do {
            let contents = try String(contentsOfFile: FileManager.documentDirectoryURL.appendingPathComponent(folder).appendingPathComponent(design + ".txt").path)
//            print("Contents of File: " + contents)
            designToPlace = contents
            designToPlaceName = design
            } catch {
                //failed to read from file
//                print("Failed to read from file:")
//                print("ERROR: \(error)")
            }
        currentMaterial.setBackgroundImage(UIImage(named: "art.scnassets/plus.png"), for: UIControl.State.normal)
        //Ask to save, then clear the prior design from the workspace
            //first, dismiss table view so alert asking to save can be displayed
        table?.dismiss(animated: true, completion: nil)
        actuallyClearTheSpace()
    }
    
    /**
     Takes input from button and calls for the space to be cleared
    - Parameter gesture: The tap guesture of the user
    */
    @objc
    func clearTheSpace(_ gesture: UITapGestureRecognizer) {
        //call helper function to clear the workspace
        if blockModificationAllowed {
            actuallyClearTheSpace()
        } else {
            startSnake()
        }
    }

    /**
     This function clears all blocks from the workspace after asking the user whether to save their current design, and it removes the root position so the workspace will be centered at the next place the user builds.
    */
    func actuallyClearTheSpace() {
//        print("cur Des: \(currentDesign)")
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
            self.modelName.text = "Untitled Design"
            self.modelName.textColor = UIColor.red
        }
    }
    /**
     Helper function for actuallyClearTheSpace(). Goes through the nodes and removes all which are cubes
    */
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
        self.modelName.text = "Untitled Design"
        self.modelName.textColor = UIColor.red
    }
    
    /**
     Takes button input and calls for the design to be saved and not deleted afterwards
     - Parameter gesture: The tap guesture of the user
     */
    @objc
    func saveThatModel(_ gesture: UITapGestureRecognizer) {
        //call function below to save when button is pressed
        save(clearAfter: false)
    }
    
    /**
    Saves the model currently in the workspace. Function prompts user for a name to save the design under, and makes the name unique before saving the file.
     - Parameter clearAfter:If this parameter is set to true, the workspace will be cleared after the file is saved
     */
    func save(clearAfter shouldClearWorkspaceAfter: Bool){
        //ask for name to save under
        if(currentDesign != "" && self.modelName.text == "Untitled Design"){
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
                            } else {
                                self.modelName.text = name
                                self.modelName.textColor = UIColor.green
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
        } else if currentDesign != "" {
        //Model already has a name, so just update that file.
            let name = self.modelName.text!
            //check if local folder has been created, if not create it
            let folderPath = FileManager.documentDirectoryURL.appendingPathComponent("My Designs")
            let folderExists = (try? folderPath.checkResourceIsReachable()) ?? false
            if !folderExists {
                do {
                    try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: false)
//                  print("Created My Designs Directory")
                } catch {
                    //failed to create Directory
//                  print("Failed to create My Designs directory")
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
                } else {
                    self.modelName.text = name
                    self.modelName.textColor = UIColor.green
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
    }
    
    /**
     Files sent to this app CreationsAR are received in this function from the app delegate as a url to the file. This function saves that file to the Shared Designs folder, and prepares the design to be placed by the user into the workspace
     - Parameter url: The url that the iOS operating system gave the app to access the file being sent to the app
     */
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

    /**
     Places a block at the position specified by the vector and with the texture specified by the index given with respect to the textures array
     - Parameter position: The vector for where to place the block in the real world with AR
     - Parameter texture: The index in the textures array for which texture the block should have
     */
    func addItemToPosition(position: SCNVector3, texture: Int) {
        //make box
        let box = SCNBox(width: CGFloat(edgeLength), height: CGFloat(edgeLength), length: CGFloat(edgeLength), chamferRadius: 0)
        //set correct material
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: textures[texture])
        box.materials = [material]
        
        //TESTING: lighting stuff
//        let reflectiveMaterial = SCNMaterial()
//        reflectiveMaterial.lightingModel = .physicallyBased
//        reflectiveMaterial.metalness.contents = 1.0
//        reflectiveMaterial.roughness.contents = 0
//        box.materials = [reflectiveMaterial]
        
        //set node as box at position
        let node = SCNNode(geometry: box)
        node.position = position
        //lighting stuff
        node.castsShadow = true
        self.sceneView.scene.rootNode.addChildNode(node)
        //Model has been changed, show that it is no longer saved
        self.modelName.textColor = UIColor.red
    }
    
    func setRootToCamera(blocksAway numberOfBlocksInFrontOfCamera: Int){
        var num = numberOfBlocksInFrontOfCamera
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
//        print(cameraTransform)
        let cameraPosition = cameraTransform?.position()
//        print(cameraPosition)
//        //TODO: Use angles to actually set new root in front of camera
//          let cameraAngles = sceneView.session.currentFrame?.camera.eulerAngles
//          let pitch = cameraAngles?.x
//          let yaw = cameraAngles?.y
//          let roll = cameraAngles?.z
        
        //set root to new position
        var cameraDirection = deviceOrientation().firstIndex(of: 0)
//        print("Camera:", cameraDirection)
        //Front = 0 - Top = 1 - Right = 2 - Back = 3 - Bottom = 4 - Left = 5
        if [0, 1, 2].contains(cameraDirection) { num *= -1; cameraDirection! += 3}
        
        var vexX = cameraPosition!.x
        var vexY = cameraPosition!.y
        var vexZ = cameraPosition!.z
        
        if cameraDirection == 3 {
            vexZ += (edgeLength * Float(num))
        } else if cameraDirection == 4 {
            vexY += (edgeLength * Float(num))
        } else if cameraDirection == 5 {
           vexX += (edgeLength * Float(num))
       }
        
        rootPosition = SCNVector3(CGFloat(vexX), CGFloat(vexY), CGFloat(vexZ))
    }
    
    func placeBlockAt(x: Int, y: Int, z: Int, texture: Int){
        //Get root position
        var rPos: SCNVector3
        if(rootPosition != nil){
            //UNWRAP optional vector: rootPosition
            rPos = rootPosition!
        } else {
            setRootToCamera(blocksAway: 5)
            rPos = rootPosition!
        }
        
        //use Coordinates to make vector
        let posX: Float = rPos.x + Float(x-31)*edgeLength
        let posY: Float = rPos.y + Float(y-31)*edgeLength
        let posZ: Float = rPos.z + Float(z-31)*edgeLength
        let vexy: SCNVector3 = SCNVector3(CGFloat(posX), CGFloat(posY), CGFloat(posZ))
        addItemToPosition(position: vexy, texture: texture)
    }
    func placeBlockObj(block: Block){
        placeBlockAt(x: block.x, y: block.y, z: block.z, texture: block.texture)
    }
    
    func removeBlockAt(x: Int, y: Int, z: Int){
        //Get root position
        var rPos: SCNVector3
        if(rootPosition != nil){
            //UNWRAP optional vector: rootPosition
            rPos = rootPosition!
        } else {
            setRootToCamera(blocksAway: -5)
            rPos = rootPosition!
        }
        
        //use Coordinates to make vector
        let posX: Float = rPos.x + Float(x-31)*edgeLength
        let posY: Float = rPos.y + Float(y-31)*edgeLength
        let posZ: Float = rPos.z + Float(z-31)*edgeLength
        let vexy: SCNVector3 = SCNVector3(CGFloat(posX), CGFloat(posY), CGFloat(posZ))
        
        for childNode in sceneView.scene.rootNode.childNodes {
            if ((childNode.geometry?.description.contains("SCNBox")) ?? false) {
                if SCNVector3EqualToVector3(childNode.position, vexy) {
                    childNode.removeFromParentNode()
                }
            }
        }
    }
    func removeBlockObj(block: Block){
        removeBlockAt(x: block.x, y: block.y, z: block.z)
    }

    /**
     Function stores the position with the texture currently selected in the workspace, if the cube wanting to be places is within the workspace. This function should probably be removed as it doesn't serve much of a purpose. Remove and instead place calls of it with getting the string of position itself and then storing to current designs string if in bounds.
     - Parameter position: The vector position for where the cube is being places
     - Returns: A Bool of whether the cube is within range or not.
     */
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
    
    /**
     This function gets a 4 character (4 byte with ascii string storage) representation of a cube at a position and the currently selected texture.
     - Parameter position: The position to get the String representation of
     - Returns: A four character String. The first 3 characters are the X, Y, and Z, coordinates within the cube latice, and the 4th character stores the currently selected texture
     */
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

    /**
     Tests if a string contains a substring within four character frames. This checks if a block is stored, as every four characters is a block in a design String. This function avoids misfinding a block if the four character string happens to be present within say, the last two character of one block's representation and the first two character of the cube immediately after.
     - Parameter design: The design String which the function is checking whether a block is stored within
     - Parameter subStr: The String for the block the function is checking for
     - Returns: Returns the Bool 'true' if block representation is within String, 'false' if not
     */
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

    /**
     Removes all occurrences of a block's string representation within a design String. This function only checks within four character frames so that only requested blocks are removed
     - Parameter design: The design String which the function is checking to remove from
     - Parameter subStr: The String for the block the function is looking for to remove
     - Returns: A String of the new design String with all occurences of the searched for block removed
     */
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
    
    /**
     Takes in design String and a root position in the real world, and builds the design into the view
     - Parameter design: The design String to be build into the view
     - Parameter rPos: The real world root position in the Augmented Reality view to base the designs position off of
     */
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
        
        //lighting stuff
        configuration.isLightEstimationEnabled = true
        if #available(iOS 13.0, *) {
            configuration.environmentTexturing = .automatic
        } else {
            //fallback for earlier version
        }
        
        
        
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
    
    //Can show detected planes in world for testing purposes
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

/**
 Extention Of this view controller used by the table view (MenuViewController) to send back selected designs to main view to be put into the workspace.
 */
extension ViewController: LoadDesignDelegate, SelectedMaterialDelegate {
    //call function within to work with information
    /**
     Function passes along design filename and folder
     - Parameter design: File name of design
     - Parameter folder: Folder where design file is stored
     */
    func designSelected(design: String, folder: String) {
        innerDesignSelected(design: design, folder: folder)
    }
    
    //call function within to change selected Material
    func materialSelected(index: Int) {
        innerChangeMaterial(index: index)
    }
}

//Code from Stack Overflow to get SCNVector3 from a matrix given by ARCamera
extension matrix_float4x4 {
    func position() -> SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}
