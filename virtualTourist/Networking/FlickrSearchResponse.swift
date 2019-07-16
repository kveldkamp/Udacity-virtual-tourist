//
//  FlickrSearchResponse.swift
//  virtualTourist
//
//  Created by Kevin Veldkamp on 7/16/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import Foundation

struct FlickrSearchResponse: Codable{
    let photos: Photos
    let stat: String
}

struct Photos: Codable{
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [PhotoObject]
}

struct PhotoObject: Codable{
    let id: String
    let server: String
    let secret: String
    let farm: Int
}
