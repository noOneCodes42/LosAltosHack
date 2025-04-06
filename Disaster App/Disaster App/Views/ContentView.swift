import SwiftUI
import MapKit
import RealmSwift

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var apiService = APIService()
    @StateObject private var locationReporter = LocationIncidentReporter()
    @StateObject private var webSocketHandler = WebSocketHandler()
    @StateObject private var disasterReport = DisasterReport()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showAlert = false
    @State private var showResponseAlert = false
    @State private var showResultForNext = false
    @State private var reporterStuff: String = ""
    @State private var id1: String = ""
    @State private var reportingShownTrue = false
    @State private var locationMessage2 = ""
    @State private var isLoading = true
    @State var destination = ""
    @State private var popUp = false
    @State private var goToChatView = false
    @State private var hasDisplayedPopUp = false // Track if pop-up has been shown
    @State var idForChat: String? = nil  // Variable to hold the chat id
    @State var disaster: String = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                        .task {
                            await loadInitialData()
                        }
                } else {
                    VStack {
                        Map(position: $position) {
                            UserAnnotation()
                        }
                        .overlay {
                            Image(systemName: "person.circle.fill")
                                .padding(.top, 750)
                                .padding(.trailing, 300)
                                .font(.largeTitle)
                                .foregroundStyle(.red)
                                .padding(.bottom, 50)
                                .onTapGesture {
                                    showResultForNext = true
                                }
                            
                            Image(systemName: "plus.circle.fill")
                                .padding(.top, 750)
                                .padding(.leading, 300)
                                .padding(.bottom, 50)
                                .font(.largeTitle)
                                .onTapGesture {
                                    withAnimation {
                                        showAlert = true
                                    }
                                }
                                .foregroundStyle(.blue)
                            
                            if showResultForNext {
                                Color.black.opacity(0.4).ignoresSafeArea()
                                CustomReporterView(
                                    title: "Reporter ID",
                                    message: "Type in your reporter id"
                                ) { result in

                                    webSocketHandler.sendMessage("{\"reporter\": \"\(result)\"}")
                                    reporterStuff = result
                                    showResultForNext = false
                                } onCancel: {
                                    showResultForNext = false
                                }
                            }
                            
                            if showAlert {
                                Color.black.opacity(0.4).ignoresSafeArea()
                                CustomAlert(
                                    title: "🚨 Report Disaster 🚨",
                                    message: "What disaster?",
                                    onConfirm: { disasterType in
                                        
    
                                        
                                        disasterReport.disasterName = disasterType
                                        
                                        let coordinates = [locationManager.longitude, locationManager.latitude]
                                        let userModel = Model1(coordinates: coordinates, disaster: disasterType)
                                        apiService.createUser(user: userModel)
                                        
                                        let disasterMessage = """
                                        {"report": {"reporter": "\(reporterStuff)", "id": "\(id1)", "coordinates": {
                                            "longitude": \(locationManager.longitude),
                                            "latitude": \(locationManager.latitude)
                                        }, "status": "approved", "disaster": "\(disasterReport.disasterName)"}}
                                        """
                                        webSocketHandler.sendMessage(disasterMessage)
                                        
                                        showAlert = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            showResponseAlert = true
                                        }
                                    },
                                    onCancel: { showAlert = false }
                                )
                            }
                        }
                        .mapControls {
                            MapUserLocationButton()
                            MapPitchToggle()
                        }
                        
                        // .alert() for report received
                        .alert("Report Received", isPresented: $reportingShownTrue) {
                            Button("Approve") {
                                locationMessage2 = """
                                {"report": {"reporter": "\(reporterStuff)", "id": "\(id1)", "coordinates": {
                                    "longitude": \(locationManager.longitude),
                                    "latitude": \(locationManager.latitude)
                                }, "status": "approved", "disaster": "\(disasterReport.disasterName)"}}
                                """
                                webSocketHandler.sendMessage(locationMessage2)
                                reportingShownTrue = false
                            }
                            Button("Don't approve", role: .cancel) {
                                id1 = ""
                                reportingShownTrue = false
                            }
                        } message: {
                            Text("""
                            Report ID \(id1)
                            Coordinates:
                              Longitude: \(locationManager.longitude)
                              Latitude: \(locationManager.latitude)
                            Disaster: \(disasterReport.disasterName)
                              Status Pending...
                            """)
                        }
                        
                        // .alert() for disaster incoming
                        .alert("Disaster Incoming", isPresented: $popUp) {
                            HStack {
                                Button("Ok", role: .cancel) {
                                    webSocketHandler.sendMessage("no_message")
                                }
                                Button("Chat") {
                                    // Update the state to trigger navigation to ChatInterface
                                    if let receivedId = webSocketHandler.receivedMessage.split(separator: "_").last {
                                        idForChat = String(receivedId) // Store the id for chat
                                    }
                                        goToChatView = true // Activate navigation to ChatInterface
                                }
                            }
                        } message: {
                            Text("Report of \(disaster)")
                        }
                        
                        // .alert() for "Thank You" response
                        .alert("Thank You", isPresented: $showResponseAlert) {
                            Button("OK", role: .cancel) { showResponseAlert = false }
                        } message: {
                            Text(apiService.responseMessage.isEmpty ? "Successfully reported to server" : apiService.responseMessage)
                                .foregroundColor(.green)
                        }
                        
                        // NavigationDestination using state for navigation
                        .navigationDestination(isPresented: $goToChatView) {
                            if let id = idForChat {
                                ChatInterface(id: id)
                                // Passing the chat ID to the destination view
                            }
                            
                        }
                        .onAppear{
                            
                        }
                    }
                }
            }
            .onAppear {
                do{
                    let realm = try Realm()
                    let storedStuff = realm.objects(RealmModel.self)
                    
                    webSocketHandler.connect()
                    if !storedStuff.isEmpty{
                        webSocketHandler.sendMessage("""
    {"reporter": "\(storedStuff.last?.reporterID ?? "")"}
    """)
                    }
                } catch {
                    print(error.localizedDescription)
                }
                startUpdatingLocationsUpdate()
                startUpdatingLocationsUpdateUpdate()
            }
            .environmentObject(disasterReport)
        }
    }
    
    func loadInitialData() async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            isLoading = false
        } catch {
            print("❌ Error loading initial data:", error.localizedDescription)
        }
    }
    
    func startUpdatingLocationsUpdateUpdate() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            webSocketHandler.sendMessage("""
            {"coordinates": {"longitude": \(locationManager.longitude), "latitude": \(locationManager.latitude)}}
            """)
        }
    }
    
    func startUpdatingLocationsUpdate() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if webSocketHandler.receivedMessage.contains("Report:")
                && !reportingShownTrue
                && locationManager.longitude != 0.0
                && locationManager.latitude != 0.0 {
                
                let idComponents = webSocketHandler.receivedMessage.split(separator: ": ")
                
                if idComponents.count > 1 {
                    id1 = String(idComponents[1])
                    
                    locationMessage2 = """
                    {"reporter": "\(reporterStuff)", "id": "\(id1)", "coordinates": {
                        "longitude": \(locationManager.longitude),
                        "latitude": \(locationManager.latitude),
                        "status": "pending"
                    }}
                    """
                    reportingShownTrue = true
                    webSocketHandler.receivedMessage = ""
                }
            }
            
            // Check for "disaster" in the received message and trigger the pop-up once
            if webSocketHandler.receivedMessage.contains("disaster") && !hasDisplayedPopUp {
                popUp = true
                let parts = webSocketHandler.receivedMessage.split(separator: "_")
                // Extract and pass the ID for chat
                disaster = parts[1..<parts.count-1].joined(separator: "_")
                goToChatView = true  // Activate navigation
                hasDisplayedPopUp = true // Prevent pop-up from showing again
            }
        }
    }
}


