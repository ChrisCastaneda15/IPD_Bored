package com.bored.chris.bored;

import android.content.Intent;
import android.location.Address;
import android.location.Geocoder;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

import java.io.IOException;
import java.util.List;
import java.util.Locale;

import it.sephiroth.android.library.picasso.Picasso;

public class DetailActivity extends AppCompatActivity{

    PlaceInfo place;
    double[] lnl;
    GoogleMap map;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_detail);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        final MapView mapView = (MapView) findViewById(R.id.mapView2);
        mapView.onCreate(savedInstanceState);

        place = (PlaceInfo) getIntent().getSerializableExtra("PLACEDEET");
        lnl = getIntent().getDoubleArrayExtra("LNL");

        setTitle(place.getName());

        ImageView imageView = (ImageView) findViewById(R.id.imageView_place);

        Picasso.with(DetailActivity.this)
                .load(place.getImageString())
                .resize(375, 211)
                .centerCrop()
                .placeholder(R.drawable.placeholder)
                .error(R.drawable.placeholder)
                .into(imageView);
        final TextView textView = (TextView) findViewById(R.id.textView_address);

        Geocoder geocoder = new Geocoder(this, Locale.getDefault());

        List<Address> addresses;
        try {
            addresses = geocoder.getFromLocation(Double.parseDouble(place.latitude), Double.parseDouble(place.longitude), 1);
            String ad = addresses.get(0).getAddressLine(0);

            textView.setText(ad);

        } catch (IOException e) {
            e.printStackTrace();
        }

        MapsInitializer.initialize(this);

        mapView.getMapAsync(new OnMapReadyCallback() {
            @Override
            public void onMapReady(GoogleMap googleMap) {
                map = googleMap;
                map.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(Double.parseDouble(place.latitude), Double.parseDouble(place.longitude)), 15));
                MarkerOptions marker = new MarkerOptions();
                marker.position(new LatLng(Double.parseDouble(place.latitude), Double.parseDouble(place.longitude)));
                marker.alpha((float) 0.8);
                marker.title(place.getName());
                marker.snippet(String.valueOf(textView.getText()));
                map.addMarker(marker);
            }
        });



        TextView textView1 = (TextView) findViewById(R.id.textView_placeType);
        textView1.setText(place.getPlaceType());

        findViewById(R.id.button3).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String uri = "http://maps.google.com/maps?saddr=" + lnl[0] + "," + lnl[1] + "&daddr=" + place.getLatitude() + "," + place.getLongitude();
                Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(uri));
                startActivity(intent);
            }
        });
    }

}
