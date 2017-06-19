//
//  SideMenuViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/10/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SideMenuViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var helloUserNameLabel: UILabel!
    
    @IBOutlet weak var currentHourLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentImageView: UIImageView!
    @IBOutlet weak var currentPOPLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var connected = true
    var displayName = ""
    var firebaseDB: FIRDatabaseReference!
    var myUser: FIRUser!
    let googlePlacesAPI = GooglePlacesAPI();
    
    var hours = [String]()
    var temps = [String]()
    var pops = [String]()
    var imgs = [String]()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseDB = FIRDatabase.database().reference().child("users");
        
        userImageView.layer.shadowColor = UIColor.BoredColors.OffWhite.cgColor
        userImageView.layer.shadowOpacity = 0.85;
        userImageView.layer.shadowRadius = 100
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
    
        collectionView.isHidden = true
        
        collectionView.register(UINib(nibName: "WeatherCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cellReuse")
        collectionView.backgroundColor = UIColor.clear
        
        currentHourLabel.text = ""
        currentTempLabel.text = ""
        currentPOPLabel.text = ""
        
        
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"WEATHERINFO"), object:nil, queue:nil, using:catchNotification)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let wUrl = defaults.string(forKey: "wUrl")
        let cCode = defaults.string(forKey: "cCode")
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let currentUser = user {
                self.myUser = currentUser
                self.helloUserNameLabel.text = "Hello, \(currentUser.displayName ?? "User")!"
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
                self.observeDB()
            } else {
                print("Not connected")
                self.connected = false;
            }
        })
        
        googlePlacesAPI.getWeather(wUrl_2: wUrl!, countryCode: cCode!)
        
//        if let last = defaults.string(forKey: "lastUpdate"){
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
//            
//            let calendar: Calendar = Calendar.current
//            let cal = calendar.dateComponents([.year, .month, .day, .hour, .minute],
//                                              from: dateFormatter.date(from: last)!,
//                                              to: Date())
//            print(dateFormatter.date(from: last)!);
//            print(Date());
//            
//            if cal.minute! > 30 {
//                print("\nGET THE WEATHER\n");
//                googlePlacesAPI.getWeather(wUrl_2: wUrl!, countryCode: cCode!)
//            }
//            else {
//                print("\nHAVE THE WEATHER\n");
//                hours = defaults.array(forKey: "lastHours") as! [String]
//                temps = defaults.array(forKey: "lastTemps") as! [String]
//                pops = defaults.array(forKey: "lastPops") as! [String]
//                imgs = defaults.array(forKey: "lastImgs") as! [String]
//                
//                setCurrent()
//            }
//        }
//        else {
//            googlePlacesAPI.getWeather(wUrl_2: wUrl!, countryCode: cCode!)
//        }
    }
    
    func observeDB(){
        let userDB = firebaseDB.child(myUser.uid)
        userDB.observe(.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            if postDict.count > 0 {
                if postDict["profilePic"] != nil {
                    print("Found it");
                    let urlString = postDict["profilePic"]!
                    self.userImageView.sd_setImage(with: URL(string: urlString as! String), placeholderImage: UIImage(named: "placeholder.png"))
                }
                else {
                    print("Set One");
                }
            }
            
        })
    }
    
    @IBAction func sideMenuButtons(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            print("goToHome")
            if revealViewController().frontViewController.childViewControllers[0] is ViewController {
                revealViewController().revealToggle(animated: true)
            }
            else {
                performSegue(withIdentifier: "goHome", sender: sender)
            }
            
        case 2:
            print("goToSettings")
            if revealViewController().frontViewController.childViewControllers[0] is SettingsViewController {
                revealViewController().revealToggle(animated: true)
            }
            else {
                performSegue(withIdentifier: "goSettings", sender: sender)
            }
            
        default:
            print("XxXXXXXX\n\(revealViewController().frontViewController.childViewControllers[0].description)XxXXXXXX\n")
        }
    }
    

    public func catchNotification(notification:Notification) -> Void {
        if notification.name.rawValue == "WEATHERINFO" {
            guard let userInfo = notification.userInfo,
                let t = userInfo["temps"] as? [String],
                let p = userInfo["pops"] as? [String],
                let i = userInfo["imgs"] as? [String],
                let h = userInfo["hours"] as? [String] else {
                    print("No userInfo found in notification")
                    return
            }
            hours = h
            temps = t
            pops = p
            imgs = i
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
            defaults.set(dateFormatter.string(from: Date()), forKey: "lastUpdate")
            defaults.set(h, forKey: "lastHours")
            defaults.set(t, forKey: "lastTemps")
            defaults.set(p, forKey: "lastPops")
            defaults.set(i, forKey: "lastImgs")
            
            setCurrent()
        }
    }
    
    func setCurrent(){
        currentHourLabel.text = hours[0]
        currentTempLabel.text = temps[0] + "˚"
        currentPOPLabel.text = pops[0] + "%"
        currentImageView.sd_setImage(with: URL(string: imgs[0]), placeholderImage: UIImage(named: "placeholder.png"))
        
        collectionView.isHidden = false
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hours.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:WeatherCollectionViewCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cellReuse", for: indexPath) as! WeatherCollectionViewCell
        
        cell.hourLabel.text = hours[indexPath.row + 1]
        cell.tempLabel.text = temps[indexPath.row + 1] + "˚"
        cell.popLabel.text = pops[indexPath.row + 1] + "%"
        cell.iconLabel.sd_setImage(with: URL(string: imgs[indexPath.row + 1]), placeholderImage: UIImage(named: "placeholder.png"))
        
        return cell
    }
    
    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: ", signOutError)
        }
    }
        
}
