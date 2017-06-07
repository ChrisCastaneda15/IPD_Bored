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
    let KEY_GOOGLE = "AIzaSyCpmvfI0yYJRIx04H1rhVIIB4ywEgw4I5w"
    
    func searchNearby(lat: Double, long:Double){
        
        let searchTypes = ["movie_theater": 5, "museum": 5, "restaurant": 10, "bowling_alley": 1, "cafe": 5, "library": 5, "night_club": 5, "shopping_mall": 5, "park": 5]
        let searchUrl_0 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=";
        let searchUrl_1 = "&radius=40233.6&key=\(KEY_GOOGLE)"
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
                            
                            photo = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photo)&key=\(self.KEY_GOOGLE)"
                            
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
    
    func getTheaterShowtimes(lat: Double, lng: Double){
        let theaterUrl_1 = "http://data.tmsapi.com/v1.1/movies/showings?startDate="
        let theaterUrl_2 = "&lat=\(lat)&lng=\(lng)&radius=1&api_key=9wg76s8xsyc4whvwus4fk62r"
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: date)
        let theaterUrl_final = theaterUrl_1 + currentDate + theaterUrl_2
        
        var theaterID = ""
        
        var movies = [MovieDetail]()
        
        Alamofire.request(theaterUrl_final).responseJSON { response in
            if let Json = response.data{
                let data = JSON(data: Json);
                let results = data.array
                for x in 0..<results!.count{
                    if let showtimes = results![x]["showtimes"].array{
                        if x == 0 {
                            var theaterInfo = showtimes[0]["theatre"].dictionary!
                            theaterID = theaterInfo["id"]!.string!
                        }
                        let name = results![x]["title"].string!
                        var runtime = "0H0M"
                        if let rt = results![x]["runTime"].string{
                            runtime = rt
                            runtime.remove(at: runtime.startIndex)
                            runtime.remove(at: runtime.startIndex)
                        }
                        let type = results![x]["subType"].string!
                    
                        var year = 2017
                        if let y = results![x]["releaseYear"].int{
                            year = y
                        }
                        
                        var rating = ""
                        if let ratings = results![x]["ratings"].array{
                            rating = ratings[0]["code"].string!
                        }
                        var showings = [String]()
                        for time in showtimes{
                            if theaterID == time["theatre"]["id"].string!{
                               showings.append(time["dateTime"].string!)
                            }
                        }
                        
                        if showings.count > 0 {
                            movies.append(MovieDetail(name: name, runtime: runtime, rating: rating, showings: showings, year: year, type: type))
                        }
                    }
                }
                
                let nc = NotificationCenter.default
                nc.post(name:Notification.Name(rawValue:"MOVIEINFO"),object: nil, userInfo: ["movies":movies])
            }
        }
    }
    
    func getMoviePoster(title: String, year: Int, index: Int){
        var name = title.replacingOccurrences(of: ": An IMAX 3D Experience", with: "")
        name = name.replacingOccurrences(of: "3D", with: "")
        name = name.replacingOccurrences(of: " ", with: "+")
        Alamofire.request("http://www.omdbapi.com/?t=\(name)&y=\(year)&apikey=1b307ed3").responseJSON { response in
            if let Json = response.data{
                let data = JSON(data: Json);
                if let poster = data["Poster"].string{
                    print(poster);
                    let nc = NotificationCenter.default
                    nc.post(name:Notification.Name(rawValue:"MOVIEPOSTER"),object: nil, userInfo: ["moviePoster":poster, "index": index])
                }
                else {
                    let nc = NotificationCenter.default
                    nc.post(name:Notification.Name(rawValue:"MOVIEPOSTER"),object: nil, userInfo: ["moviePoster":"N/A", "index": index])
                }
            }
        }
    }
}
        
    


