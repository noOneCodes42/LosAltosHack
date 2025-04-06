import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var apiService = APIService()  // Add APIService to observe changes
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),  // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showAlert = false
    @State private var showResponseAlert = false  // State for showing response alert
    @StateObject private var webSocketHandler = WebSocketHandler()
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            
        }
        .overlay {

            Image(systemName: "plus.circle.fill")
                .padding(.top, 750)
                .padding(.leading, 300)
                .font(.largeTitle)
                .onTapGesture {
                    withAnimation {
                        showAlert = true
                    }

                }
                .foregroundStyle(.blue)
            
            if showAlert {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                CustomAlert(
                    title: "🚨 Report Disaster 🚨",
                    message: "What disaster?",
                    onConfirm: { disasterType in
                        let coordinates = [locationManager.longitude, locationManager.latitude]
                        let userModel = Model1(coordinates: coordinates, disaster: disasterType)
                        
                        // Call the API to send data
                        apiService.createUser(user: userModel)
                        
                        // Hide the alert
                        showAlert = false
                        
                        // Show response alert after API call completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {  // Delay for realism
                            showResponseAlert = true
                        }
                    },
                    onCancel: {
                        showAlert = false
                    }
                )

            }
        }
        .mapControls {
            MapUserLocationButton()
            MapPitchToggle()
            
        }
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
            webSocketHandler.connect()
            startUpdatingLocationsUpdate()

        }

        .alert("Thank You", isPresented: $showResponseAlert) {  // Show response alert
            
            Button("OK", role: .cancel) {
                showResponseAlert = false
            }
        } message: {
            Text(apiService.responseMessage.isEmpty ? "Successfully reported to server" : apiService.responseMessage)
                .padding()
                .foregroundColor(.green)
        }
    }
    func startUpdatingLocationsUpdate(){
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            let message =         """
            {"coordinates": {"longitude": "\(locationManager.longitude)", "latitude": "\(locationManager.latitude)"}}
            """
            webSocketHandler.sendMessage(message)

        }
    }
}

#Preview {
    ContentView()
}
