//
//  Classes.swift
//  BoredTestFacility
//
//  Created by Chris Castaneda on 5/30/17.
//  Copyright © 2017 Chris Castaneda. All rights reserved.
//

import Foundation
import GooglePlaces

class PlaceInfo{

    var name: String;
    var placeID: String;
    var imageString: String;
    var placeType: String;
    var latitude: String;
    var longitude: String;
    
    init(){
        self.name = "NULL";
        self.placeID = "ChIJN0qhSgJZwokRmQJ-MIEQq08";
        self.imageString = "https://lh3.googleusercontent.com/p/AF1QipO5kFUcS-VPrqLXETgTSfFKUtjYM44IfUWkObNb=s1600-w400";
        self.placeType = "NULL";
        self.latitude = "0.0";
        self.longitude = "0.0";
    }
    
    init(name: String, place: String, image: String, placeType: String, lat: String, long: String){
        self.name = name;
        self.placeID = place;
        self.imageString = image;
        self.placeType = placeType;
        self.latitude = lat;
        self.longitude = long;
    }
}

class MovieDetail {
    var name: String;
    var runtime: String;
    var rating: String;
    var showings: [String];
    var year: Int
    var type: String
    
    init(){
        self.name = "MOVIENAME"
        self.runtime = "0H0M"
        self.rating = "rated_r"
        self.showings = [String]()
        self.year = 2017
        self.type = "N/A"
    }
    
    init(name: String, runtime: String, rating: String, showings: [String], year: Int, type: String) {
        self.name = name
        self.runtime = runtime
        self.rating = rating
        self.showings = showings
        self.year = year
        self.type = type
    }

}

class RestaurantDetail{
    var name: String
    var lat: String
    var lng: String
    var serves: String
    var avg : Int
    var price: Int
    var currency: String
    var menu: String
    var link: String
    
    init(){
        self.name = ""
        self.lat = ""
        self.lng = ""
        self.serves = "rated_r"
        self.avg = 0
        self.price = 0
        self.currency = "N/A"
        self.menu = ""
        self.link = ""
    }
    
    init(name: String, lat: String, lng: String, serves: String, avg: Int, price: Int, currency: String, menu: String, link: String){
        self.name = name
        self.lat = lat
        self.lng = lng
        self.serves = serves
        self.avg = avg
        self.price = price
        self.currency = currency
        self.menu = menu
        self.link = link
    }
    
}

extension UIColor {
    struct BoredColors {
        static let DeepBlue = UIColor(colorLiteralRed: 15.0/255.0, green: 16.0/255.0, blue: 32.0/255.0, alpha: 1.0)
        static let OffWhite = UIColor(colorLiteralRed: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        static let BoredBlue = UIColor(colorLiteralRed: 66.0/255.0, green: 72.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        static let SilverScrapes = UIColor(hue: 201.0, saturation: 23.0, brightness: 59.0, alpha: 1.0)
        static let SalmonForDinner = UIColor(hue: 0.0, saturation: 5.0, brightness: 95.0, alpha: 1.0)
    }
}






