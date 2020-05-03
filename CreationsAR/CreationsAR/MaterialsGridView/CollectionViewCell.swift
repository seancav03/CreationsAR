//
//  CollectionViewCell.swift
//  CreationsAR
//
//  Created by Sean Cavalieri on 4/29/20.
//  Copyright © 2020 SeanCoding. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setImage(image: UIImage){
        imageView.image = image
    }

}
