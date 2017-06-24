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
    @IBOutlet var filterImages: [UIImageView]!
    

    @IBOutlet weak var sButton: UIButton!
    
    
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var mileSlider: UISlider!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var origToggled = [Bool]()
    var origMiles = 0.0
    var toggled = [Bool]()
    var currentLocation = CLLocation()

    override func viewDidLoad() {
        super.viewDidLoad()
        sButton.isEnabled = false
        toggled = origToggled
        
        centerMapOnLocation(radius: Int(origMiles))
        
        mileSlider.value = Float(origMiles)
        searchLabel.text = "Search Radius - \(Int(mileSlider.value))m"
        
        for t in 0..<toggled.count {
            filterButtons[t].layer.borderColor = UIColor.BoredColors.OffWhite.cgColor
            if toggled[t] == true {
                filterButtons[t].layer.borderWidth = 2.0
                filterLabels[t].textColor = UIColor.BoredColors.OffWhite
                filterImages[t].tintColor = UIColor.BoredColors.OffWhite
            }
            else {
                filterButtons[t].layer.borderWidth = 0.0
                filterLabels[t].textColor = UIColor.BoredColors.DeepBlue
                filterImages[t].tintColor = UIColor.BoredColors.DeepBlue
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
        
        enableDisableButton()
    }
    
    
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        if toggled[sender.tag] == true {
            filterLabels[sender.tag].textColor = UIColor.BoredColors.DeepBlue
            filterImages[sender.tag].tintColor = UIColor.BoredColors.DeepBlue
            toggled[sender.tag] = false
            filterButtons[sender.tag].layer.borderWidth = 0.0
            
        }
        else {
            filterLabels[sender.tag].textColor = UIColor.BoredColors.OffWhite
            filterImages[sender.tag].tintColor = UIColor.BoredColors.OffWhite
            toggled[sender.tag] = true
            filterButtons[sender.tag].layer.borderWidth = 2.0
            filterButtons[sender.tag].layer.borderColor = UIColor.BoredColors.OffWhite.cgColor
        }
        
        enableDisableButton()
    }
    
    @IBAction func submitButton(_ sender: Any) {
        let anyDiff = checkChange()
        
        if anyDiff == true {
            let defaults = UserDefaults.standard
            defaults.set(toggled, forKey: "toggledFilters")
            //self.dismiss(animated: true, completion: nil)
        }
        else {
            //Alert
        }
    }
    
    func enableDisableButton(){
        let c = checkChange()
        
        if c == true || origMiles != Double(Int(mileSlider.value)) {
            sButton.isEnabled = true
        }
        else {
            sButton.isEnabled = false
        }
    }
    
    func checkChange()-> Bool{
        var anyDiff = false
        
        for i in 0..<toggled.count {
            if origToggled[i] != toggled[i]{
                anyDiff = true
                break
            }
        }
        
        return anyDiff
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
