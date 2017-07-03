package com.bored.chris.bored;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.media.Image;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.util.Log;
import android.view.View;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.StackView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.HashMap;

import it.moondroid.coverflow.components.ui.containers.FeatureCoverFlow;
import it.sephiroth.android.library.picasso.Picasso;


public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener, LocationListener {

    public static final String UPDATE_PLACES = "com.bored.chris.bored.UPDATE_PLACES";

    String profilePicUrl = "";

    private PlaceBaseAdapter adapter;
    private ArrayList<PlaceInfo> places;
    private StackView coverFlow;
    double[] latandlon;
    private FirebaseAuth mAuth;
    private FirebaseAuth.AuthStateListener mAuthListener;
    private FirebaseUser firebaseUser;
    private DatabaseReference mDatabase;
    private ProgressDialog loading;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        loading = new ProgressDialog(this);
        loading.setCancelable(false);
        loading.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        loading.setMessage("Getting Data...");
        loading.show();

        mAuth = FirebaseAuth.getInstance();
        mDatabase = FirebaseDatabase.getInstance().getReference();

        mAuthListener = new FirebaseAuth.AuthStateListener() {
            @Override
            public void onAuthStateChanged(@NonNull FirebaseAuth firebaseAuth) {
                firebaseUser = firebaseAuth.getCurrentUser();
                if (firebaseUser != null) {
                    // User is signed in
                    Log.e("onAuthStateChanged:", firebaseUser.getEmail());
                    readFromDatabase();

                } else {
                    // User is signed out
                    finish();
                    Toast.makeText(MainActivity.this, "Signed out", Toast.LENGTH_SHORT).show();
                    Log.e("onAuthStateChanged:", "signedOut");
                }
            }
        };

        places = new ArrayList<>();

        latandlon = getLocation();

        coverFlow = (StackView) findViewById(R.id.flipperMain);
        coverFlow.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Log.e("onItemSelected: ", "YO");
                Intent intent = new Intent(MainActivity.this, DetailActivity.class);
                intent.putExtra("PLACEDEET", places.get(position));
                intent.putExtra("LNL", latandlon);
                startActivityForResult(intent, 420);
            }
        });

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Filter", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.setDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);
    }

    @Override
    public void onStart() {
        super.onStart();
        mAuth.addAuthStateListener(mAuthListener);

    }

    @Override
    public void onStop() {
        super.onStop();
        if (mAuthListener != null) {
            mAuth.removeAuthStateListener(mAuthListener);
        }
    }

    private void readFromDatabase(){
        ValueEventListener postListener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                // Get Post object and use the values to update the UI
                if (dataSnapshot.getValue(true) != null){
                    //noinspection unchecked
                    HashMap<String, String> result = (HashMap<String, String>) dataSnapshot.getValue();
                    if (result.size() > 0){
                        for (String key : result.keySet()) {
                            profilePicUrl = result.get(key);
                            NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
                            View hView =  navigationView.getHeaderView(0);
                            TextView nav_user = (TextView)hView.findViewById(R.id.personName);
                            nav_user.setText("Hello, " + firebaseUser.getDisplayName() + "!");
                            ImageView userImg = (ImageView)hView.findViewById(R.id.personImageView);
                            Picasso.with(MainActivity.this)
                                    .load(profilePicUrl)
                                    .resize(60, 60)
                                    .centerCrop()
                                    .placeholder(R.drawable.placeholder)
                                    .error(R.drawable.placeholder)
                                    .into(userImg);
                        }
                    }
                }
                else {
                    Log.e("onDataChange: ", "Nothing to Show");
                }

            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                Log.e("onCancelled: ", databaseError.toString());

            }
        };
        mDatabase.child("users").child(firebaseUser.getUid()).addValueEventListener(postListener);
    }

    private double[] getLocation() {
        double[] latLon;
        Log.e("", "getLocation: " + "yoyoyoyo");
        LocationManager locationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED){

            return null;
        }
        locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 10000, 10, this);
        Location location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
        if (location == null){
            latLon = new double[]{0.0, 0.0};
        }
        else {
            latLon = new double[]{location.getLatitude(), location.getLongitude()};
        }

        Log.e("", "getLocation: " + latLon[0] + " " + latLon[1]);

        return latLon;
    }

    @Override
    protected void onResume() {
        super.onResume();

        IntentFilter filter = new IntentFilter(UPDATE_PLACES);
        registerReceiver(updatePlaces, filter);
    }

    @Override
    protected void onPause() {
        super.onPause();
        unregisterReceiver(updatePlaces);
    }

    public void getInfo(){
        Intent service = new Intent(MainActivity.this, GooglePlacesService.class);
        if (latandlon != null) {
            service.putExtra("GPSLAT", Double.toString(latandlon[0]));
            service.putExtra("GPSLON", Double.toString(latandlon[1]));
        }

        startService(service);
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);

        if (id == R.id.nav_camera) {
            drawer.closeDrawer(GravityCompat.START);
        } else if (id == R.id.nav_gallery) {

        } else if (id == R.id.nav_slideshow) {

        } else if (id == R.id.nav_log) {
            drawer.closeDrawer(GravityCompat.START);
            FirebaseAuth.getInstance().signOut();
        }

        return true;
    }

    private final BroadcastReceiver updatePlaces = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            loading.dismiss();
            PlaceInfo object = (PlaceInfo) intent.getSerializableExtra("place");
            places.add(object);
            TextView tv = (TextView) findViewById(R.id.resultsTV);
            tv.setText("Showing " + places.size() + " result(s)!");
            adapter = new PlaceBaseAdapter(MainActivity.this, places, latandlon);
            coverFlow.setAdapter(adapter);
        }
    };

    @Override
    public void onLocationChanged(Location location) {
        Log.e("onStatusChanged: ", location.getLatitude() + " " + location.getLongitude());
        latandlon[0] = location.getLatitude();
        latandlon[1] = location.getLongitude();
        getInfo();
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {

    }

    @Override
    public void onProviderEnabled(String provider) {

    }

    @Override
    public void onProviderDisabled(String provider) {

    }
}
