//
//  ViewController.swift
//  virtualTourist
//
//  Created by Kevin Veldkamp on 7/3/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import UIKit
import MapKit

class TravelMap: UIViewController, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var pinAnnotation: MKPointAnnotation? = nil
    
    
    
    @IBAction func longPressedOnMap(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: mapView)
        let locCoord = mapView.convert(location, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            
            pinAnnotation = MKPointAnnotation()
            pinAnnotation!.coordinate = locCoord
            
            print("\(#function) Coordinate: \(locCoord.latitude),\(locCoord.longitude)")
            
            mapView.addAnnotation(pinAnnotation!)
            
        }
    }
    
    
    
}

