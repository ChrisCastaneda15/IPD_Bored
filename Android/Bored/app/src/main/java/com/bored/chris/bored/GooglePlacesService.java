package com.bored.chris.bored;

import android.app.IntentService;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class GooglePlacesService extends IntentService {

    private String lat;
    private String lon;

    final String KEY_GOOGLE = "AIzaSyCpmvfI0yYJRIx04H1rhVIIB4ywEgw4I5w";
    final String KEY_TICKETMASTER = "2oeLG86JkAZfAOuAWSLCaZniWyzFKTfO";

    public GooglePlacesService() {
        super("GooglePlacesService");
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        lat = intent.getStringExtra("GPSLAT");
        lon = intent.getStringExtra("GPSLON");

        Log.e("onHandleIntent: ", lat + " " + lon);

        final String searchUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + lat + "," + lon  + "&type=";
        final String searchUrl2 = "&radius=" + 40233.5 + "&key=" + KEY_GOOGLE;

        String eventURL = "https://app.ticketmaster.com/discovery/v2/events.json?size=10&latlong=" + lat + "," + lon + "&radius=20&apikey=" + KEY_TICKETMASTER;

        parseGooglePlaces(getGooglePlaces(searchUrl + "movie_theater" + searchUrl2), "movie_theater", 10);
        parseGooglePlaces(getGooglePlaces(searchUrl + "museum" + searchUrl2), "museum", 10);
        parseGooglePlaces(getGooglePlaces(searchUrl + "bowling_alley" + searchUrl2), "bowling_alley", 3);
        parseGooglePlaces(getGooglePlaces(searchUrl + "cafe" + searchUrl2), "cafe", 10);
        parseGooglePlaces(getGooglePlaces(searchUrl + "library" + searchUrl2), "library", 10);
        parseGooglePlaces(getGooglePlaces(searchUrl + "night_club" + searchUrl2), "night_club", 5);
        parseGooglePlaces(getGooglePlaces(searchUrl + "shopping_mall" + searchUrl2), "shopping_mall", 10);
        parseGooglePlaces(getGooglePlaces(searchUrl + "park" + searchUrl2), "park", 8);
        parseEvents(getEvents(eventURL), "event");
    }

    private String getGooglePlaces(String u){
        try {
            URL url = new URL(u);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();

            try (InputStream is = connection.getInputStream()) {
                connection.connect();
                return IOUtils.toString(is);

            } catch (IOException e) {
                e.printStackTrace();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    private void parseGooglePlaces(String data, String type, int count){
        if (!data.equals("")){

            try {
                JSONObject main = new JSONObject(data);
                JSONArray results = main.getJSONArray("results");

                int num = results.length();

                if (count < num){
                    num = count;
                }

                for (int i = 0; i < num; i++) {
                    String photo;

                    JSONObject result = (JSONObject) results.get(i);

                    if (result.has("photos")) {
                        JSONObject ps = (JSONObject) result.getJSONArray("photos").get(0);
                        photo = ps.getString("photo_reference");
                        photo = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + photo + "&key=" + KEY_GOOGLE;
                    }
                    else {
                        photo = "N/A";
                    }

                    String name = result.getString("name");
                    String id = result.getString("place_id");



                    String lat_place;
                    String lon_place;

                    JSONObject g = result.getJSONObject("geometry").getJSONObject("location");

                    lat_place = Double.toString(g.getDouble("lat"));
                    lon_place = Double.toString(g.getDouble("lng"));

                    Intent intent = new Intent(MainActivity.UPDATE_PLACES);
                    intent.putExtra("place", new PlaceInfo(name, id, photo, type, lat_place, lon_place));
                    sendBroadcast(intent);

                }

            } catch (Exception e) {
                e.printStackTrace();
                Toast.makeText(this, "Movie/Show Not Found", Toast.LENGTH_SHORT).show();
            }
        }
    }

    private String getEvents(String u){
        try {
            URL url = new URL(u);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();

            try (InputStream is = connection.getInputStream()) {
                connection.connect();
                return IOUtils.toString(is);

            } catch (IOException e) {
                e.printStackTrace();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    private void parseEvents(String data, String type){
        if (!data.equals("")){

            try {
                JSONObject main = new JSONObject(data);

                JSONObject embedded = main.getJSONObject("_embedded");
                JSONArray events = embedded.getJSONArray("events");

                for (int i = 0; i < events.length(); i++) {
                    JSONObject event = events.getJSONObject(i);
                    String name = event.getString("name");
                    String id = event.getString("id");
                    String pic = "N/A";

                    if (event.has("images")){
                        JSONArray images = event.getJSONArray("images");

                        for (int j = 0; j < images.length(); j++) {
                            JSONObject img = images.getJSONObject(j);
                            if (img.getInt("width") == 1024 && img.getString("ratio") == "16_9"){
                                pic = img.getString("url");
                            }
                        }
                        if (pic == "N/A"){
                            pic = images.getJSONObject(0).getString("url");
                        }

                    }

                    String lat_place = "0.0";
                    String lon_place = "0.0";

                    if (event.has("_embedded")){
                        JSONObject embed = event.getJSONObject("_embedded");
                        if (embed.has("venues")){
                            JSONArray ven = embed.getJSONArray("venues");
                            JSONObject v = ven.getJSONObject(0).getJSONObject("location");
                            lat_place = v.getString("latitude");
                            lon_place = v.getString("longitude");
                        }
                    }

                    Intent intent = new Intent(MainActivity.UPDATE_PLACES);
                    intent.putExtra("place", new PlaceInfo(name, id, pic, type, lat_place, lon_place));
                    sendBroadcast(intent);

                }

            } catch (Exception e) {
                e.printStackTrace();
                Toast.makeText(this, "Movie/Show Not Found", Toast.LENGTH_SHORT).show();
            }
        }
    }

}
