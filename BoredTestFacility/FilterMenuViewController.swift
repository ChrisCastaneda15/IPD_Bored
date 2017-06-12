//
//  FilterMenuViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/11/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import MapKit

class FilterMenuViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var filterButtons: [UIButton]!
    @IBOutlet var filterLabels: [UILabel]!
    
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var mileSlider: UISlider!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var toggled = [Bool]()
    var currentLocation = CLLocation()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        toggled = [true, true, true, true, true, true]
        
        centerMapOnLocation(radius: 5)
        
        for t in 0..<toggled.count {
            filterButtons[t].layer.borderColor = UIColor.BoredColors.OffWhite.cgColor
            if toggled[t] == true {
                filterButtons[t].layer.borderWidth = 2.0
                
            }
            else {
                filterButtons[t].layer.borderWidth = 0.0
            }
        }

    }

    func centerMapOnLocation(radius: Int) {
        let regionRadius: CLLocationDistance = Double(radius) * 100.0
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        let annotation = MKPointAnnotation()
        annotation.coordinate = currentLocation.coordinate
        mapView.addAnnotation(annotation)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        searchLabel.text = "Search Radius - \(Int(sender.value))m"
        centerMapOnLocation(radius: Int(sender.value))
    }
    
    
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        if toggled[sender.tag] == true {
            filterLabels[sender.tag].textColor = UIColor.BoredColors.DeepBlue
            toggled[sender.tag] = false
            filterButtons[sender.tag].layer.borderWidth = 0.0
            
        }
        else {
            filterLabels[sender.tag].textColor = UIColor.BoredColors.OffWhite
            toggled[sender.tag] = true
            filterButtons[sender.tag].layer.borderWidth = 2.0
            filterButtons[sender.tag].layer.borderColor = UIColor.BoredColors.OffWhite.cgColor
        }
        
    }
    
    @IBAction func submitButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
