//
//  ParkMueDetailViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/24/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import GooglePlaces
import ImageSlideshow
import MapKit
import UberRides

class ParkMueDetailViewController: UIViewController, MKMapViewDelegate, RideRequestButtonDelegate {
    
    let googlePlacesAPI = GooglePlacesAPI();

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var imageSlideshow: ImageSlideshow!
    @IBOutlet weak var placeDescTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var uberButtonView: UIView!
    @IBOutlet weak var favButton: DOFavoriteButton!
    
    let defaults = UserDefaults.standard
    
    var placeInfo = PlaceInfo();
    
    var placesClient = GMSPlacesClient()
    
    let ridesClient = RidesClient()
    let button = RideRequestButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeNameLabel.text = placeInfo.name + "."
        placeDescTextView.text = ""
        
        if googlePlacesAPI.checkFavs(place: placeInfo) == true {
            favButton.isSelected = true
        }
        
        uberSetup()
        
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
            
            print(place.openNowStatus.rawValue);
            print(GMSPlacesOpenNowStatus.unknown.rawValue)
            
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
        
        getImages()

        // Do any additional setup after loading the view.
    }
    
    func getImages(){
        var imgs = [ImageSource]()
        
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeInfo.placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let allPhotos = photos?.results{
                    for p in allPhotos {
                        GMSPlacesClient.shared().loadPlacePhoto(p, callback: {
                            (photo, error) -> Void in
                            if let error = error {
                                // TODO: handle the error.
                                print("Error: \(error.localizedDescription)")
                            } else {
                                
                                imgs.append(ImageSource(image: photo!))
                                
                                self.imageSlideshow.setImageInputs(imgs)

                            }
                        })
                    }
                }
                
            }
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

    func uberSetup(){
        let defaults = UserDefaults.standard
        let lat = defaults.double(forKey: "currLat")
        let lng = defaults.double(forKey: "currLong")
        
        let startCoord = CLLocation(latitude: lat, longitude: lng)
        
        let coord = CLLocation(latitude: Double(placeInfo.latitude)!, longitude: Double(placeInfo.longitude)!)
        
        let builder = RideParametersBuilder()
            .setPickupLocation(startCoord)
            .setDropoffLocation(coord, nickname: placeInfo.name)
        
        
        ridesClient.fetchCheapestProduct(pickupLocation: startCoord, completion: {
            product, response in
            if let productID = product?.productID {
                builder.setProductID(productID)
                self.button.rideParameters = builder.build()
                
                self.button.loadRideInformation()
            }
        })
        
        button.delegate = self
        
        button.center = uberButtonView.center
        button.colorStyle = .white
        uberButtonView.addSubview(button)
    }
    
    func rideRequestButtonDidLoadRideInformation(_ button: RideRequestButton) {
        button.sizeToFit()
        button.center = uberButtonView.center
    }
    
    func rideRequestButton(_ button: RideRequestButton, didReceiveError error: RidesError) {
        print(error.code ?? "Error")
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
    @IBAction func openInMaps(_ sender: Any) {
        let lat:CLLocationDegrees = Double(placeInfo.latitude)!
        let lng:CLLocationDegrees = Double(placeInfo.longitude)!
        let coordinate = CLLocationCoordinate2DMake(lat, lng)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = placeInfo.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    

}
