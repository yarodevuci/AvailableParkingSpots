//
//  MapViewController.swift
//  zotDinning
//
//  Created by Yaro on 12/3/15.
//  Copyright © 2015 Yaro. All rights reserved.
//

import UIKit
import MapKit
import Parse
import CoreLocation

class MapViewController: UIViewController, UITabBarDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var Map: MKMapView!
    
    var locationManager: CLLocationManager!
    var SpotNames = [String]()
    var SpotGeoPoints = [PFGeoPoint]()
    var SpotLocationLatitudes = [CLLocationDegrees]()
    var SpotLocationLongitudes = [CLLocationDegrees]()
    
    
    func displayParkingSpots() {
        
        let query:PFQuery = PFQuery(className: "parkingLocations")
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
            if !(error != nil){
                for object in objects!   {
                    self.SpotNames.append(object["SpotNames"] as! String)
                    self.SpotGeoPoints.append(object["longitude"] as! PFGeoPoint)
                    self.SpotLocationLatitudes.append(self.SpotGeoPoints.last?.latitude as CLLocationDegrees!)
                    self.SpotLocationLongitudes.append(self.SpotGeoPoints.last?.longitude as CLLocationDegrees!)
                    
                  //  let pulsator = Pulsator()
                    
                    var annotation = MKAnnotationView()
//                    annotation.coordinate = CLLocationCoordinate2DMake(self.SpotLocationLatitudes.last!, self.SpotLocationLongitudes.last!)
//                    annotation.title = self.SpotNames.last!
//                    annotation.layer
                  //  annotation.imageName = "currentLocation.png"
                //    self.Map.addAnnotation(annotation)
                    self.Map.showsUserLocation = true
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayParkingSpots()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        Map.mapType = MKMapType.Standard
        Map.showsUserLocation = true
        
        
    }
    
    
    @IBAction func myCurrentLocationButton(sender: AnyObject) {
        displayParkingSpots()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        Map.mapType = MKMapType.Standard
        Map.showsUserLocation = true
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.Map.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    @IBAction func logOutButton(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
            PFUser.logOut()
            self.goToAnotherScreen("LoginDisplay")
        }
    }
    func goToAnotherScreen (viewController: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(viewController)
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
