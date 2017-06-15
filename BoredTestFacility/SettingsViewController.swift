//
//  SettingsViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/14/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            revealViewController().rearViewRevealWidth = view.frame.width * 0.85
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        if revealViewController() != nil {
            revealViewController().revealToggle(sender)
        }
    }

    @IBAction func settingsButtonPressed(_ sender: UIButton) {
    }
    

}
