//
//  MovieTheaterDetailViewController.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 6/6/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import UIKit
import MapKit

class MovieTheaterDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    let googlePlacesAPI = GooglePlacesAPI();
    var placeInfo = PlaceInfo()
    var moviesInTheater = [MovieDetail]()
    var moviePosters = [String]()
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var showtimesBar: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        googlePlacesAPI.getTheaterShowtimes(lat: Double(placeInfo.latitude)!, lng: Double(placeInfo.longitude)!)
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"MOVIEINFO"), object:nil, queue:nil, using:catchNotification)
        nc.addObserver(forName:Notification.Name(rawValue:"MOVIEPOSTER"), object:nil, queue:nil, using:catchNotification)
        
        // Do any additional setup after loading the view.
        
        navBar.layer.shadowColor = UIColor.black.cgColor
        navBar.layer.shadowOpacity = 0.85;
        navBar.layer.shadowRadius = 10;
        //navBar.layer.shouldRasterize = true;
        
        showtimesBar.layer.shadowColor = UIColor.black.cgColor
        showtimesBar.layer.shadowOpacity = 0.85;
        showtimesBar.layer.shadowRadius = 10;
        //showtimesBar.layer.shouldRasterize = true;
        
        let placeLocation = CLLocation(latitude: Double(placeInfo.latitude)!, longitude: Double(placeInfo.longitude)!)
        centerMapOnLocation(location: placeLocation)
        
        placeNameLabel.text = placeInfo.name + "."
        placeImageView.sd_setImage(with: URL(string: placeInfo.imageString), placeholderImage: UIImage(named: "placeholder.png"))
        tableView.register(UINib(nibName: "TheaterTableViewCell", bundle: nil), forCellReuseIdentifier: "cellReuse")
        tableView.backgroundColor = UIColor.clear
        tableView.isHidden = true
    }
    
    public func catchNotification(notification:Notification) -> Void {
        if notification.name.rawValue == "MOVIEINFO" {
            guard let userInfo = notification.userInfo,
                let movies = userInfo["movies"] as? [MovieDetail] else {
                    print("No userInfo found in notification")
                    return
            }
            moviesInTheater = movies
            tableView.reloadData()
            for movie in movies {
                if movie.type == "Feature Film"{
                    moviePosters.append("")
                }
                else {
                    moviePosters.append("N/A")
                }
            }
            tableView.isHidden = false
        }
        else if notification.name.rawValue == "MOVIEPOSTER"{
            guard let userInfo = notification.userInfo,
                let poster = userInfo["moviePoster"] as? String,
                let index = userInfo["index"] as? Int else {
                    print("No userInfo found in notification")
                    return
            }
            moviePosters[index] = poster
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesInTheater.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TheaterTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cellReuse") as! TheaterTableViewCell
        cell.movieNameLabel.text = moviesInTheater[indexPath.row].name
        cell.movieRuntimeLabel.text = moviesInTheater[indexPath.row].runtime
        switch moviesInTheater[indexPath.row].rating {
        case "G":
            cell.movieRatingImageView.image = #imageLiteral(resourceName: "rated_g")
        case "PG":
            cell.movieRatingImageView.image = #imageLiteral(resourceName: "rated_pg")
        case "PG-13":
            cell.movieRatingImageView.image = #imageLiteral(resourceName: "rated_pg13")
        case "R":
            cell.movieRatingImageView.image = #imageLiteral(resourceName: "rated_r")
        default:
            cell.movieRatingImageView.image = #imageLiteral(resourceName: "rated_pg")
        }
        
        cell.movieShowtimesTextView.text = ""
        for showing in moviesInTheater[indexPath.row].showings{
            let time = showing.substring(from:showing.index(showing.endIndex, offsetBy: -5))
            let characters = Array(time.characters)
            var hours = Int("\(characters[0])\(characters[1])")
            let mins = "\(characters[3])\(characters[4])"
            if hours! > 12 {
                hours = hours! - 12
                cell.movieShowtimesTextView.text = cell.movieShowtimesTextView.text + "\(hours ?? 0):\(mins)PM" + " | "
            }
            else {
                cell.movieShowtimesTextView.text = cell.movieShowtimesTextView.text + "\(hours ?? 0):\(mins)AM" + " | "
            }
            
        }
        
        if moviePosters[indexPath.row] == "" {
            googlePlacesAPI.getMoviePoster(title: moviesInTheater[indexPath.row].name, year: moviesInTheater[indexPath.row].year, index: indexPath.row)
        }
        else if moviePosters[indexPath.row] == "N/A"{
            cell.moviePosterImageView.image = #imageLiteral(resourceName: "moviePosterPlaceholder")
        }
        else {
            cell.moviePosterImageView.sd_setImage(with: URL(string: moviePosters[indexPath.row]), placeholderImage: UIImage(named: "moviePosterPlaceholder.png"))
        }
        
        return cell
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    @IBAction func openInMaps(_ sender: Any) {
        let lat:CLLocationDegrees = Double(placeInfo.latitude)!
        let lng:CLLocationDegrees = Double(placeInfo.longitude)!
        let coordinate = CLLocationCoordinate2DMake(lat, lng)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = placeInfo.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    
    
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    

}
