//
//  HomeViewController.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882

import UIKit
import Foundation
import CoreLocation
import Combine

class HomeViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    private let dataFetcher = DataFetcher.getInstance()
    var taskerList:[Tasker] = [Tasker]()
    var filteredTaskers:[Tasker] = []
    
    private var cancellables : Set<AnyCancellable> = []

    
    // MARK: Outlets
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var taskersTable: UITableView!
    
    // MARK: Local Variables
    let geocoder = CLGeocoder();
    var locationManager: CLLocationManager!
    var gotLocation = false;
    var userLat = 0.0
    var userLng = 0.0
    let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeSearchBar()

        taskersTable.delegate = self
        taskersTable.dataSource = self
        
        self.dataFetcher.fetchDataFromAPI()
        self.receiveChanges()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        // request user permission
        self.locationManager.requestWhenInUseAuthorization()
        self.getUserLocation()
        
        self.taskersTable.rowHeight = 90
        self.taskersTable.reloadData()
        
        self.filteredTaskers = self.taskerList
        
        //Hide BAck Button
        self.navigationItem.hidesBackButton = true
//        self.navigationItem.accessibilityElementsHidden
    }
    
    // MARK: Get User Location
    func getUserLocation() {
        self.locationManager.startUpdatingLocation()
        print("Getting user location....")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Received a Location!")
        if let lastKnowLocation = locations.first {
            let lat = lastKnowLocation.coordinate.latitude
            let lng = lastKnowLocation.coordinate.longitude
            self.userLat = lat
            self.userLng = lng
            self.gotLocation = true;
            
            // Reverse GeoCoding to find user address
            let locationToFind = CLLocation(latitude: lat, longitude: lng)
            geocoder.reverseGeocodeLocation(locationToFind) {
                (resultsList, error) in
                if let err = error {
                    print(#function,"Error! Could not get location")
                    return
                }
                else {
                    let locationResult:CLPlacemark = resultsList!.first!
                    let address = "\(locationResult.name ?? "Error! Could not get location"), \(locationResult.locality ?? "") \( locationResult.postalCode ?? "")"
                    self.userLocation.text = address
                    self.appendDistanceToUser()
                    self.taskersTable.reloadData()
                }
            }
        }
    
    }
    
    private func receiveChanges(){
        self.dataFetcher.$taskerList
            .receive(on: RunLoop.main)
            .sink{(updatedTaskersList) in
                self.taskerList.removeAll()
                self.taskerList.append(contentsOf: updatedTaskersList)
                self.appendDistanceToUser()
                self.taskersTable.reloadData()
                self.filteredTaskers = self.taskerList
                
            }
            .store(in: &cancellables)
    }
    
    // MARK: UITableView data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredTaskers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskerCell", for: indexPath) as! TaskerTableViewCell
        cell.lblName.text = filteredTaskers[indexPath.row].name
        cell.lblTask.text = filteredTaskers[indexPath.row].task
        cell.taskerImg.image = filteredTaskers[indexPath.row].image
        cell.lblDistance.text = "\(filteredTaskers[indexPath.row].distance ?? 0.0) km"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(filteredTaskers[indexPath.row].name)
        guard let nextScreen = storyboard?.instantiateViewController(withIdentifier: "taskerDetail") as? TaskerViewController else {
            print("Cannot find next screen")
            return
        }
        nextScreen.tasker = self.filteredTaskers[indexPath.row]
        navigationController?.pushViewController(nextScreen, animated: true)
    }
    
    // Calculate distance to user and sort by nearest
    func appendDistanceToUser() {
        var temp_arr:[Tasker] = []
        let userlocation = CLLocation(latitude: self.userLat, longitude:  self.userLng) // User location
        for var i in self.taskerList {
            let taskerLocation = CLLocation(latitude: Double(i.latitude)!, longitude: Double(i.longitude)!) // Tasker location
            // distance in km
            let distance = userlocation.distance(from: taskerLocation) / 1000
            i.distance = round(distance * 10) / 10.0
            
            temp_arr.append(i)
        }
        // sort to closest first
        temp_arr.sort {
            $0.distance! < $1.distance!
        }
        self.taskerList = temp_arr
        self.filteredTaskers = temp_arr
    }
    
    // MARK: Search bar configuration
    func initializeSearchBar() {
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Search by Task or Name"
        navigationItem.titleView = searchBar
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredTaskers = []
//        print(#function, searchText)
        // search for name/task containing search criteria
        for tasker in taskerList {
            if tasker.name.lowercased().contains(searchText.lowercased()) || tasker.task.lowercased().contains(searchText.lowercased()) {
                self.filteredTaskers.append(tasker)
            }
        }
        // revert back to normal if searchtext is empty
        if searchText == "" {
            self.filteredTaskers = self.taskerList
        }
        self.taskersTable.reloadData()
    }

}
