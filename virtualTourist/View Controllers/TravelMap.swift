//
//  ViewController.swift
//  virtualTourist
//
//  Created by Kevin Veldkamp on 7/3/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelMap: UIViewController, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
    
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Pin")
        
        do {
            pins = try managedContext.fetch(fetchRequest)
            populatePins()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pins: [NSManagedObject] = []

    var pinAnnotation: MKPointAnnotation? = nil
    
    @IBAction func longPressedOnMap(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: mapView)
        let locCoord = mapView.convert(location, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            
            pinAnnotation = MKPointAnnotation()
            pinAnnotation!.coordinate = locCoord
            
            print("\(#function) Coordinate: \(locCoord.latitude),\(locCoord.longitude)")
            
            mapView.addAnnotation(pinAnnotation!)
            savePin(lat: locCoord.latitude, long: locCoord.longitude)
        }
    }
    
    
    func populatePins(){
        for pin in pins {
            pinAnnotation = MKPointAnnotation()
            pinAnnotation!.coordinate.latitude = (pin.value(forKeyPath: "latitude") as? CLLocationDegrees)!
            pinAnnotation!.coordinate.longitude = (pin.value(forKeyPath: "longitude") as? CLLocationDegrees)!
            mapView.addAnnotation(pinAnnotation!)
        }
    }
    
    
    func savePin(lat: CLLocationDegrees, long: CLLocationDegrees) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Pin",
                                       in: managedContext)!
        
        let pin = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        let doubleLat = Double(lat)
        let doubleLong = Double(long)
        pin.setValue(doubleLat, forKey: "latitude")
        pin.setValue(doubleLong, forKeyPath: "longitude")
        
        do {
            try managedContext.save()
            pins.append(pin)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "seeLocationPhotos", sender: self)
    }
    

}

