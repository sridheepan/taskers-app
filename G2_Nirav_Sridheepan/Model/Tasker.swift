//
//  Tasker.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882


import Foundation
import UIKit

struct Tasker:Decodable {
    
    let id:String
    let name:String
    let age:Int
    let address:String
    let task:String
    let latitude:String
    let longitude:String
    let imageURL:String
    let rate:Int
    var image: UIImage?
    var distance: Double?

    enum TaskerKeys:String, CodingKey {
        case id
        case name
        case age
        case address
        case task
        case latitude
        case longitude
        case image_url
        case rate
    }
    
    init(from decoder: Decoder) throws {
        let taskerContainer = try decoder.container(keyedBy: TaskerKeys.self)
        self.id = try taskerContainer.decodeIfPresent(String.self, forKey: .id) ?? "0"
        self.name = try taskerContainer.decodeIfPresent(String.self, forKey: .name) ?? "Unknown"
        self.age = try taskerContainer.decodeIfPresent(Int.self, forKey: .age) ?? 0
        self.address = try taskerContainer.decodeIfPresent(String.self, forKey: .address) ?? "Unknown"
        self.task = try taskerContainer.decodeIfPresent(String.self, forKey: .task) ?? "Unknown"
        self.latitude = try taskerContainer.decodeIfPresent(String.self, forKey: .latitude) ?? "Unknown"
        self.longitude = try taskerContainer.decodeIfPresent(String.self, forKey: .longitude) ?? "Unknown"
        self.imageURL = try taskerContainer.decodeIfPresent(String.self, forKey: .image_url) ?? "Unknown"
        self.rate = try taskerContainer.decodeIfPresent(Int.self, forKey: .rate) ?? 0
    }
}
