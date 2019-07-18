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
    
    var photoArray : [Photo] = [Photo]()
    var photoURLArray : [String] = [String]()
    var photoArrayNonCoreData = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("here are the coords \(coordinatesToUse)")
        loadPinOnMap()
        loadPhotos()
        collectionView.reloadData()
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
        NetworkingManager.getPhotosByLocation(lat: coordinates.latitude, lon: coordinates.longitude, completion: handleFlickrSearchResponse(photos:error:))
    }
    
    
    func handleFlickrSearchResponse(photos: [PhotoObject], error: Error?){
        if photos.count > 0 {
            for photo in photos {
                buildAndSetImageURL(photo)
            }
        }
        collectionView.reloadData()
    }
    
    func buildAndSetImageURL(_ photo: PhotoObject){
        let url = "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_q.jpg"
        photoURLArray.append(url)
        NetworkingManager.getPicture(url){ data, error in
            guard error == nil else{
                print("error getting this photo")
                self.photoArrayNonCoreData.append(UIImage(named: "VirtualTourist_120.png")!)
                return
            }
            if let data = data{
                print("succesfully got photo")
                self.photoArrayNonCoreData.append(UIImage(data: data)!)
            }
            
        }
        //set imageURL attribute in coreData
        // build URL and call getDataFromURL and set into collectionView
    }
    
    
    
    //collectionView methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        
        cell.flickrImage.image = UIImage(named: "VirtualTourist_120.png")
        cell.activitySpinner.startAnimating()
       
        
        if photoArrayNonCoreData.count > 0 {
            DispatchQueue.main.async {
                cell.activitySpinner.stopAnimating()
                cell.activitySpinner.isHidden = true
                cell.flickrImage.image = self.photoArrayNonCoreData[0]
            }
        }
        return cell
    }
}


