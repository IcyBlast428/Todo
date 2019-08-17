//
//  LocationViewController.swift
//  Todo
//
//  Created by IcyBlast on 30/5/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol backCoordinateProtocol_Location_Details    // back protocol to details page
{
    func coordinateFunc_Location_Details(longitude: CLLocationDegrees, latitude:CLLocationDegrees)
}

class LocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate
{
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var setLongitude: CLLocationDegrees? = nil
    var setLatitude: CLLocationDegrees? = nil
    var locationDelegate: backCoordinateProtocol_Location_Details?

    @IBOutlet weak var locationViewControllerMKMapView: MKMapView!
    
    func requestLocationAccess()
    {
        let status = CLLocationManager.authorizationStatus()    // get the authorizatino from the users
        switch status
        {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .denied, .restricted:
            print("location access denied")
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        requestLocationAccess()
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        currentLocation = locations.last!
        let Center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let Span = MKCoordinateSpanMake(0.02, 0.02)
        locationViewControllerMKMapView.region = MKCoordinateRegionMake(Center, Span)
    }
    
    lazy var geoc :CLGeocoder = {
        return CLGeocoder()
    }()
    
    // pick up a location on the map
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        //if there is no annotation on the map
        if touches.count == 0
        {
            let point = touches.first?.location(in:locationViewControllerMKMapView)
            let coordinate = locationViewControllerMKMapView.convert(point!, toCoordinateFrom:locationViewControllerMKMapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).coordinate
            setLongitude = coordinate.longitude // get the longitude
            setLatitude = coordinate.latitude   // get the latitude
            self.locationViewControllerMKMapView.addAnnotation(annotation)  // put the annotation on the map
        }
        else    // if there is already annotation on the map
        {
            let annotations = locationViewControllerMKMapView.annotations
            locationViewControllerMKMapView.removeAnnotations(annotations)  // delete the previous annotatoin
            let point = touches.first?.location(in:locationViewControllerMKMapView)
            let coordinate = locationViewControllerMKMapView.convert(point!, toCoordinateFrom:locationViewControllerMKMapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).coordinate
            setLongitude = coordinate.longitude
            setLatitude = coordinate.latitude
            self.locationViewControllerMKMapView.addAnnotation(annotation)
        }
    }
    
    // back the longitude and latitude value to the detailds page
    override func viewWillDisappear(_ animated: Bool)
    {
        self.locationDelegate?.coordinateFunc_Location_Details(longitude: setLongitude!, latitude: setLatitude!)
    }

}
