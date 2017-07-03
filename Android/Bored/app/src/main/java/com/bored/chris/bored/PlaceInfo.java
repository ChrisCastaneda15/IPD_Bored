package com.bored.chris.bored;

import java.io.Serializable;

public class PlaceInfo implements Serializable {
    String name;
    String placeID;
    String imageString;
    String placeType;
    String latitude;
    String longitude;

    public PlaceInfo() {
        this.name = "NULL";
        this.placeID = "ChIJN0qhSgJZwokRmQJ-MIEQq08";
        this.imageString = "https://lh3.googleusercontent.com/p/AF1QipO5kFUcS-VPrqLXETgTSfFKUtjYM44IfUWkObNb=s1600-w400";
        this.placeType = "NULL";
        this.latitude = "0.0";
        this.longitude = "0.0";
    }

    public PlaceInfo(String name, String placeID, String imageString, String placeType, String latitude, String longitude) {
        this.name = name;
        this.placeID = placeID;
        this.imageString = imageString;
        this.placeType = placeType;
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPlaceID() {
        return placeID;
    }

    public void setPlaceID(String placeID) {
        this.placeID = placeID;
    }

    public String getImageString() {
        return imageString;
    }

    public void setImageString(String imageString) {
        this.imageString = imageString;
    }

    public String getPlaceType() {
        return placeType;
    }

    public void setPlaceType(String placeType) {
        this.placeType = placeType;
    }

    public String getLatitude() {
        return latitude;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }

    public String getLongitude() {
        return longitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }
}
