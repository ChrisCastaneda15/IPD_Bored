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

class ViewController: UIViewController, iCarouselDataSource, iCarouselDelegate, CLLocationManagerDelegate {
    let googlePlacesAPI = GooglePlacesAPI();
    var placeDict = [String:PlaceInfo]();
    var locationManager: CLLocationManager?
    
    var currentLocation = CLLocation()
    
    var selectedPlace = PlaceInfo()
    
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
        
        carousel.type = iCarouselType.rotary
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"PLACEINFO"), object:nil, queue:nil, using:catchNotification)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[0]
        //NY LAT:40.752357 LONG:-73.981569
        googlePlacesAPI.searchNearby(lat: currentLocation.coordinate.latitude,long: currentLocation.coordinate.longitude);
        googlePlacesAPI.getBestEvents(lat: currentLocation.coordinate.latitude,long: currentLocation.coordinate.longitude);
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
        placeView.placeNameLabel.text = pI.name
        let coordinate = CLLocation(latitude: Double(pI.latitude)!, longitude: Double(pI.longitude)!)
        let distanceInMiles = (currentLocation.distance(from: coordinate) / 1609.0)
        placeView.placeDistanceLabel.text = "\(String(format: "%.1f", distanceInMiles)) Mile(s) from you!"
        placeView.placeImageView.sd_setImage(with: URL(string: pI.imageString), placeholderImage: UIImage(named: "placeholder.png"))
        placeView.placeImageView.layer.masksToBounds = true
        placeView.placeImageView.contentMode = UIViewContentMode.center
        
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
        default:
            performSegue(withIdentifier: "detailVC", sender: carousel);
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch selectedPlace.placeType {
        case "movie_theater":
            let mTDVC = segue.destination as! MovieTheaterDetailViewController
            mTDVC.placeInfo = selectedPlace
        default:
            let dVC = segue.destination as! DetailViewController
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
            placeDict.updateValue(place, forKey: iD)
            carousel.reloadData()
            resultsAmountLabel.text = "Showing \(placeDict.count) Result(s)"
        }
        
    }

}

