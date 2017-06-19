//
//  UserSettingsViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/14/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import TextFieldEffects
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UserSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let picker = UIImagePickerController()

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameTextField: KaedeTextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var changeImageButton: UIButton!
    
    var imageChange = true
    var connected = true
    var firebaseDB: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var myUser: FIRUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseDB = FIRDatabase.database().reference().child("users");
        self.storageRef = FIRStorage.storage().reference(forURL: "gs://bored-f8584.appspot.com")
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        submitButton.layer.cornerRadius = submitButton.frame.size.width / 2
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let currentUser = user {
                self.myUser = currentUser
                self.userNameTextField.text = self.myUser.displayName
                
                self.observeDB()
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                print("Connected")
                self.connected = true;
            } else {
                print("Not connected")
                self.connected = false;
            }
        })
    
        userNameTextField.placeholder = "Username"
        userNameTextField.textColor = UIColor.white
        userNameTextField.font = userNameTextField.font?.withSize(15)
        userNameTextField.placeholderColor = UIColor.gray
        userNameTextField.keyboardAppearance = .dark
        userNameTextField.keyboardType = .default
        userNameTextField.returnKeyType = .done
        userNameTextField.delegate = self
        picker.delegate = self
        picker.allowsEditing = false
        
    }
    
    func observeDB(){
        let userDB = firebaseDB.child(myUser.uid)
        userDB.observe(.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            if postDict["profilePic"] != nil {
                self.imageChange = false
                print("Found it");
                let urlString = postDict["profilePic"]!
                self.userImageView.sd_setImage(with: URL(string: urlString as! String), placeholderImage: UIImage(named: "placeholder.png"))
            }
            else {
                print("Set One");
                self.imageChange = true
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func storeUserImage(data: Data){
        let ref = self.storageRef.child(myUser.uid).child("profilePic")
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        
        
        ref.put(data, metadata: metaData) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL()?.absoluteString
            self.firebaseDB.child(self.myUser.uid).child("profilePic").setValue(downloadURL)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        // Create a reference to the file you want to upload
        imageChange = true
        userImageView.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitChanges(_ sender: UIButton) {
        if imageChange == true {
            storeUserImage(data: UIImageJPEGRepresentation(userImageView.image!, 0.8)!)
        }
    
        if userNameTextField.text != myUser.displayName {
            let changeRequest = myUser.profileChangeRequest()
            changeRequest.displayName = self.userNameTextField.text
            changeRequest.commitChanges { error in
                if error != nil {
                    
                } else {
                    print(self.myUser.displayName!);
                }
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeImageSelected(_ sender: UIButton) {
        openActionSheet()
    }
    
    func openActionSheet(){
        let alertController = UIAlertController(title: "Set a User Image", message: "What would you like to do?", preferredStyle: .actionSheet)
        
        let sendButton = UIAlertAction(title: "Take a picture", style: .default, handler: { (action) -> Void in
            self.picker.sourceType = .camera
            self.picker.cameraCaptureMode = .photo
            self.present(self.picker, animated: true, completion: nil)
            print("TakePic")
        })
        
        let  deleteButton = UIAlertAction(title: "Use an image from Photo Album", style: .default, handler: { (action) -> Void in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
            print("UsePic")
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        
        alertController.addAction(sendButton)
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }

}
