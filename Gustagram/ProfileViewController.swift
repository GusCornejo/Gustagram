//
//  ProfileViewController.swift
//  Gustagram
//
//  Created by Gustavo Cornejo on 10/11/21.
//

import UIKit
import Parse
import AlamofireImage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var profilePicSavedLabel: UILabel!
    
    let user = PFUser.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileNameLabel.text = user?.username
        
        let imageFile = user?["profilePic"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        profilePicView.af_setImage(withURL: url)
        
        profilePicSavedLabel.isHidden.toggle()
        
        profilePicView.layer.borderWidth = 1
        profilePicView.layer.masksToBounds = false
        profilePicView.layer.borderColor = UIColor.black.cgColor
        profilePicView.layer.cornerRadius = profilePicView.frame.height/2
        profilePicView.clipsToBounds = true
    }
    
    @IBAction func onSaveButton(_ sender: Any) {
        
        let imageData = profilePicView.image!.pngData()
        let file = PFFileObject(name: "profileImage.png", data: imageData!)
        
        user!["profilePic"] = file
        profilePicSavedLabel.isHidden.toggle()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
            self.profilePicSavedLabel.isHidden.toggle()
            timer.invalidate()
        }
        
        user!.saveInBackground { (success, error) in
            if success {
                print("saved")
            } else {
                print("error")
            }
        }
    }
    
    
    @IBAction func onLibraryButton(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func onProfilePicture(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 200, height: 200)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        
        profilePicView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
