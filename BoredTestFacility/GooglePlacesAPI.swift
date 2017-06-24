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
import CoreData

public class GooglePlacesAPI{
    let KEY_GOOGLE = "AIzaSyCpmvfI0yYJRIx04H1rhVIIB4ywEgw4I5w"
    let KEY_TICKETMASTER = "2oeLG86JkAZfAOuAWSLCaZniWyzFKTfO"
    let KEY_TMS = "9wg76s8xsyc4whvwus4fk62r"
    let ZOMATO_HEADER: HTTPHeaders = [
        "user-key": "2780090e35e9d807b1f793e96b2a6f69"
    ]
    let KEY_WEATHER = "b5d6591a8a63a613"
    
    
    func saveFavorite(place: PlaceInfo){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "PlaceDetail",in: managedContext)!
        
        let p = NSManagedObject(entity: entity, insertInto: managedContext)
        
        p.setValue(place.name, forKey: "name")
        p.setValue(place.placeID, forKey: "id")
        p.setValue(place.placeType, forKey: "placetype")
        p.setValue(place.imageString, forKey: "imagestring")
        p.setValue(place.longitude, forKey: "long")
        p.setValue(place.latitude, forKey: "lat")
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    func getFavorites()->[String:PlaceInfo]{
        var favPlaces = [String:PlaceInfo]();
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return favPlaces
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PlaceDetail")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            if let favs = results as? [NSManagedObject] {
                for i in favs{
                    let n = i.value(forKey: "name")! as! String
                    let k = i.value(forKey: "id")! as! String
                    let img = i.value(forKey: "imagestring")! as! String
                    let t = i.value(forKey: "placetype")! as! String
                    let lat = i.value(forKey: "lat")! as! String
                    let long = i.value(forKey: "long")! as! String
                    
                    print(n);
                    let place = PlaceInfo(name: n, place: k, image: img, placeType: t, lat: lat, long: long)
                    favPlaces.updateValue(place, forKey: k);
                }
                
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return favPlaces
    }
    
    func checkFavs(place: PlaceInfo)->Bool{
        let favPlaces = getFavorites()
        
        if favPlaces[place.placeID] != nil {
            return true
        }
        
        return false
    }
    
