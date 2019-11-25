//
//  LocationManager.swift
//  DemoApp
//
//  Created by Macbook on 23/11/19.
//  Copyright © 2019 Prabhjot Singh. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject {
    
    static let sharedManager = LocationManager()
    fileprivate var locationManager: CLLocationManager!
    
    var currentLocation: CLLocation!
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance: Double = 0
    
    func initializeLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
        
    }
    
    func stopLocationUpdates()  {
        locationManager.stopUpdatingLocation()
        startLocation = nil
        traveledDistance = 0
        lastLocation = CLLocation()
        currentLocation = CLLocation()
        locationManager = CLLocationManager()
    }
    
   
    private func notifyLocationAvailability(placemark: CLPlacemark, latLongs: CLLocation) {
        
        guard let LMCity = placemark.locality else {
            print("no location details")
            return
        }
       
        do {
            
            let locationDetails = ["city": LMCity] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name("LocationUpdates"), object: nil, userInfo: locationDetails)
        }
        
    }
    
}

// MARK: - Core Location Delegate
extension LocationManager: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
    
        case .notDetermined         : print("notDetermined")        // location permission not asked for yet
        case .authorizedWhenInUse   : print("authorizedWhenInUse")  // location authorized
        case .authorizedAlways      : print("authorizedAlways")     // location authorized
        case .restricted            : print("restricted")           // TODO: handle
        case .denied                : print("denied")               // TODO: handle
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           
           if startLocation == nil {
               startLocation = locations.first
           } else if let location = locations.last {
               traveledDistance += lastLocation.distance(from: location) * 0.000621371
           }
           lastLocation = locations.last
           
           // 10 kms logic implementation
           if traveledDistance > 10.0{
               traveledDistance = 0
               self.locationManager?.startUpdatingLocation()
               return
           } else if traveledDistance <= 0.1{
                 let location: AnyObject? = (locations as NSArray).lastObject as AnyObject?
                               
                               self.currentLocation = location as? CLLocation
                               
                               CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
                                   
                                   if (error != nil) {
                                       print("reverseGeoCode error")
                                       return
                                   }
                                   
                                   if placemarks!.count > 0 {
                                       
                                       let pm = placemarks![0] as CLPlacemark
                                       self.notifyLocationAvailability(placemark: pm, latLongs: self.currentLocation!)
                                       
                                   } else {
                                        print("no placemarker")
                                   }
                        })
                           
               }
           
       }

}

/*
// MARK: - Get Location
extension LocationManager {
    
    
    func getLocation(forPlaceCalled name: String,
                     completion: @escaping(CLLocation?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { placemarks, error in
            
            guard error == nil else {
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                completion(nil)
                return
            }
            
            guard let location = placemark.location else {
                completion(nil)
                return
            }

            completion(location)
        }
    }
}
 */
