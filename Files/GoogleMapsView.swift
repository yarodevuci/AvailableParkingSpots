//
//  GoogleMapsView.swift
//  URBN
//
//  Created by Yaroslav on 5/22/16.
//  Copyright © 2016 Yaro. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse

class Spot: NSObject {
    
    var name: String?
    var geopoint: PFGeoPoint
    var marker: GMSMarker
    
    init(name: String?, geopoint: PFGeoPoint, marker: GMSMarker) {
        self.name = name
        self.geopoint = geopoint
        self.marker = marker
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let aSpot = object as? Spot {
            return (self.geopoint.latitude == aSpot.geopoint.latitude) && (self.geopoint.longitude == aSpot.geopoint.longitude)
        }
        return false
    }
    
}
    func ==(lhs: Spot, rhs: Spot) -> Bool {
    return (lhs.geopoint.latitude == rhs.geopoint.latitude) && (lhs.geopoint.longitude == rhs.geopoint.longitude)
    }

class GoogleMapsView: UIViewController, CLLocationManagerDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var gMapsView: GMSMapView!
    @IBOutlet weak var popAlertView: UIView!
    //MARK: variables
    var didFindMyLocation = false
    var locationManager = CLLocationManager()
    
    var SpotNames = [String]()
    var SpotGeoPoints = [PFGeoPoint]()
    var SpotLocationLatitudes = [CLLocationDegrees]()
    var SpotLocationLongitudes = [CLLocationDegrees]()
    
    var Spots = [Spot]()
    var gameTimer: NSTimer!
    
    func displayParkingSpots() {
        
        var newSpots = [Spot]()
        let query:PFQuery = PFQuery(className: "parkingLocations")
        query.whereKey("ParkingSpotIsEmpty", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
            if !(error != nil) {
                for object in objects! {
                    
                    let geopoint = object["longitude"] as! PFGeoPoint
                    let parkingSpotsPosition = CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude)
                    let marker = GMSMarker(position: parkingSpotsPosition)
                    
                    let newSpot = Spot(name: object["SpotNames"] as? String, geopoint: geopoint, marker: marker)
                    newSpots.append(newSpot)
                    
                    if !self.Spots.contains(newSpot) {
                        print("ADDING MARKER: \(newSpot.name)")
                        self.Spots.append(newSpot)
                        
                        marker.title = newSpot.name
                        //marker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
                        marker.icon = UIImage(named: "parking-location")
                        
                      //  let pulsator = Pulsator()
//                        self.view.layer.addSublayer(pulsator)
//                        pulsator.start()
                        marker.map = self.gMapsView
                    }
                    
                }
                
                for i in (0..<self.Spots.count).reverse() {
                    let spot = self.Spots[i]
                    if !newSpots.contains(spot) {
                        self.Spots.removeAtIndex(i)
                        print("REMOVING MARKER: \(spot.name)")
                        spot.marker.map = nil
                    }
                }
            }
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        gameTimer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        displayParkingSpots()
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(displayParkingSpots), userInfo: nil, repeats: true)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        gMapsView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        gMapsView.myLocationEnabled = true
    }
    
    func goToAnotherScreen (viewController: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(viewController)
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }

    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
            gMapsView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 15.0)
            gMapsView.settings.myLocationButton = true
            gMapsView.settings.compassButton = true
            didFindMyLocation = true
        }
    }
    //MARK: IBActions
    @IBAction func logOutButton(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
            PFUser.logOut()
            self.goToAnotherScreen("LoginDisplay")
        }
    }
    @IBAction func hidePopAlertButton(sender: AnyObject) {
        
        popAlertView.hidden = true
    }
   
}
