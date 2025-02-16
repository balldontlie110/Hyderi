//
//  QiblaModel.swift
//  Hyderi
//
//  Created by Ali Earp on 12/22/24.
//

import Foundation
import CoreLocation

class QiblaModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    var locationManager: CLLocationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var heading: CLHeading?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.location = location
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    private let qibla = CLLocation(latitude: 21.422487, longitude: 39.826206)
    
    func qiblaHeading() -> CLLocationDirection? {
        guard let location, let heading else { return nil }
        
        let locationLatitude = location.coordinate.latitude.degreesToRadians
        let locationLongitude = location.coordinate.longitude.degreesToRadians
        
        let qiblaLatitude = qibla.coordinate.latitude.degreesToRadians
        let qiblaLongitude = qibla.coordinate.longitude.degreesToRadians
        
        let longitudeDifference = qiblaLongitude - locationLongitude
        
        let y = sin(longitudeDifference) * cos(qiblaLatitude)
        let x = cos(locationLatitude) * sin(qiblaLatitude) - sin(locationLatitude) * cos(qiblaLatitude) * cos(longitudeDifference)
        let bearing = atan2(y, x).radiansToDegrees

        return bearing - heading.trueHeading
    }
}
