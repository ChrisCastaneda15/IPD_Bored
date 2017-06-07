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






