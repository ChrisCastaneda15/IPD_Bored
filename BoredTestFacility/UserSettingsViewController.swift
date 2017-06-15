//
//  UserSettingsViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/14/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import TextFieldEffects

class UserSettingsViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameTextField: KaedeTextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var changeImageButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitChanges(_ sender: UIButton) {
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeImageSelected(_ sender: UIButton) {
    }
    

}
