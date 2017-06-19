//
//  SettingsViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/14/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController
import MZAppearance
import FirebaseAuth

class SettingsViewController: UIViewController {

    var myUser: FIRUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            revealViewController().rearViewRevealWidth = view.frame.width * 0.85
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let currentUser = user {
                self.myUser = currentUser
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
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
        if sender.tag == 0 {
            let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "userSetCon") as! UINavigationController
            let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
            formSheetController.presentationController?.contentViewSize = CGSize(width: 365.0, height: 425.0)
            formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideAndBounceFromTop
            formSheetController.allowDismissByPanningPresentedView = true
            self.present(formSheetController, animated: true, completion: nil)
        }
        else if sender.tag == 2 {
            
            let alertController = UIAlertController(title: "Delete Account!", message: "Are you sure you want to delete your account?", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (act) in
                self.myUser.delete { error in
                    if let error = error {
                        print("ERROR\(error)");
                    } else {
                        print("Account Deleted")
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })

            alertController.addAction(deleteAction)
            alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
        }
    }
    

}
