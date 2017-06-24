//
//  FavoritesViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/23/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import MapKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    let googlePlacesAPI = GooglePlacesAPI();
    
    var placesDict = [String:PlaceInfo]()
    let defaults = UserDefaults.standard
    
    var coord: CLLocation!
    
    var selectedPlace: PlaceInfo!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateFavs()
        
        let lat = defaults.double(forKey: "currLat")
        let lng = defaults.double(forKey: "currLong")
        
        coord = CLLocation(latitude: lat, longitude: lng)
        
        tableView.register(UINib(nibName: "FavoriteTableViewCell", bundle: nil), forCellReuseIdentifier: "cellReuse")
        tableView.backgroundColor = UIColor.clear
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateFavs()
    }
    
    func updateFavs(){
        placesDict = googlePlacesAPI.getFavorites()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FavoriteTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cellReuse") as! FavoriteTableViewCell
        
        let k = Array(placesDict.keys)
        cell.placeNameLabel.text = placesDict[k[indexPath.row]]!.name
        cell.placeImageView.sd_setImage(with: URL(string: placesDict[k[indexPath.row]]!.imageString), placeholderImage: UIImage(named: "placeholder.png"))
        cell.placeImageView.layer.masksToBounds = true
        cell.placeImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        let coordinate = CLLocation(latitude: Double(placesDict[k[indexPath.row]]!.latitude)!,
                                    longitude: Double(placesDict[k[indexPath.row]]!.longitude)!)
        let distanceInMiles = (coord.distance(from: coordinate) / 1609.0)
        cell.placeDistLabel.text = "\(String(format: "%.1f", distanceInMiles)) Mile(s) from you!"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var k = Array(placesDict.keys)
        selectedPlace = placesDict[k[indexPath.row]]!
        moveToDetail(type: selectedPlace.placeType)
    }
    
    func moveToDetail(type: String){
        switch type {
        case "movie_theater":
            performSegue(withIdentifier: "favs2Movie", sender: tableView);
        case "restaurant":
            performSegue(withIdentifier: "favs2Food", sender: tableView);
        case "event":
            performSegue(withIdentifier: "favs2Event", sender: tableView);
        default:
            performSegue(withIdentifier: "favs2Detail", sender: tableView);
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
        default:
            let dVC = segue.destination as! DetailViewController
            dVC.placeInfo = selectedPlace
        }
    }
    
    @IBAction func menuPressed(_ sender: UIButton) {
        if revealViewController() != nil {
            revealViewController().revealToggle(sender)
        }
    }
}
