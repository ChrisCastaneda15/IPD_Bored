//
//  DetailViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/4/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class DetailViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeDescTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBar: UIView!
    
    var placeInfo = PlaceInfo();
    
    var placesClient = GMSPlacesClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.statusBarStyle = .lightContent
        
        placeNameLabel.text = placeInfo.name + "."
        placeImageView.sd_setImage(with: URL(string: placeInfo.imageString), placeholderImage: UIImage(named: "placeholder.png"))
        
        placeDescTextView.text = ""
        
        navBar.layer.shadowColor = UIColor.black.cgColor
        navBar.layer.shadowOpacity = 0.85;
        navBar.layer.shadowRadius = 10;
        //navBar.layer.shouldRasterize = true;
        
        let placeLocation = CLLocation(latitude: Double(placeInfo.latitude)!, longitude: Double(placeInfo.longitude)!)
        centerMapOnLocation(location: placeLocation)
        
        placesClient.lookUpPlaceID(placeInfo.placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                self.placeDescTextView.text = "Description Unavailable"
                return
            }
            
            guard let place = place else {
                print("No place details for \(self.placeInfo.placeID)")
                return
            }
            
            var desc = "\(place.name) "
            
            if place.openNowStatus == .no{
                desc = desc + "is currently not open now.\n"
            }
            else if place.openNowStatus == .unknown {
                desc = desc + " may or may not be open.\n"
                if let number = place.phoneNumber {
                    desc = desc + " Please contact \(number) if you'd like to know more.\n"
                }
            }
            else {
                desc = desc + "is open now!\n"
            }
            
            desc = desc + "\(place.name) is located at \" \(place.formattedAddress ?? "")\" \n"
            
            self.placeDescTextView.text = desc
        })
        

    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func RequestUber(_ sender: Any) {
    }

    @IBAction func openInMaps(_ sender: Any) {
        let lat:CLLocationDegrees = Double(placeInfo.latitude)!
        let lng:CLLocationDegrees = Double(placeInfo.longitude)!
        let coordinate = CLLocationCoordinate2DMake(lat, lng)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = placeInfo.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }

}
