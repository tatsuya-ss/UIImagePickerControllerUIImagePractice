//
//  CollectionViewCell.swift
//  UIImage+UIImagePicker
//
//  Created by 坂本龍哉 on 2021/09/18.
//

import UIKit

final class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
    func configure(image: UIImage) {
        photoImageView.image = image
        photoImageView.backgroundColor = .systemBackground
    }

}
