//
//  ViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 5/30/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import SDWebImage
import iCarousel
import CoreLocation
import MapKit
import MZFormSheetPresentationController
import MZAppearance

class ViewController: UIViewController, iCarouselDataSource, iCarouselDelegate, CLLocationManagerDelegate {
    let googlePlacesAPI = GooglePlacesAPI();
    var placeDict = [String:PlaceInfo]();
    var locationManager: CLLocationManager?
    let defaults = UserDefaults.standard
    
    var currentLocation = CLLocation()
    
    var selectedPlace = PlaceInfo()
    
    var gotInfo = false
    
    var filters = [Bool]()
    var miles = 25.0
    
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var resultsAmountLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIApplication.shared.statusBarStyle = .lightContent
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestAlwaysAuthorization()
        
        filters = [true, true, true, true, true, true]
        
        if revealViewController() != nil {
            revealViewController().rearViewRevealWidth = view.frame.width * 0.85
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        carousel.type = iCarouselType.rotary
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"PLACEINFO"), object:nil, queue:nil, using:catchNotification)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        carousel.isScrollEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        carousel.isScrollEnabled = false
    }
    
    func getInfo(){
        gotInfo = false
        placeDict = [String:PlaceInfo]();
        resultsAmountLabel.text = "Getting Result(s)!"
        carousel.reloadData()
        locationManager?.startUpdatingLocation()
    }
    
    @IBAction func unwindToContainerVC(segue: UIStoryboardSegue) {
        if segue.source is FilterMenuViewController {
            if let source = segue.source as? FilterMenuViewController {
                filters = source.toggled
                miles = Double(Int(source.mileSlider.value))
                getInfo()
            }
        }
        
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        if revealViewController() != nil {
            revealViewController().revealToggle(sender)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[locations.count - 1]
        //NY LAT:40.752357 LONG:-73.981569
        
        self.defaults.set(Double(currentLocation.coordinate.longitude), forKey: "currLong")
        self.defaults.set(Double(currentLocation.coordinate.latitude), forKey: "currLat")
        
        if gotInfo == false{
            CLGeocoder().reverseGeocodeLocation(currentLocation) { (pmarks, error) in
                if pmarks?.count != 0 {
                    if let p = pmarks?[0]{
                        var countOrState = p.isoCountryCode
                        let city = p.locality!.replacingOccurrences(of: " ", with: "_")
                        if p.isoCountryCode == "US"{
                            countOrState = p.administrativeArea
                        }
                        
                        
                        self.defaults.set("\(countOrState!)/\(city).json", forKey: "wUrl")
                        self.defaults.set(p.isoCountryCode, forKey: "cCode")
                    }
                    
                }
            }
            

            googlePlacesAPI.searchNearby(lat: currentLocation.coordinate.latitude,long: currentLocation.coordinate.longitude, filters: filters, miles: (miles * 1609.34));
            
            if filters[1] == true {
                googlePlacesAPI.getZomatoID(lat: currentLocation.coordinate.latitude, lng:currentLocation.coordinate.longitude);
            }
            
            if filters[3] == true {
                googlePlacesAPI.getBestEvents(lat: currentLocation.coordinate.latitude,long: currentLocation.coordinate.longitude);
            }
            
            gotInfo = true
        }
        
        locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error);
    }

    func numberOfItems(in carousel: iCarousel) -> Int {
        return placeDict.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIView
        var placeView: PlaceCarouselView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? PlaceCarouselView {
            itemView = view
            placeView = itemView.viewWithTag(1) as! PlaceCarouselView
        } else {
            itemView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
            placeView = (Bundle.main.loadNibNamed("PlaceCarouselView", owner: self, options: nil)?[0] as? PlaceCarouselView)!;
            placeView.tag = 1
            placeView.frame = itemView.frame
            placeView.layer.masksToBounds = true
            itemView.addSubview(placeView)
        }
        
        var k = Array(placeDict.keys)
        let pI:PlaceInfo = placeDict[k[index]]!
        placeView.placeNameLabel.text = pI.name + "."
        let coordinate = CLLocation(latitude: Double(pI.latitude)!, longitude: Double(pI.longitude)!)
        let distanceInMiles = (currentLocation.distance(from: coordinate) / 1609.0)
        placeView.placeDistanceLabel.text = "\(String(format: "%.1f", distanceInMiles)) Mile(s) from you!"
        placeView.placeImageView.sd_setImage(with: URL(string: pI.imageString), placeholderImage: UIImage(named: "placeholder.png"))
        placeView.placeImageView.layer.masksToBounds = true
        placeView.placeImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        return itemView
        
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.15
        }
        return value
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        var k = Array(placeDict.keys)
        selectedPlace = placeDict[k[index]]!
        if carousel.currentItemIndex == index{
            moveToDetail(type: selectedPlace.placeType)
            
        }
    }
    
    func moveToDetail(type: String){
        switch type {
        case "movie_theater":
            performSegue(withIdentifier: "movieTheaterDetailVC", sender: carousel);
        case "restaurant":
            performSegue(withIdentifier: "restaurantDetailVC", sender: carousel);
        case "event":
            performSegue(withIdentifier: "eventDetailVC", sender: carousel);
        case "museum":
            performSegue(withIdentifier: "parkMueDetailVC", sender: carousel);
        case "park":
            performSegue(withIdentifier: "parkMueDetailVC", sender: carousel);
        default:
            performSegue(withIdentifier: "parkMueDetailVC", sender: carousel);
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch selectedPlace.placeType {
        case "movie_theater":
            let mTDVC = segue.destination as! MovieTheaterDetailViewController
            mTDVC.placeInfo = selectedPlace
        case "restaurant":
            let rDVC = segue.destination as! RestaurantDetailViewController
            rDVC.placeInfo = selectedPlace
        case "event":
            let eDVC = segue.destination as! EventDetailViewController
            eDVC.placeInfo = selectedPlace
        case "museum":
            let pmDVC = segue.destination as! ParkMueDetailViewController
            pmDVC.placeInfo = selectedPlace
        case "park":
            let pmDVC = segue.destination as! ParkMueDetailViewController
            pmDVC.placeInfo = selectedPlace
        default:
            let dVC = segue.destination as! ParkMueDetailViewController
            dVC.placeInfo = selectedPlace
        }
    }
    
    public func catchNotification(notification:Notification) -> Void {
        var place = PlaceInfo();
        
        if notification.name.rawValue == "PLACEINFO" {
            guard let userInfo = notification.userInfo,
                let name = userInfo["name"] as? String,
                let iD = userInfo["placeID"] as? String,
                let type = userInfo["type"] as? String,
                let lat = userInfo["lat"] as? String,
                let long = userInfo["long"] as? String,
                let image = userInfo["image"] as? String else {
                print("No userInfo found in notification")
                return
            }
            place = PlaceInfo(name: name, place: iD, image: image, placeType: type, lat: lat, long: long)
            let coordinate = CLLocation(latitude: Double(place.latitude)!, longitude: Double(place.longitude)!)
            if (currentLocation.distance(from: coordinate) / 1609.0) < miles {
                placeDict.updateValue(place, forKey: iD)
                carousel.reloadData()
                resultsAmountLabel.text = "Showing \(placeDict.count) Result(s)!"
            }
        }
        
    }

    
    @IBAction func openFilterMenu(_ sender: Any) {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "filterNavCon") as! UINavigationController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.contentViewSize = CGSize(width: 365.0, height: 500.0)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideAndBounceFromRight
        formSheetController.allowDismissByPanningPresentedView = true
        let presentedViewController = navigationController.viewControllers.first as! FilterMenuViewController
        presentedViewController.currentLocation = self.currentLocation
        presentedViewController.origToggled = filters
        presentedViewController.origMiles = miles
        
        self.present(formSheetController, animated: true, completion: nil)
    }
    


}

