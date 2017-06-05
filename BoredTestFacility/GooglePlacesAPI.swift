//
//  GooglePlacesAPI.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 5/30/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import Foundation
import Alamofire
import GooglePlaces

public class GooglePlacesAPI{
    func searchNearby(lat: Double, long:Double){

        let searchTypes = ["movie_theater": 5, "museum": 5, "restaurant": 10, "bowling_alley": 1, "cafe": 5, "library": 5, "night_club": 5, "shopping_mall": 5, "park": 5]
        let searchUrl_0 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=";
        let searchUrl_1 = "&radius=40233.6&key=AIzaSyCpmvfI0yYJRIx04H1rhVIIB4ywEgw4I5w"
        let searchUrl_type = "&type="
        
        for (type, count) in searchTypes {
            let searchUrl_final = searchUrl_0 + "\(lat),\(long)" + searchUrl_type + type + searchUrl_1;
            
            Alamofire.request(searchUrl_final).responseJSON { response in
                if let Json = response.data{
                    let data = JSON(data: Json);
                    if let results = data["results"].array {
                        for num in 0..<count{
                            var photo = ""
                            let photos = results[Int(num)]["photos"].array
                            if let image = photos{
                                photo = image[0]["photo_reference"].string!
                            }
                            let name = results[Int(num)]["name"].string!
                            let id = results[Int(num)]["place_id"].string!
                            
                            photo = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photo)&key=AIzaSyCpmvfI0yYJRIx04H1rhVIIB4ywEgw4I5w"
                            
                            var lat_place = "0.0"
                            var long_place = "0.0"
                        
                            
                            if let location = results[Int(num)]["geometry"]["location"].dictionary{
                                lat_place = location["lat"]!.double!.description
                                long_place = location["lng"]!.double!.description
                            }
                            
                            let nc = NotificationCenter.default
                            nc.post(name:Notification.Name(rawValue:"PLACEINFO"),object: nil, userInfo: ["name":name, "placeID":id, "image":photo, "type":type, "lat":lat_place, "long":long_place])
                        }
                    }
                }
            }
        }
        
    }
    
    public func loadFirstPhotoForPlace(placeID: String) -> UIImage?{
        var placePhoto: UIImage?;
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: {
                        (photo, error) -> Void in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else {
                            placePhoto = photo;
                        }
                    })
                }
            }
        }
        return placePhoto
    }
    
    func getBestEvents(lat: Double, long:Double){
        let ticketmasterUrl_1 = "https://app.ticketmaster.com/discovery/v2/events.json?size=7&latlong="
        let ticketmasterUrl_2 = "&radius=20"
        let ticketmasterUrl_3 = "&apikey=2oeLG86JkAZfAOuAWSLCaZniWyzFKTfO"
        let ticketmasterUrl_final = ticketmasterUrl_1 + "\(lat),\(long)" + ticketmasterUrl_2 + ticketmasterUrl_3
        Alamofire.request(ticketmasterUrl_final).responseJSON { response in
            if let Json = response.data{
                let data = JSON(data: Json);
                if let embedded = data["_embedded"].dictionary{
                    if let events = embedded["events"]?.array {
                        for event in events {
                            //print(event);
                            let name = event["name"].string!
                            let id = event["id"].string!
                            var pic = ""
                            
                            if let images = event["images"].array{
                                for image in images{
                                    if image["width"].int == 1024 && image["ratio"].string == "16_9"{
                                        pic = image["url"].string!
                                    }
                                }
                                if pic == ""{
                                    pic = images[0]["url"].string!
                                }
                            }
                            
                            var lat_place = "0.0"
                            var long_place = "0.0"
                            
                            if let embedded = event["_embedded"].dictionary{
                                if let venues = embedded["venues"]?.array{
                                    let coord = venues[0]["location"].dictionary!
                                    lat_place = coord["latitude"]!.string!
                                    long_place = coord["longitude"]!.string!
                                }
                            }
                            
                            let nc = NotificationCenter.default
                            nc.post(name:Notification.Name(rawValue:"PLACEINFO"),object: nil, userInfo: ["name":name, "placeID":id, "image":pic, "type":"event", "lat":lat_place, "long":long_place])
                        }
                    }
                }
                
            }
        }
        
    }

}
