//
//  ViewController.swift
//  MapKT
//
//  Created by Dalvin Sejour on 1/16/19.
//  Copyright © 2019 Dalvin Sejour. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var Gobutton: UIButton!
    @IBOutlet weak var steps: UIButton!
    
    
    let locationManager = CLLocationManager()
    let regionMeters: Double = 10000
    var previousLocation: CLLocation?
    var directionsArray: [MKDirections] = []
    var instructionsArray: [[MKRoute.Step]] = [[]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationService()
        
       
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func centerViewOnUserLocation() {
        if let location =  locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func goButtonTapped(_ sender: UIButton){
        //Get Directions for current user
        getDirections()
    }
    
    //Checks what the loction is used for
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
           startTrackingUserLocation()
        case .denied:
            //Show alert on how to turn on permission
                break
        case .notDetermined:
            // ave not pick
                locationManager.requestWhenInUseAuthorization()
                break
        case .restricted:
            //Cant change app restrictions show an alert
                break
        case .authorizedAlways:
                break
        }
    }
    
    func startTrackingUserLocation() {
        //Do map stuff
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(mapView: mapView)
    }
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    //Check devise wide location settitns
    func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            //setuo our location manager
            setupLocationManager()
            checkLocationAuthorization()
            
        } else {
            // show user an allert to let user to turn on location services
        }
    }

}
//delegate that updates the user location based on current location

extension ViewController: CLLocationManagerDelegate {
    /*
     
     shows current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // We'll be back
        //This returns a list of locations an array perfect for application to list of locations
        guard let location =  locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.latitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
        mapView.setRegion(region, animated: true)

    }*/
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //We'll be back
        checkLocationAuthorization()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "StepViewSegue") {
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destination as! StepsViewController
            // your new view controller should have property that will store passed value
            viewController.instructionArray = instructionsArray
        }
    }
    
    func getCenterLocation(mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    func resetMapView(directions: MKDirections) {
        self.mapView.overlays.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeOverlay($0)
            }
        }
        
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
    func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            // Inform user we do not have their current location
            return
        }
        
        let request = createDirectionRequest(from: location)
        
        let directions =  MKDirections.init(request: request)
        resetMapView(directions: directions)
        resetInstructions()
        directions.calculate {
            [unowned self] (response, error) in
            guard let response = response else{ return } //response not available
            
            for route in response.routes {
                //Add step properties
                //Allow for instructions for the route to be stored
                let steps =  route.steps
                self.instructionsArray.append(steps)
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate =  getCenterLocation(mapView: mapView).coordinate
        
        let startingLocation = MKPlacemark(coordinate: coordinate)
        
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        //change alternate route to true to show multiple paths
        let request = createRequest(startingLocation: startingLocation, destination: destination, transport: .automobile, alternateRoute: false)

        //In order to take directions it take a request
        return request
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (instructionsArray.count < 1) {
            let alert = UIAlertController(title: "Hey", message: "This is  one Alert", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Working!!", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    func createRequest(startingLocation: MKPlacemark, destination: MKPlacemark, transport: MKDirectionsTransportType, alternateRoute: Bool) -> MKDirections.Request{
        let request =  MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = transport
        request.requestsAlternateRoutes = alternateRoute
        return request
    }
    
    func resetInstructions() {
        instructionsArray = [[]]
    }

}




extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay ) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        return renderer
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(mapView: mapView)
        let geoCoder =  CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        //guard against rate limit
        guard center.distance(from: previousLocation) > 50 else { return }
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let _ = error {
                //show alert
                return
            }
            
            guard let placemark = placemarks?.first else {
                //Show allert informing user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
}
