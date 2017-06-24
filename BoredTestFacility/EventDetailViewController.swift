//
//  EventDetailViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/20/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import MapKit

class EventDetailViewController: UIViewController, MKMapViewDelegate {
    
    let googlePlacesAPI = GooglePlacesAPI();
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventImageLabel: UIImageView!
    @IBOutlet weak var eventDescTextView: UITextView!
    @IBOutlet weak var eventPriceRangeLabel: UILabel!
    @IBOutlet weak var eventVenueName: UILabel!
    @IBOutlet weak var eventVenueImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var favButton: DOFavoriteButton!
    
    var ticketURL = ""
    
    
    var placeInfo = PlaceInfo()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"EVENTINFO"), object:nil, queue:nil, using:catchNotification)
        
        navBar.layer.shadowColor = UIColor.black.cgColor
        navBar.layer.shadowOpacity = 0.85;
        navBar.layer.shadowRadius = 10;
        
        if googlePlacesAPI.checkFavs(place: placeInfo) == true {
            favButton.isSelected = true
        }
        
        eventNameLabel.text = placeInfo.name
        eventImageLabel.sd_setImage(with: URL(string: placeInfo.imageString), placeholderImage: UIImage(named: "placeholder.png"))
        let placeLocation = CLLocation(latitude: Double(placeInfo.latitude)!, longitude: Double(placeInfo.longitude)!)
        centerMapOnLocation(location: placeLocation)
        print(placeInfo.placeID)
        googlePlacesAPI.getEventDetail(id: placeInfo.placeID)
        
    }
    
    @IBAction func favButtonTapped(_ sender: DOFavoriteButton) {
        if sender.isSelected == false {
            sender.select()
            googlePlacesAPI.saveFavorite(place: placeInfo)
        }
        else {
            sender.deselect()
            googlePlacesAPI.deleteFav(place: placeInfo)
        }
    }
    
    
    public func catchNotification(notification:Notification) -> Void {
        if notification.name.rawValue == "EVENTINFO" {
            guard let userInfo = notification.userInfo,
                let u = userInfo["url"] as? String,
                let i = userInfo["info"] as? String,
                let img = userInfo["venueImg"] as? String,
                let saleDate = userInfo["saleDate"] as? String,
                let n = userInfo["name"] as? String,
                let min = userInfo["min"] as? Double,
                let max = userInfo["max"] as? Double,
                let g = userInfo["genre"] as? String else{
                    print("No userInfo found in notification")
                    return
            }
            
            ticketURL = u
            
            eventDescTextView.text = "Genre: \(g)\n"
            eventDescTextView.text = eventDescTextView.text + "Tickets on sale starting \(saleDate)\n"
            eventDescTextView.text = eventDescTextView.text + i
            
            eventVenueImageView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: "placeholder.png"))
            
            eventPriceRangeLabel.text = "$\(String(format: "%.2f", min)) - $ \(String(format: "%.2f", max))"
            
            eventVenueName.text = n
            
        }
    }

    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func openInMaps(_ sender: UIButton) {
        let lat:CLLocationDegrees = Double(placeInfo.latitude)!
        let lng:CLLocationDegrees = Double(placeInfo.longitude)!
        let coordinate = CLLocationCoordinate2DMake(lat, lng)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = placeInfo.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func buyTickets(_ sender: UIButton) {
        if ticketURL != "" {
            UIApplication.shared.open(URL(string: ticketURL)!, options: [:], completionHandler: nil)
        }
    }
}
