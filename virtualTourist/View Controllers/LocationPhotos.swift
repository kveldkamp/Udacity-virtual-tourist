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

class LocationPhotos: UIViewController{
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    
    
    
    
    @IBAction func getNewCollection(_ sender: UIButton) {
        
    }
    
    
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
