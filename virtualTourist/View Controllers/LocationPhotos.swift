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
import CoreData

class LocationPhotos: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    var coordinatesToUse = CLLocationCoordinate2D()
    
    var photos = [Photo]()
    var selectedPin : Pin!
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
        CoreDataManager.saveContext()
        collectionView.reloadData()
    }
    
    func buildAndSetImageURL(_ photo: PhotoObject){
        let url = "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_q.jpg"
        let context = CoreDataManager.getContext()
         let photo:Photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context ) as! Photo
        
        photo.urlString = url
        
        if let url = photo.urlString{
            NetworkingManager.getPicture(url){ data, error in
                guard error == nil else{
                    print("error getting this photo")
                    return
                }
                if let data = data{
                    print("succesfully got photo")
                    DispatchQueue.main.async {
                        photo.imageData = data as NSData?
                    }
                }
            }
        }
    }
    
    
    
    //collectionView methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        
        cell.flickrImage.image = UIImage(named: "VirtualTourist_120.png")
        cell.activitySpinner.startAnimating()
       
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = []
        let context = CoreDataManager.getContext()
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        if let data = fetchedResultsController.fetchedObjects, data.count > 0 {
            print("\(data.count) photos from core data fetched.")
            photos = data
            self.collectionView.reloadData()
        }
    
        
        let photo = photos[indexPath.row]

        if photo.imageData != nil{
            if photos.count > 0 {
                DispatchQueue.main.async {
                    cell.activitySpinner.stopAnimating()
                    cell.activitySpinner.isHidden = true
                    cell.flickrImage.image = UIImage(data: photo.imageData! as Data)
                }
            }
            
        }
        return cell
    }
}


