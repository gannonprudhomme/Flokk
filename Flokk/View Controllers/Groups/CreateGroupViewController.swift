//
//  AddGroupViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/10/18.
//  Copyright © 2018 Gannon Prudhomme. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController {
    @IBOutlet weak var groupIconButton: UIButton!
    @IBOutlet weak var groupNameField: UITextField!
    
    // For passing the new group back to the groups view
    var delegate: GroupsViewControllerDelegate!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        groupIconButton.contentMode = .scaleAspectFit
        groupIconButton?.layer.cornerRadius = (self.groupIconButton?.frame.size.width)! / 2
        groupIconButton?.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func groupIconPressed(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        if groupNameField.text!.count > 0 {
            delegate.addNewGroup(groupName: groupNameField.text!, icon: (groupIconButton.imageView?.image)!)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - Image Picker functions
extension CreateGroupViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            groupIconButton.setImage(pickedImage, for: UIControlState.normal)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
