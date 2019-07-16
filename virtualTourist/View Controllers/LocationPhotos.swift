//
//  LocationPhotos.swift
//  virtualTourist
//
//  Created by Kevin Veldkamp on 7/9/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationPhotos: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    var coordinatesToUse = CLLocationCoordinate2D()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("here are the coords \(coordinatesToUse)")
        loadPinOnMap()
        loadPhotos()
    }
    
    
    
    
    
    @IBAction func getNewCollection(_ sender: UIButton) {
        getFlickrPhotos(coordinatesToUse)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func loadPinOnMap(){
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = coordinatesToUse
        mapView.addAnnotation(pinAnnotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: pinAnnotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func loadPhotos(){
        getFlickrPhotos(coordinatesToUse)
    }
    
    func getFlickrPhotos(_ coordinates: CLLocationCoordinate2D){
        NetworkingManager.getPhotosByLocation(lat: coordinates.latitude, lon: coordinates.longitude)
    }
    
    
    
    //collectionView methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        
        cell.flickrImage.image = nil
        DispatchQueue.main.async {
            cell.activitySpinner.startAnimating()
        }
        
        
        return cell
    }
    
    
    
}
