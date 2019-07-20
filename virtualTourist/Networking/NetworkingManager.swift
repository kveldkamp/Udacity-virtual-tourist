//
//  NetworkingManager.swift
//  virtualTourist
//
//  Created by Kevin Veldkamp on 7/9/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import Foundation


class NetworkingManager {
    
    
    class func taskForGETRequest<ResponseType:Decodable>(urlRequest: URLRequest, response: ResponseType.Type, completion: @escaping (ResponseType?,Error?) -> Void){
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if error != nil{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                if let data = data{
                    print(data)
                    let decoder = JSONDecoder()
                    do {
                        let responseObject = try decoder.decode(ResponseType.self, from: data)
                        DispatchQueue.main.async {
                            completion(responseObject, nil)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
            }
            else{
                completion(nil,error)
            }
        }
        task.resume()
    }
    
    
    
   class func buildRequest(_ parameters: [String:String]) -> URL {
        var components = URLComponents()
        components.scheme = Constants.APIScheme
        components.host = Constants.flickrSearch.host
        components.path = Constants.flickrSearch.path
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
        let queryItem = URLQueryItem(name: key, value: "\(value)")
        components.queryItems!.append(queryItem)
        }
        return components.url!
    }
    
    class func getPhotosByLocation(lat: Double, lon: Double, page: Int, completion: @escaping ([PhotoObject], Error?) -> Void){
        let methodParameters: [String:String] = [
            "method" : Constants.flickrSearch.methodType,
            "api_key" : Constants.flickrApiKey,
            "per_page" : "21",
            "page" : String(page),
            "format" : "json",
            "nojsoncallback" : "1",
            "lat" : String(lat),
            "lon" : String(lon)
            
        ]
        let urlRequest = URLRequest(url: buildRequest(methodParameters))
        
        taskForGETRequest(urlRequest: urlRequest, response: FlickrSearchResponse.self) { response, error in
            guard error == nil else {
                completion([], error)
                return
            }
            if let response = response{
                completion(response.photos.photo, nil)
            }
        }
    }
    
    class func getPicture(_ urlString: String, _ completionHandler: @escaping (_ imageData: Data?, _ error: String?) -> Void) {
        
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completionHandler(nil, error?.localizedDescription)
                return
            }
            completionHandler(data, nil)
        }
        task.resume()
    }
    
    
    
    
    
    
    
    
}
