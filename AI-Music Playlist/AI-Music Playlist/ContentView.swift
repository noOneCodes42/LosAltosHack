//
//  ContentView.swift
//  AI-Music Playlist
//
//  Created by Neel Arora on 4/5/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showAlert = false
    var body: some View {
        Map(position: $position){
            UserAnnotation()
        }
        .overlay{
                Image(systemName: "plus.circle")
                    .padding(.top, 750)
                    .padding(.leading, 300)
                    .font(.largeTitle)
                    .onTapGesture{
                        withAnimation{
                            showAlert = true
                        }
                    }
            if showAlert {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showAlert = false
                        }
                    }
                CustomAlert(title: "Report Diasaster", message: "What disaster?", onConfirm: {
                    print("Lat: \(locationManager.latitude), Long: \(locationManager.longitude)")
                    showAlert = false
                }, onCancel: {
                    showAlert = false
                })
            }
        }
        .mapControls{
            MapUserLocationButton()
            MapPitchToggle()
        }
        .onAppear{
            CLLocationManager().requestWhenInUseAuthorization()
            
        }

        
    }
}

#Preview {
    ContentView()
}
