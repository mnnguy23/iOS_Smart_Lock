//
//  ManagementViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 11/14/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit
import MapKit

class ManagementViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var lock:Lock?
    let regionRadius: CLLocationDistance = 1000
    var mapPin: MapPin?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        centerMap()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func back(_ sender: Any) {
        mapView.removeAnnotation(mapPin!)
        self.dismiss(animated: true, completion: nil)
    }
    
    func centerMap() {
        if let currentLock = lock {
            CLGeocoder().geocodeAddressString(currentLock.location, completionHandler: {placemarks, error in
                if error != nil {
                    print(error)
                    return
                }
                if let placemarks = placemarks {
                    if placemarks.count > 0 {
                        let placemark = placemarks[0]
                        let location = placemark.location!
                        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, self.regionRadius * 3.0, self.regionRadius * 3.0)
                        self.mapPin = MapPin(coordinate: location.coordinate, title: currentLock.name, subtitle: currentLock.location, islocked: currentLock.locked)
                        self.mapView.setRegion(coordinateRegion, animated: true)
                        self.mapView.addAnnotation(self.mapPin!)
                        self.mapView.reloadInputViews()
                    }
                }
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapPin {
            let identifier = "pin"
            let view: MKPinAnnotationView =  MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                let button = UIButton(type: .roundedRect)
                view.rightCalloutAccessoryView = button
                if annotation.islocked {
                    view.pinTintColor = UIColor.green
                } else {
                    view.pinTintColor = UIColor.red
                }
                view.canShowCallout = true
                return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    }
}
