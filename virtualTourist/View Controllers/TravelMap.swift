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
        populatePins()
    }

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBAction func longPressedOnMap(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: mapView)
        let locCoord = mapView.convert(location, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            
            let pinAnnotation = MKPointAnnotation()
            pinAnnotation.coordinate = locCoord
            
            print(" Coordinate: \(locCoord.latitude),\(locCoord.longitude)")
            
            mapView.addAnnotation(pinAnnotation)
            savePin(lat: locCoord.latitude, long: locCoord.longitude)
        }
    }
    
    
    func populatePins(){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do{
            let results = try CoreDataManager.getContext().fetch(fetchRequest)
            print("found \(results.count) pins")
            var annotations = [MKPointAnnotation]()
            for pin in results as[Pin]{
                let lat = CLLocationDegrees(pin.latitude)
                let long = CLLocationDegrees(pin.longitude)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotations.append(annotation)
            }
            
            DispatchQueue.main.async {
                self.mapView.addAnnotations(annotations)
            }
        }
        catch{
             print("Error getting pins: \(error)")
        }
    }
    
    
    func savePin(lat: CLLocationDegrees, long: CLLocationDegrees) {

        let managedContext =
            CoreDataManager.getContext()
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Pin",
                                       in: managedContext)!
        
        let pin = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        let doubleLat = Double(lat)
        let doubleLong = Double(long)
        pin.setValue(doubleLat, forKey: "latitude")
        pin.setValue(doubleLong, forKeyPath: "longitude")
        
        CoreDataManager.saveContext()
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        let lat = view.annotation?.coordinate.latitude
        let lon = view.annotation?.coordinate.longitude
        print("The selected pin's lat:\(String(describing: lat)), lon:\(String(describing: lon))")
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let searchResults = try CoreDataManager.getContext().fetch(fetchRequest)
            for pin in searchResults as [Pin] {
                if pin.latitude == lat!, pin.longitude == lon! {
                    let selectedPin = pin
                    print("Found pin")
                
                    DispatchQueue.main.async {
                         self.performSegue(withIdentifier: "seeLocationPhotos", sender: selectedPin)
                    }
                }
            }
        }
        catch {
            print("Error: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //TODO: send an NSManagedObject instead of just the coordinates
        if segue.destination is LocationPhotos
        {
            if let vc = segue.destination as? LocationPhotos{
                let selectedPin = sender as! Pin
                vc.selectedPin = selectedPin
            }
        }
    }
}

