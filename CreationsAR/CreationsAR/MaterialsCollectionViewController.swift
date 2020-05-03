//
//  MaterialsCollectionViewController.swift
//  CreationsAR
//
//  Created by Sean Cavalieri on 4/29/20.
//  Copyright © 2020 SeanCoding. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CVCell"

protocol SelectedMaterialDelegate: AnyObject {
    func materialSelected(index: Int)
}

class MaterialsCollectionViewController: UICollectionViewController {
    
    let textures: [String] = [ "art.scnassets/RedPaint.png", "art.scnassets/OrangePaint.png", "art.scnassets/YellowPaint.png", "art.scnassets/GreenPaint.png", "art.scnassets/BluePaint.png", "art.scnassets/PurplePaint.png", "art.scnassets/WhitePaint.png", "art.scnassets/BlackPaint.png", "art.scnassets/brick.png", "art.scnassets/WhiteBrick.png", "art.scnassets/Concrete.png", "art.scnassets/stone.png", "art.scnassets/mosaicStone.png", "art.scnassets/SmoothStone.png", "art.scnassets/Gravel.png", "art.scnassets/Sand.png", "art.scnassets/NiceWood.png", "art.scnassets/WoodBoards.png", "art.scnassets/BarnWood.png", "art.scnassets/WeatheredWood.png", "art.scnassets/DarkWood.png", "art.scnassets/GreyWood.png", "art.scnassets/wood.png", "art.scnassets/SmoothWood.png"]
    
    //for passing back design
    weak var thisDelegate: SelectedMaterialDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(header.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")

        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        self.collectionView.addGestureRecognizer(tap)
    }
    
    @objc
    func tapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else { return }
        self.thisDelegate?.materialSelected(index: indexPath.item)
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 24
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        let theIndex = indexPath.item
        let imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: (collectionView.frame.width - 30)/4, height: (collectionView.frame.width - 30)/4))
        imageView.image = UIImage(named: textures[theIndex])
        cell.addSubview(imageView)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var supplementaryView = UICollectionReusableView()
        supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
        return supplementaryView
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
//        print("HERE:", indexPath.item)
//    }

}

extension MaterialsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 30)/4, height: (collectionView.frame.width - 30)/4)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: view.frame.width, height: 60)
        } else {
            return .zero
        }
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        print("SELECTED:", indexPath.item)
//    }
}

class header: UICollectionReusableView {
    
    var label: UILabel = {
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textColor = .blue
        textLabel.text = "Chose a Material"
        textLabel.font = UIFont.boldSystemFont(ofSize: 30)
        textLabel.textAlignment = NSTextAlignment.center
        return textLabel
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        addSubview(label)
        label.topAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        label.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