    func deleteFav(place: PlaceInfo){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        

        let managedContext = appDelegate.persistentContainer.viewContext
        
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "PlaceDetail", in: managedContext)
        fetchRequest.includesPropertyValues = false
        do {
            if let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject] {
                for result in results {
                    if place.placeID == result.value(forKey: "id")! as! String {
                        managedContext.delete(result)
                        break
                    }
                }
                
                try managedContext.save()
            }
        } catch {
            print("NOPE");
        }
        
        
    }
    
    func deleteAllFav(){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "PlaceDetail", in: managedContext)
        fetchRequest.includesPropertyValues = false
        do {
            if let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject] {
                for result in results {
                    managedContext.delete(result)
                }
                
                try managedContext.save()
            }
        } catch {
            print("NOPE");
        }
        
    }
    
    func requestUber(place: PlaceInfo){

    }
    
    
    func searchNearby(lat: Double, long:Double, filters: [Bool], miles: Double){
        
        let searchTypes = ["movie_theater": 10, "museum": 10, "bowling_alley": 3, "cafe": 10, "library": 10, "night_club": 5, "shopping_mall": 10, "park": 8]
        var filteredSearchTypes = searchTypes
        if filters[0] == false {
            filteredSearchTypes["park"] = 0
        }
        if filters[1] == false {
            filteredSearchTypes["cafe"] = 0
        }
        if filters[2] == false {
            filteredSearchTypes["bowling_alley"] = 0
            filteredSearchTypes["night_club"] = 0
            filteredSearchTypes["shopping_mall"] = 0
        }
        if filters[4] == false {
            filteredSearchTypes["movie_theater"] = 0
        }
        if filters[5] == false {
            filteredSearchTypes["museum"] = 0
            filteredSearchTypes["library"] = 0
        }
        
        
        let searchUrl_0 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=";
        let searchUrl_1 = "&radius=\(miles)&key=\(KEY_GOOGLE)"
        let searchUrl_type = "&type="
        
        for (type, count) in filteredSearchTypes {
            
            if count > 0 {
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
        let ticketmasterUrl_3 = "&apikey=\(KEY_TICKETMASTER)"
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
        let theaterUrl_2 = "&lat=\(lat)&lng=\(lng)&radius=1&api_key=\(KEY_TMS)"
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
    
    func getZomatoID(lat: Double, lng: Double){
        Alamofire.request("https://developers.zomato.com/api/v2.1/cities?lat=\(lat)&lon=\(lng)", headers: ZOMATO_HEADER).responseJSON { response in
            if let Json = response.data{
                let data = JSON(data: Json);
                if let id = data["location_suggestions"][0].dictionary{
                    self.getZomatoRestaurants(id: (id["id"]?.int!)!)
                }
            }
        }
    }
    
    func getZomatoRestaurants(id: Int){
        Alamofire.request("https://developers.zomato.com/api/v2.1/search?entity_id=\(id)&entity_type=city&collection_id=1", headers: ZOMATO_HEADER).responseJSON { response in
            if let Json = response.data{
                let data = JSON(data: Json);
                if let restaurants = data["restaurants"].array{
                    for res in restaurants{
                        let r = res["restaurant"].dictionary!
                        let name = r["name"]!.string!
                        var id = -1

                        if let iden = r["id"]!.int {
                            id = iden
                        }
                        var lat = ""
                        var lng = ""
                        if let location = r["location"]?.dictionary{
                            lat = (location["latitude"]?.string!)!
                            lng = (location["longitude"]?.string!)!
                        }
                        var image = ""
                        if let img = r["thumb"]?.string{
                            image = img
                        }
                        
                        if id != -1 {
                            let nc = NotificationCenter.default
                            nc.post(name:Notification.Name(rawValue:"PLACEINFO"),object: nil, userInfo: ["name":name, "placeID":id.description, "image":image, "type":"restaurant", "lat":lat, "long":lng])
                        }
                    }
                }
            }
        }
    }
    
    func getZomatoInfo(id: String){

        Alamofire.request("https://developers.zomato.com/api/v2.1/restaurant?res_id=\(id)", headers: ZOMATO_HEADER).responseJSON { response in
            if let Json = response.data{
                let data = JSON(data: Json);
                let info = data.dictionary
                
                if let location = info!["location"]?.dictionary {
                    let lat = location["latitude"]?.string!
                    let lng = location["longitude"]?.string!
                    let name = info!["name"]?.string!
                    let cuis = info!["cuisines"]?.string!
                    let curr = info!["currency"]?.string!
                    let price = info!["price_range"]?.int!
                    let avg = info!["average_cost_for_two"]?.int!
                    let menu = info!["menu_url"]?.string!
                    let url = info!["url"]?.string!
                    
                    let place = RestaurantDetail(name: name!, lat: lat!, lng: lng!, serves: cuis!, avg: avg!, price: price!, currency: curr!, menu: menu!, link: url!)
                    
                    self.getRestaurantInfo(place: place)
                }
            }
        }
    }
    
    func getRestaurantInfo(place: RestaurantDetail){
        Alamofire.request("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(place.lat),\(place.lng)&radius=100&type=restaurant&keyword=\(place.name.replacingOccurrences(of: " ", with: ""))&key=\(KEY_GOOGLE)").responseJSON { response in
            if let Json = response.data{
                let data = JSON(data: Json);
                if let results = data["results"].array {
                    var photo = ""
                    let photos = results[0]["photos"].array
                    if let image = photos{
                        photo = image[0]["photo_reference"].string!
                    }
                    photo = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photo)&key=\(self.KEY_GOOGLE)"
                    
                    var open = "N/A"
                    
                    if let hours = results[0]["opening_hours"].dictionary{
                        if hours["open_now"]?.bool == true{
                            open = "Yes!"
                        }
                        else {
                            open = "No :("
                        }
                    }

                    
                    let nc = NotificationCenter.default
                    nc.post(name:Notification.Name(rawValue:"RESTINFO"),object: nil, userInfo: ["place": place, "hours": open, "photo": photo])
                }
            }
        }
    }
    
    func getWeather(wUrl_2: String, countryCode: String){
        let wUrl_1 = "http://api.wunderground.com/api/\(KEY_WEATHER)/hourly/q/"
        var hours = [String]()
        var temps = [String]()
        var pops = [String]()
        var imgs = [String]()
        Alamofire.request(wUrl_1 + wUrl_2).responseJSON { response in
            if let Json = response.data{
                let data = JSON(data: Json);
                if let hourlyForecast = data["hourly_forecast"].array{
                    for hour in hourlyForecast {
                        if let time = hour["FCTTIME"].dictionary{
                            var h = Int((time["hour"]?.string!)!)!
                            let l = 24 - Int(hourlyForecast[0]["FCTTIME"]["hour"].string!)!
                            if h > 12 {
                                h -= 12
                            }
                            else if h == 0 {
                                h = 12
                            }
                            if hours.count < l {
                                hours.append("\(h) " + (time["ampm"]?.string!)!)
                                var temp = ""
                                if countryCode == "US"{
                                    temp = hour["temp"]["english"].string!
                                }
                                else {
                                    temp = hour["temp"]["metric"].string!
                                }
                                let pop = hour["pop"].string!
                                let img = hour["icon_url"].string!
                                
                                temps.append(temp)
                                pops.append(pop)
                                imgs.append(img)
                            }
                            
                        }
                    }
                    let nc = NotificationCenter.default
                    nc.post(name:Notification.Name(rawValue:"WEATHERINFO"),object: nil, userInfo: ["hours": hours, "temps": temps, "pops": pops, "imgs": imgs])
                }
                
            }
        }
    }
    
    func getEventDetail(id: String){
        let ticketMasterUrl = "https://app.ticketmaster.com/discovery/v2/events/\(id).json?apikey=\(KEY_TICKETMASTER)"
        Alamofire.request(ticketMasterUrl).responseJSON { response in
            if let Json = response.data{
                let data = JSON(data: Json);
                
                let url = data["url"].string!
                
                var info = "Info not Available"
                
                if let i = data["info"].string {
                    info = i
                }
                
                var genre = "N/A"
                var priceMin = 0.0
                var priceMax = 0.0
                var saleDate = ""
                var venueImg = ""
                var venueName = ""
                
                if let classifications = data["classifications"].array {
                    let c = classifications[0].dictionary!
                    genre = c["genre"]!["name"].string!
                }
                
                if let sales = data["sales"].dictionary {
                    let p = sales["public"]!.dictionary!
                    saleDate = p["startDateTime"]!.string!
                }
                
                if let priceRanges = data["priceRanges"].array {
                    let r = priceRanges[0].dictionary!
                    priceMin = r["min"]!.double!
                    priceMax = r["max"]!.double!
                }
                
                if let embedded = data["_embedded"].dictionary{
                    if let venues = embedded["venues"]?.array{
                        venueName = venues[0]["name"].string!
                        let im = venues[0]["images"].array!
                        venueImg = im[0]["url"].string!
                    }
                }
                
                
                
                let nc = NotificationCenter.default
                nc.post(name:Notification.Name(rawValue:"EVENTINFO"),object: nil, userInfo: ["url": url, "info": info, "genre": genre, "min": priceMin, "max": priceMax, "saleDate": saleDate, "venueImg": venueImg, "name": venueName])
                
            }
        }
    }
    
}





