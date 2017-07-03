package com.bored.chris.bored;


import android.content.Context;
import android.location.Location;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;

import it.sephiroth.android.library.picasso.Picasso;

public class PlaceBaseAdapter extends BaseAdapter {

    private ArrayList<PlaceInfo> data;
    private Context context;
    private double[] latLong;

    public PlaceBaseAdapter(Context context, ArrayList<PlaceInfo> objects, double[] lnl) {
        this.context = context;
        this.data = objects;
        this.latLong = lnl;
    }

    @Override
    public int getCount() {
        return data.size();
    }

    @Override
    public PlaceInfo getItem(int position) {
        return data.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    static class ViewHolder {
        // Views in your item layouts
        public ImageView imageView;
        public TextView name;
        public TextView dist;

        // Constructor that sets the views up.
        public ViewHolder(View v) {
            imageView = (ImageView) v.findViewById(R.id.placeImageView);
            name = (TextView) v.findViewById(R.id.placeNameTextView);
            dist = (TextView) v.findViewById(R.id.placeDistanceTextView);
        }
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        ViewHolder holder;

        convertView = LayoutInflater.from(context).inflate(R.layout.placecoverlayout, parent, false);
        holder = new ViewHolder(convertView);
        convertView.setTag(holder);

        PlaceInfo item = getItem(position);

        char[] characters = item.getName().toCharArray();

        if (holder != null){
            holder.name.setText(item.getName());
            if (characters.length > 30){
                holder.name.setTextSize(20);
            }

            Location loc1 = new Location("");
            loc1.setLatitude(latLong[0]);
            loc1.setLongitude(latLong[1]);

            Location loc2 = new Location("");
            loc2.setLatitude(Double.parseDouble(item.getLatitude()));
            loc2.setLongitude(Double.parseDouble(item.getLongitude()));

            float distanceInMeters = loc1.distanceTo(loc2);

            String d = String.format("%.1f", distanceInMeters / 1609.34);

            holder.dist.setText(d + " miles away!");

            if (item.getImageString().equals("N/A")){
                holder.imageView.setVisibility(View.GONE);
            }
            else {
                Picasso.with(context).load(item.getImageString()).into(holder.imageView);
            }
            convertView.setTag(holder);
        }

        return convertView;
    }
}
