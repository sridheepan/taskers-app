//
//  UpdateOrderViewController.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882

import UIKit

class UpdateOrderViewController: UIViewController {
    // Variables for DB
    private let db = CoreDBHelper.getInstance()
    
    // MARK: Receiving Variables
    var order_id: UUID?
    var taskerName: String = ""
    var task: String = ""
    var scheduleDate: String = ""
    var scheduleTime: String = ""
    var isPromocodeUsed: String = ""
    var promocode: String = ""
    var discount: String = ""
    var amountPaid: String = ""
    
    // MARK: Outlets
    
    @IBOutlet weak var lblTaskerName: UILabel!
    @IBOutlet weak var lblTask: UILabel!
    @IBOutlet weak var lblTaskDate: UILabel!
    @IBOutlet weak var lblTaskTime: UILabel!
    @IBOutlet weak var lblIsPromocodeUsed: UILabel!
    @IBOutlet weak var lblPromocode: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblPaidAmount: UILabel!
    
    @IBOutlet weak var lblUpdateSchedule: UILabel!
    @IBOutlet weak var scheduleDatePicker: UIDatePicker!
    @IBOutlet weak var btnUpdateSchedule: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lblTaskerName.text = self.taskerName
        self.lblTask.text = self.task
        self.lblTaskDate.text = "\(self.scheduleDate)"
        self.lblTaskTime.text = "\(self.scheduleTime)"
        self.lblIsPromocodeUsed.text = self.isPromocodeUsed
        self.lblPromocode.text = self.promocode
        self.lblDiscount.text = discount
        self.lblPaidAmount.text = amountPaid
        
        convertStringToDate(date: "\(self.scheduleDate) \(self.scheduleTime)")
        
        print(self.order_id!)
    }
    
    // MARK: Actions
    
    
    @IBAction func updateSchedulePressed(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        let task_date = dateFormatter.string(from: self.scheduleDatePicker.date)
        
        
        let box = UIAlertController(title: "Confirm Order?", message: "Please tap on confirm button to place the order", preferredStyle: .actionSheet)
        
        // Add some buttons
        box.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        box.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {
            action in
            self.db.updateOrder(order_id: self.order_id!, task_date: task_date)
            self.showSuccessAlert()
            
        }))
        
        self.present(box, animated: true)
    }
    
    // MARK: Helper function
    func convertStringToDate(date: String){
        var dayComponent = DateComponents()
        dayComponent.day = 1
        let theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: Date())
        scheduleDatePicker.minimumDate =  nextDate
        
        let strDate : String! = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = dateFormatter.date(from: strDate)
        self.scheduleDatePicker.datePickerMode = .dateAndTime
        self.scheduleDatePicker.setDate(date!, animated: false)
        
        //Hide Update Schedule Section if date is smaller
        if(date! < nextDate!){
            self.scheduleDatePicker.isHidden = true
            self.lblUpdateSchedule.isHidden = true
            self.btnUpdateSchedule.isHidden = true
        }
    }
    
    func showSuccessAlert(){
        let title = "Success"
        let message = "Order successfully updated"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
            //go to root view controller
            self.navigationController?.popViewController(animated: true)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
