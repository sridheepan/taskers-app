//
//  DataFetcher.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882

import Foundation
import UIKit

class DataFetcher: ObservableObject {
    
    var apiURL = "https://62898d025da6ddfd5d593f1e.mockapi.io/get-taskers/getAll"
    
    @Published var taskerList = [Tasker]()
    
    //singleton instance
    private static var shared : DataFetcher?
    
    static func getInstance() -> DataFetcher{
        if shared == nil{
            shared = DataFetcher()
        }
        return shared!
    }
    
    func fetchDataFromAPI(){
        
        guard let api = URL(string: apiURL) else{
            print(#function, "Unable to obtain URL from string")
            return
        }
        
        URLSession.shared.dataTask(with: api){ (data : Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                print(#function, error)
            }else{
                
                if let httpResponse = response as? HTTPURLResponse{
                    if httpResponse.statusCode == 200{

                        DispatchQueue.global().async {
                            do{
                                
                                if (data != nil){
                                    if let jsonData = data {
                                        print(#function, jsonData)
                                        
                                        let decoder = JSONDecoder()
                                        var decodedTaskerList = try decoder.decode([Tasker].self, from: jsonData)
//                                        print("API RESPONSE: \(decodedTaskerList)")
                                        
                                        // convert image url to UIImageView
                                        for tasker in decodedTaskerList {
                                            self.fetchImage(from: URL(string: tasker.imageURL)!, withCompletion: {
                                                data in
                                                guard let imageData = data else {
                                                    print("Could not load image from url!")
                                                    return
                                                }
                                                
                                                guard let index = decodedTaskerList.firstIndex(where: {$0.id == tasker.id}) else{
                                                    return
                                                }
                                                decodedTaskerList[index].image = UIImage(data: imageData)!
                                                
                                                DispatchQueue.main.async {
                                                    self.taskerList = decodedTaskerList
                                                }
                                            })
                                        }
                                        
                                    }
                                }
                                
                            }catch let error{
                                print(#function, error)
                            }
                        }
                        
                    }else{
                        print(#function, "Unsuccessful response from network call")
                    }
                }
            }
            
        }.resume() //execute or initiate network call
        
    }
    
    private func fetchImage(from url: URL, withCompletion completion: @escaping(Data?) -> Void){
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (data != nil){
                DispatchQueue.main.async {
                    completion(data)
                }
            }
        }).resume()
    }
    
}
