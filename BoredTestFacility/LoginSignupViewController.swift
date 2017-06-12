//
//  LoginSignupViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/11/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import TextFieldEffects
import SwiftyGif

class LoginSignupViewController: UIViewController {
    
    @IBOutlet weak var gifImageView: UIImageView!

    @IBOutlet weak var emailTextField: KaedeTextField!
    @IBOutlet weak var passwordTextField: KaedeTextField!
    @IBOutlet weak var usernameTextField: KaedeTextField!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var logSwitchButton: UIButton!
    
    private var logType = false;
    private var userName = "";
    private var connected = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        
        setupLabels()
        
        usernameTextField.isHidden = true;
        
        let gifManager = SwiftyGifManager(memoryLimit:20)
        let gif = UIImage(gifName: "cityGif.gif")
        self.gifImageView.setGifImage(gif, manager: gifManager)
        
        FIRDatabase.database().persistenceEnabled = true;
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                if ((user?.displayName) != nil){
                    print(user?.displayName ?? "EMPTY");
                    self.performSegue(withIdentifier: "toMain", sender: nil)
                }
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
    }
    
    func setupLabels(){
        emailTextField.placeholder = "Email"
        emailTextField.textColor = UIColor.white
        emailTextField.font = emailTextField.font?.withSize(15)
        emailTextField.placeholderColor = UIColor.gray
        emailTextField.keyboardAppearance = .dark
        emailTextField.keyboardType = .emailAddress
        passwordTextField.placeholder = "Password"
        passwordTextField.textColor = UIColor.white
        passwordTextField.font = passwordTextField.font?.withSize(15)
        passwordTextField.placeholderColor = UIColor.gray
        passwordTextField.isSecureTextEntry = true
        passwordTextField.keyboardAppearance = .dark
        usernameTextField.placeholder = "Username"
        usernameTextField.textColor = UIColor.white
        usernameTextField.font = usernameTextField.font?.withSize(15)
        usernameTextField.placeholderColor = UIColor.gray
        usernameTextField.keyboardAppearance = .dark
    }

    override func viewWillAppear(_ animated: Bool) {
        emailTextField.text = "";
        passwordTextField.text = "";
        usernameTextField.text = "";
        usernameTextField.isHidden = true;
        
        logType = false;
        
    }
    
    func createUser(email: String, password: String, sender: UIButton) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            // Set Display Name
            let changeRequest = user?.profileChangeRequest()
            changeRequest?.displayName = self.usernameTextField.text!
            changeRequest?.commitChanges { error in
                if error != nil {
                    
                } else {
                    self.userName = self.usernameTextField.text!;
                    print(self.userName);
                    //Go to Main Screen
                    self.performSegue(withIdentifier: "toMain", sender: sender)
                }
            }
        }
    }
    
    func loginUser(email: String, password: String, sender: UIButton) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            //Go to Main Screen
            print(user?.displayName ?? "EMPTY");
            self.performSegue(withIdentifier: "toMain", sender: sender)
        }
    }
    
    @IBAction func logPressed(_ sender: UIButton) {
        if connected {
            if !emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty {
                if logType {
                    createUser(email: emailTextField.text!, password: passwordTextField.text!, sender: sender);
                }
                else {
                    loginUser(email: emailTextField.text!, password: passwordTextField.text!, sender: sender);
                }
            }
            else {
                //Alert
                let alertController = UIAlertController(title: "¯\\_(ツ)_/¯", message: "Please fill all of the fields.", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        else {
            let alertController = UIAlertController(title: "You are disconnected!", message: "Please reconnect to log in/sign up.", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func switchPressed(_ sender: UIButton) {
        if logType {
            usernameTextField.isHidden = true
            logInButton.setTitle("Log In!", for: UIControlState.normal)
            logSwitchButton.setTitle("Don't have an account? Sign up!", for: UIControlState.normal)
            logType = false;
        }
        else {
            usernameTextField.isHidden = false
            logInButton.setTitle("Sign Up!", for: UIControlState.normal)
            logSwitchButton.setTitle("Have an account? Log in!", for: UIControlState.normal)
            logType = true;
        }
    }
    

}
