//
//  PlantImageCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 12/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class EditPlantImageCell: UITableViewCell {

    @IBOutlet weak var plantImageView: UIImageView!
    
    weak var delegate: EditPlantImageCellDelegate?
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBAction func choosePicture(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Add image", message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.delegate?.dismiss(animated: true)
        }))

        actionSheet.addAction(UIAlertAction(title: "From gallery", style: .default, handler: { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.delegate?.presentView(imagePicker, animated: true)

        }))

        actionSheet.addAction(UIAlertAction(title: "Open camera", style: .default, handler: { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.delegate?.presentView(imagePicker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Remove image", style: .destructive, handler: { (action) in
            self.plantImageView?.image = UIImage()
            self.delegate?.imageAdded(image: nil)
        }))
        delegate?.presentView(actionSheet, animated: true)
    }
    
    func configureCell(image: UIImage?) {
        plantImageView.image = image    
    }
    
    func handleScroll(offset: CGFloat) {
        clipsToBounds = offset >= 0
        heightConstraint.constant = EditPlantViewController.SectionSize.image - offset
    }

}

extension EditPlantImageCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        plantImageView.image = image
        delegate?.imageAdded(image: image)
        delegate?.dismiss(animated: true)
    }
}

protocol EditPlantImageCellDelegate: class {
    func presentView(_ view: UIViewController, animated: Bool)
    
    func dismiss(animated: Bool)
    
    func imageAdded(image: UIImage?)
}
