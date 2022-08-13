//
//  TaskerViewController.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882

import UIKit

class TaskerViewController: UIViewController {
    //------------------------------------------------
    // MARK: User Defaults
    var defaults:UserDefaults = UserDefaults.standard
    
    // MARK: singleton db instance
    private var db = CoreDBHelper.getInstance()
    
    //MARK: Variables
    var loggedInUserID: UUID?
    var isPromocodeUsed = false
    var tasker:Tasker?
    let promocode: String = "CANADA20"
    let discountPercentage:Double = 20
    var finalHiringRate: Double = 0.0
    
    // MARK: Outlets
    @IBOutlet weak var taskerImg: UIImageView!
    @IBOutlet weak var lblTaskerName: UILabel!
    @IBOutlet weak var lblDesignation: UILabel!
    @IBOutlet weak var buttonHire: UIButton!
    @IBOutlet weak var scheduleDatePicker: UIDatePicker!
    @IBOutlet weak var txtPromocode: UITextField!
    @IBOutlet weak var lblApplyPromocode: UILabel!
    @IBOutlet weak var lblPromocodeMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let height: CGFloat = 20 //whatever height you want to add to the existing height
        let bounds = self.navigationController!.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.taskerImg.image = self.tasker?.image
        self.lblTaskerName.text = "\(self.tasker!.name), \(self.tasker!.age)"
        self.lblDesignation.text = self.tasker!.task
        self.buttonHire.setTitle("Hire for $\(self.tasker!.rate)", for: .normal)
        self.setImageDimensions()
        
        
        self.finalHiringRate = Double(self.tasker!.rate)
        self.lblPromocodeMessage.text = ""
        
        //Make Apply label clickable
        let apply = UITapGestureRecognizer(target: self, action: #selector(TaskerViewController.applyPressed))
        lblApplyPromocode.isUserInteractionEnabled = true
        lblApplyPromocode.addGestureRecognizer(apply)
        
        //date picker minimum date
        var dayComponent = DateComponents()
        dayComponent.day = 1
        let theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: Date())
        scheduleDatePicker.minimumDate =  nextDate
        
        //check the logged in user
        let loggedInUserID:String? = self.defaults.string(forKey: "loggedInID")
        guard let userId = loggedInUserID else{
            let errorMsg = "Logged in user not found"
            print("\(errorMsg)")
            return
        }
        let uuid = UUID(uuidString: userId)

        if(uuid != nil){
            self.loggedInUserID = uuid
        }
        else{
            print("Not valid UUID`")
        }

    }
    
    private func setImageDimensions() {
        self.taskerImg.contentMode = UIView.ContentMode.scaleAspectFill
        self.taskerImg.layer.cornerRadius = self.taskerImg.frame.size.height/2
        self.taskerImg.clipsToBounds = true
        self.taskerImg.layer.borderWidth = 3
        self.taskerImg.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    
    // MARK: Actions
    @IBAction func hireButtonPressed(_ sender: Any) {
        print("button pressed")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        let task_date = dateFormatter.string(from: self.scheduleDatePicker.date)
        
        if(self.loggedInUserID != nil){
            let box = UIAlertController(title: "Confirm Order?", message: "Please tap on confirm button to place the order", preferredStyle: .actionSheet)
            
            // Add some buttons
            box.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            box.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {
                action in
                self.db.insertOrder(user_id: self.loggedInUserID!, tasker_id: self.tasker!.id, task_date: task_date, is_promocode_used: self.isPromocodeUsed, promocode: self.promocode, promocode_per_val: Int(self.discountPercentage), order_amount: self.finalHiringRate)
                
                self.showSuccessAlert(alertType: "order")
                
            }))
            
            self.present(box, animated: true)
        }
    }
    
    // MARK: Helper Function
    @objc
    func applyPressed(sender:UITapGestureRecognizer) {
        print("Apply Pressed")
        
        //Validating promocode
        guard let promo = txtPromocode.text, promo.isEmpty == false else{
            let errorMsg = "Please enter promocode"
            self.lblPromocodeMessage.textColor = UIColor.red
            self.lblPromocodeMessage.text = errorMsg
            print(#function, "\(errorMsg)")
            return
        }
        
        if(promo == self.promocode){
            self.isPromocodeUsed = true
            self.lblPromocodeMessage.textColor = UIColor.systemGreen
            self.lblPromocodeMessage.text = "20% Discount Applied"
            
            self.finalHiringRate = getDiscountedRate()
            self.buttonHire.setTitle("Hire for $\(self.finalHiringRate)", for: .normal)
            showSuccessAlert(alertType: "promocode")
        }
        else{
            self.lblPromocodeMessage.textColor = UIColor.red
            self.lblPromocodeMessage.text = "Invalid Promocode"
        }
    }
    
    // Alert
    func showSuccessAlert(alertType: String){
        let title = "Success"
        var message = ""
        if(alertType == "order"){
            message = "Order successfully placed"
        }
        else if(alertType == "promocode"){
            message = "Promocode successfully applied"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
            if(alertType == "order"){
                //go to previous screen
                self.navigationController?.popViewController(animated: true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //promocode discount function
    func getDiscountedRate() -> Double{
        let original_rate = Double(self.tasker!.rate)
        let discount = (original_rate * self.discountPercentage)/100
        return original_rate - discount
    }
}
