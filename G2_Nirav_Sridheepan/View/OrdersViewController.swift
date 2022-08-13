//
//  OrdersViewController.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882

import UIKit
import Foundation
import Combine

class OrdersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: User Defaults
    var defaults:UserDefaults = UserDefaults.standard
    
    //MARK: Variables
    // Variables for DB
    private let db = CoreDBHelper.getInstance()
    var ordersList:[Orders] = [Orders]()
    
    // Variable for Tasker API
    private let dataFetcher = DataFetcher.getInstance()
    var taskerList:[Tasker] = [Tasker]()
    
    // Local Variables
    var loggedInUserID: UUID?
    
    
    // MARK: Outlets
    @IBOutlet weak var ordersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ordersTableView.delegate = self
        ordersTableView.dataSource = self
        
        self.ordersTableView.rowHeight = 100
        self.ordersTableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.taskerList = dataFetcher.taskerList
        
        //Get Orders for logged in user
        self.loggedInUserID = getUserID()
        if(self.loggedInUserID != nil){
            getUserOrders(user_id: self.loggedInUserID!)
        }
        else{
            print(#function, "Logged in user not found")
        }
        
        self.ordersTableView.reloadData()
    }
    
    // MARK: Table View Funcations
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        var numOfSections: Int = 0
        if(self.ordersList.count > 0)
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.systemGreen
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ordersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ScheduleArray = getScheduleArray(date: ordersList[indexPath.row].task_date!)
        let taskObj:Tasker? = getTaskDetails(taskId: ordersList[indexPath.row].tasker_id!)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrdersTableViewCell
        cell.taskerImage.image = taskObj?.image
        cell.lblTaskerName.text = "Name: \(taskObj?.name ?? "NA")"
        cell.lblTask.text = "Task: \(taskObj?.task ?? "NA")"
        cell.lblTaskScheduleDate.text = "Date: \(ScheduleArray[0])"
        cell.lblTaskScheduleTime.text = "Time: \(ScheduleArray[1]) \(ScheduleArray[2])"
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ScheduleArray = getScheduleArray(date: ordersList[indexPath.row].task_date!)
        let taskObj:Tasker? = getTaskDetails(taskId: ordersList[indexPath.row].tasker_id!)
        let isPromocodeUsed = checkIfPromocodeUsed(val: ordersList[indexPath.row].is_promocode_used)
        let discount = ordersList[indexPath.row].promocode_per_val
        
        guard let nextScreen = storyboard?.instantiateViewController(withIdentifier: "updateOrderScreen") as? UpdateOrderViewController else {
            print("Cannot find next screen")
            return
        }
        
        nextScreen.order_id = ordersList[indexPath.row].order_id
        nextScreen.taskerName = "\(taskObj?.name ?? "NA")"
        nextScreen.task = "\(taskObj?.task ?? "NA")"
        nextScreen.scheduleDate = "\(ScheduleArray[0])"
        nextScreen.scheduleTime = "\(ScheduleArray[1]) \(ScheduleArray[2])"
        nextScreen.isPromocodeUsed = "\(isPromocodeUsed)"
        nextScreen.promocode = "\( (discount > 0) ? ordersList[indexPath.row].promocode! : "---" )"
        nextScreen.discount = "\( (discount > 0) ? "\(String(discount))%" : "---" )"
        nextScreen.amountPaid = "$\(ordersList[indexPath.row].order_amount)"
        
        navigationController?.pushViewController(nextScreen, animated: true)
    }
    
    // MARK: Helper Funcations
    private func getUserOrders(user_id: UUID){
        let data = self.db.getAllOrdersForUser(user_id: user_id)
        if (data != nil){
            self.ordersList = data!
            self.ordersTableView.reloadData()
        }
        else{
            print(#function, "Order Data not found in DB")
        }
    }
    
    //get user_id from userdefaults
    func getUserID() -> UUID?{
        var user_id: UUID? = nil
        //check the logged in user
        let loggedInUserID:String? = self.defaults.string(forKey: "loggedInID")
        guard let userId = loggedInUserID else{
            return nil
        }
        
        let uuid = UUID(uuidString: userId)
        if(uuid != nil){
            user_id = uuid
        }
        
        return user_id
    }
    
    func getScheduleArray(date: String) -> [String]{
        return date.components(separatedBy: " ")
    }
    
    func checkIfPromocodeUsed(val: Bool) -> String{
        if(val){
            return "Yes"
        }
        else{
            return "No"
        }
    }
    
    func getTaskDetails(taskId: String) -> Tasker?{
        for currVal in taskerList{
            if(currVal.id == taskId){
                return currVal
            }
        }
        return nil
    }
}
