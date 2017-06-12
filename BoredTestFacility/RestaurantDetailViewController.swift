//
//  RestaurantDetailViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/9/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import MapKit

class RestaurantDetailViewController: UIViewController, MKMapViewDelegate {
    
    let googlePlacesAPI = GooglePlacesAPI();
    var placeInfo = PlaceInfo()
    var menuLink = ""
    var resLink = ""
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet var priceLabels: [UILabel]!
    @IBOutlet weak var avgPriceLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var servesLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        googlePlacesAPI.getZomatoInfo(id: placeInfo.placeID)
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"RESTINFO"), object:nil, queue:nil, using:catchNotification)
        
        // Do any additional setup after loading the view.
        let placeLocation = CLLocation(latitude: Double(placeInfo.latitude)!, longitude: Double(placeInfo.longitude)!)
        centerMapOnLocation(location: placeLocation)
        
        placeNameLabel.text = placeInfo.name + "."
        placeImageView.image = #imageLiteral(resourceName: "placeholder")
        //placeImageView.sd_setImage(with: URL(string: placeInfo.imageString), placeholderImage: UIImage(named: "placeholder.png"))
        
        for label in priceLabels {
            label.text = ""
        }
        
        avgPriceLabel.text = ""
        
        openLabel.text = ""
        servesLabel.text = ""
        
        
        navBar.layer.shadowColor = UIColor.black.cgColor
        navBar.layer.shadowOpacity = 0.85;
        navBar.layer.shadowRadius = 10;
    }
    
    public func catchNotification(notification:Notification) -> Void {
        if notification.name.rawValue == "RESTINFO" {
            guard let userInfo = notification.userInfo,
                let p = userInfo["place"] as? RestaurantDetail,
                let o = userInfo["hours"] as? String,
                let photo = userInfo["photo"] as? String else {
                    print("No userInfo found in notification")
                    return
            }
            placeImageView.sd_setImage(with: URL(string: photo), placeholderImage: UIImage(named: "placeholder.png"))
            openLabel.text = o
            
            for label in priceLabels {
                label.text = p.currency
                if label.tag <= p.price {
                    label.textColor = UIColor.green
                }
            }
            
            avgPriceLabel.text = p.currency + "\(p.avg)"
            
            servesLabel.text = "\(p.serves) Cuisine"
            
            resLink = p.link
            menuLink = p.menu
            
        }
    }
    
    @IBAction func openInMaps(_ sender: Any) {
        let lat:CLLocationDegrees = Double(placeInfo.latitude)!
        let lng:CLLocationDegrees = Double(placeInfo.longitude)!
        let coordinate = CLLocationCoordinate2DMake(lat, lng)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = placeInfo.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func websiteButton(_ sender: Any) {
        if resLink != "" {
            UIApplication.shared.open(URL(string: resLink)!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func viewMenuButton(_ sender: Any) {
        if menuLink != "" {
            UIApplication.shared.open(URL(string: menuLink)!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
