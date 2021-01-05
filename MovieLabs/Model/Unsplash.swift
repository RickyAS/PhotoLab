//
//  Unsplash.swift
//  MovieLabs
//
//  Created by Ricky Austin on 05/01/21.
//

import Foundation
import UIKit

class Unsplash {
    var components = URLComponents(string: "https://api.unsplash.com/photos?")!

    let clientid = "d8a272c480b258b875d82f4062d6c52e4ae7f4b4656add778d71e9b638b2f8be"
    let color = "black_and_white"
    let pageSize = "10"
    
    typealias QueryResult = ([Photos]?, String) -> Void
    
    func getData(page : Int, completion : @escaping QueryResult){
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientid),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "color", value: color),
            URLQueryItem(name: "per_page", value: pageSize)
        ]
        
        let request = URLRequest(url: components.url!)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else { return }
            
            if let data = data {
                if response.statusCode == 200 {
                    let decoder = JSONDecoder()
                    let photos = try! decoder.decode([Photos].self, from: data)
                    DispatchQueue.main.async {
                        completion(photos, "")
                    }
                    
                    
                    

                } else {
                    print("ERROR: \(data), Http Status: \(response.statusCode)")
                }
            }
        }
        task.resume()
    }
}

struct Photos : Codable{
    let id: String
    let width: Int
    
    let color: String
    let urlLinks: URLs
    var image: UIImage?
    var state: DownloadState = .new
    
    
    init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        width = try container.decode(Int.self, forKey: .width)
        
        color = try container.decode(String.self, forKey: .color)
        urlLinks = try container.decode(URLs.self, forKey: .urlLinks)
    }
    
    enum CodingKeys: String, CodingKey{
        case id
        case width
        case color
        case urlLinks = "urls"
    }
    
}

struct URLs: Codable {
   let regular: String
}
