import SwiftUI
import MapKit

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var tapLocation: CLLocationCoordinate2D?
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: .all)
                .gesture(
                    TapGesture()
                        .onEnded { _ in // The closure now doesn't receive any arguments
                            tapLocation = region.center // Use current region as the tap location
                            showAlert = true
                        }
                )

            // Alert
            if let tapLocation = tapLocation {
                Text("Tapped at: \(tapLocation.latitude), \(tapLocation.longitude)")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .position(x: 200, y: 100)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Coordinates Tapped"),
                message: Text("Latitude: \(tapLocation?.latitude ?? 0), Longitude: \(tapLocation?.longitude ?? 0)"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
