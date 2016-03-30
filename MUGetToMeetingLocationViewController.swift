//
//  MUGetToMeetingLocationViewController.swift
//  MeetUp_Swift
//
//  Created by Chongzheng Zhang on 3/02/2016.
//  Copyright © 2016 Chongzheng Zhang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MUGetToMeetingLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var MapView: MKMapView!
   
   
    var selectedMeetingLocationAddress: String!
    var selectedMeetingLocationCoordinate: CLLocationCoordinate2D!
    
    var currentUserAddressCoordinate = CLLocationCoordinate2D()
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Ask for Authorisation from the User. For use in background.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
        
      
        self.MapView.delegate = self
        
        MapView.showsUserLocation = true  // used to show current user location.
        
        NSLog("MapView.userLocation.latitude:%d", MapView.userLocation.coordinate.latitude)
        NSLog("MapView.userLocation.longitude:%d", MapView.userLocation.coordinate  .longitude)
        NSLog("currentUserAddressCoordinate.latitude:%d", currentUserAddressCoordinate.latitude)
        NSLog("currentUserAddressCoordinate.longitude:%d", currentUserAddressCoordinate.longitude)
        
        /* Pass the information of meeting location coordinate to the MUGetToMeetingLocationViewController*/
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(self.selectedMeetingLocationAddress!, completionHandler: {(placemarks, error) -> Void in
            
            NSLog("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
            
            NSLog("Placemark count:%d",(placemarks?.count)!)
            
            
            if((error) != nil)
            {
                NSLog("Error: %@",(error?.description)!)
            }
            
            
            
            if((error) != nil){
                print("Error", error)
            }
            
            
            if let placemark = placemarks?.first {
                self.selectedMeetingLocationCoordinate = placemark.location?.coordinate
                NSLog("selectedMeetingLocationCoordinate.latitude:%d", self.selectedMeetingLocationCoordinate.latitude)
                NSLog("selectedMeetingLocationCoordinate.longitude:%d", self.selectedMeetingLocationCoordinate.longitude)
                
                if ((self.selectedMeetingLocationCoordinate) != nil){
                    
                    /*********Add annotation for destination meeting location to the map view.**************/
                    let span = MKCoordinateSpanMake(0.02, 0.02)
                    
                    let region = MKCoordinateRegionMake(self.selectedMeetingLocationCoordinate, span)
                    
                    self.MapView.setRegion(region, animated: true)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = self.selectedMeetingLocationCoordinate
                    annotation.title = "Meeting location"
                    
                    self.MapView.addAnnotation(annotation)
                    
                    
                    /*******Set route from current location to destination meeting location in the map view. ***********/
                  //  let currentLocationCoordinate: CLLocationCoordinate2D = (self.MapView.userLocation.location?.coordinate)!
                    
                    let request = MKDirectionsRequest()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.currentUserAddressCoordinate.latitude, longitude: self.currentUserAddressCoordinate.longitude), addressDictionary: nil))
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.selectedMeetingLocationCoordinate.latitude, longitude: self.selectedMeetingLocationCoordinate.longitude), addressDictionary: nil))
                    
                    request.requestsAlternateRoutes = true
                    request.transportType = .Automobile
                    
                    let directions = MKDirections(request: request)
                    
                    directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
                        guard let unwrappedResponse = response else { return }
                        
                        for route in unwrappedResponse.routes {
                            
                            self.MapView.addOverlay(route.polyline)
                            self.MapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        } // end of for route in unwrappedResponse.routes
                    }  // end of directions.calculateDirectionsWithCompletionHandler
                }// end of if ((selectedMeetingLocationCoordinate) != nil)
                
                
            }
        })
        


    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        currentUserAddressCoordinate = newLocation.coordinate
        
        self.MapView.showsUserLocation = true
        
        NSLog("didUpdateToLocation-currentUserAddressCoordinate.latitude:%d", self.currentUserAddressCoordinate.latitude)
        NSLog("didUpdateToLocation-currentUserAddressCoordinate.longitude:%d", self.currentUserAddressCoordinate.longitude)
        
        
        //       MKCoordinateRegionMakeWithDistance(currentUserAddressCoordinate, 1000, 1000)
        
        
        let span = MKCoordinateSpanMake(0.02, 0.02)
        
        let region = MKCoordinateRegionMake(currentUserAddressCoordinate, span)
        
        self.MapView.setRegion(region, animated: true)
        
        self.MapView.setCenterCoordinate(currentUserAddressCoordinate, animated: true)
        self.MapView.centerCoordinate = self.currentUserAddressCoordinate
        
        
        locationManager.stopUpdatingLocation()

        
    }

    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3
        return renderer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
