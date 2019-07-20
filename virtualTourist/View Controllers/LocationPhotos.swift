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

class LocationPhotos: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
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
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        loadPhotos()
        collectionView.reloadData()
        
        
        //collection view spacing and setup
        let space: CGFloat = 3.0
        let viewWidth = self.view.frame.width
        let dimension: CGFloat = (viewWidth-(2*space))/3.0
        
        collectionViewLayout.minimumInteritemSpacing = space
        collectionViewLayout.minimumLineSpacing = space
        collectionViewLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    
    @IBAction func getNewCollection(_ sender: UIButton) {
        getFlickrPhotos()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func loadPinOnMap(){
        let pinAnnotation = MKPointAnnotation()
        let lat = CLLocationDegrees(selectedPin.latitude)
        let lon = CLLocationDegrees(selectedPin.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        pinAnnotation.coordinate = coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: pinAnnotation.coordinate, span: span)
        
        DispatchQueue.main.async{
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(pinAnnotation)
        }
        
    }
    
    func loadPhotos(){
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin = %@", selectedPin)
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
        } else {
            getFlickrPhotos()
        }
    }
    
    func getFlickrPhotos(){
        NetworkingManager.getPhotosByLocation(lat: selectedPin.latitude, lon: selectedPin.longitude, completion: handleFlickrSearchResponse(results:error:))
        collectionView.reloadData()
    }
    
    
    func handleFlickrSearchResponse(results: [PhotoObject], error: Error?){
        if results.count > 0 {
            for result in results {
                buildAndSetImageURL(result)
            }
        }
    }
    
    func buildAndSetImageURL(_ result: PhotoObject){
        let url = "https://farm\(result.farm).staticflickr.com/\(result.server)/\(result.id)_\(result.secret)_q.jpg"
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
                        photo.pin = self.selectedPin
                        self.photos.append(photo)
                         CoreDataManager.saveContext()
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    
    
    //collectionView methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        
        let photo = photos[indexPath.row]
        cell.flickrImage.image = UIImage(named: "VirtualTourist_120.png")
        cell.activitySpinner.startAnimating()
    
        if photo.imageData != nil{
            DispatchQueue.main.async {
                cell.activitySpinner.stopAnimating()
                cell.activitySpinner.isHidden = true
                cell.flickrImage.image = UIImage(data: photo.imageData! as Data)
            }
        }
        else{
            if let url = photo.urlString{
                NetworkingManager.getPicture(url, {data, error in
                    guard error != nil else {
                        print("error getting photos")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        photo.imageData = data as NSData?
                        cell.activitySpinner.stopAnimating()
                        cell.activitySpinner.isHidden = true
                        cell.flickrImage.image = UIImage(data: photo.imageData! as Data)
                    }
            })
        }
    }
    return cell
}
}


