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
    
    let locationManager = CLLocationManager()
    let regionMeters: Double = 10000
    var previousLocation: CLLocation?
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
    
    func getCenterLocation(mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension ViewController: MKMapViewDelegate {
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
