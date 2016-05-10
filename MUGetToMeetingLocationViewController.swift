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
   
   
    class myMapAnnotation : NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        var title: String?
        var subtitle: String?
        
        init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
        }
    }
    
    
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
                    
                    //request.requestsAlternateRoutes = true
                    request.requestsAlternateRoutes = false
                    request.transportType = .Automobile
                    
                    let directions = MKDirections(request: request)
                    
                    directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
                        guard let unwrappedResponse = response else { return }
                        
                        
                        for route in unwrappedResponse.routes {
                            
                            self.addEstimatedTimeArrivalToRoute(route)
                            
        
                            self.MapView.addOverlay(route.polyline)


                            self.MapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                            
                            

                        } // end of for route in unwrappedResponse.routes
                    }  // end of directions.calculateDirectionsWithCompletionHandler
                    
                }// end of if ((selectedMeetingLocationCoordinate) != nil)
                
                
            }
        })
        


    }
    
    
    func addEstimatedTimeArrivalToRoute(route: MKRoute) -> Void {
        let points = route.polyline.points()
        
        let leftTime: String = getStandardTimeExpression(route.expectedTravelTime)  // estimated time arrival
        
        
        let midPoint = points[route.polyline.pointCount/2]
        
        let midCoord: CLLocationCoordinate2D = MKCoordinateForMapPoint(midPoint)
        
      //  let annotation = myMapAnnotation(coordinate: midCoord, title: leftTime, subtitle: "")

        let annotation = MKPointAnnotation()
        annotation.coordinate = midCoord
        annotation.title = leftTime
      //  annotation.subtitle = "ETS"
    
        
        self.MapView.addAnnotation(annotation)
        
        self.MapView.selectAnnotation(annotation, animated: true)
        
    }
    
    
    
    func getStandardTimeExpression(leftTime: NSTimeInterval) -> String {
        
        var leftTimeExpression: String
        
        
        let leftMin = (Int)(leftTime/60)
        
        if (leftMin < 60)
        {
            
            leftTimeExpression = String(format:"%d minutes", (Int)(leftTime/60))
        }
        else{
            
            let leftHour = (Int)(leftMin/60)
            let remainMin = (Int)(leftMin%60)
            
            if (leftHour == 1)
            {
                leftTimeExpression = String(format:"%d hour %d minutes", leftHour, remainMin)
            }
            else{
                
                leftTimeExpression = String(format:"%d hours %d minutes", leftHour, remainMin)
            }
            
        }
        
        return leftTimeExpression
        
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
    
        renderer.alpha = 0.7;
        renderer.lineWidth = 4.0;

    
        return renderer
    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)...
            return nil
        }
        
        let reuseId = "test"
        
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if anView == nil {
            anView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            //  anView!.image = UIImage(named:"meetupIcon.png")
           //  anView?.pinColor = getRightPinColor(annotation.title!!)
            
            if #available(iOS 9.0, *) {
                anView?.pinTintColor = getRightPinTintColor(annotation.title!!)
            } else {
                // Fallback on earlier versions
            }
            

            anView!.canShowCallout = true
            
            
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView!.annotation = annotation
        }
        
        if #available(iOS 9.0, *) {
            anView?.rightCalloutAccessoryView = estimatedTimeArrivalCallOut(annotation)
            
            
            
            
        } else {
            // Fallback on earlier versions
        }
        

        return anView
    }
    
    
    func estimatedTimeArrivalCallOut(annotation: MKAnnotation) -> UIView {
        
        let etsUIView = UIView()
        
//        let label = UILabel()
//        
//        label.text = "What is that"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.numberOfLines = 0
//        
//        etsUIView.addSubview(label)
        
        etsUIView.backgroundColor = .greenColor()
        
        
        
        let widthConstraint = NSLayoutConstraint(item: etsUIView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        etsUIView.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: etsUIView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 20)
        etsUIView.addConstraint(heightConstraint)
        
        return etsUIView
        
    }
    
//    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
//        
//        if ((view.annotation?.title)! != "Meeting location")
//        {
//            view.selected = true
//            self.MapView.selectAnnotation(view.annotation!, animated: true)
//        }
//        
//    }
    
    
    
    func getRightPinColor (pinName:String)-> MKPinAnnotationColor{
        
        var correctPin = MKPinAnnotationColor.init(rawValue: 0)
        
        switch pinName
        {
        case "Meeting location":
            correctPin = MKPinAnnotationColor.Red
            break
        default:
            correctPin = MKPinAnnotationColor.Purple
            break
            
        }
        
        return correctPin!
    }
    
    func getRightPinTintColor (pinName:String)-> UIColor{
        
        var correctTintPin = UIColor()
        
        switch pinName
        {
        case "Meeting location":
            correctTintPin = UIColor.redColor()
            break
        default:
            correctTintPin = UIColor.clearColor()
            break
        }
        
        return correctTintPin
    }
    
//
//    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
//
//     //   for view in views {
//        
//          //  view.selected = true
//         //   mapView.selectAnnotation(view.annotation!, animated: true)
//     //  }
//        
//    }
    
    

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
