//
//  ProfileViewController.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882

import UIKit
import Foundation

class ProfileViewController: UIViewController {
    
    var defaults:UserDefaults = UserDefaults.standard
    private var db = CoreDBHelper.getInstance()
    private let dataFetcher = DataFetcher.getInstance()
    
    // MARK: Outlets
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.intitalizeProfile()
//        print(self.getUserObjUsingID())
    }
    
    func getUserObjUsingID() -> Users?{
        let loggedInUserID:String? = self.defaults.string(forKey: "loggedInID")
        
        guard let userId = loggedInUserID else{
            let errorMsg = "Logged in user not found"
            print(#function, "\(errorMsg)")
            return nil
        }
        let uuid = UUID(uuidString: userId)
        
        if(uuid != nil){
            guard let user = self.db.searchUserWithID(id: uuid!) else{
                let errorMsg = "Logged in user not found"
                print(#function, "\(errorMsg)")
                return nil
            }
            return user
        }
        else{
            print(#function, "Not valid UUID`")
        }
        return nil
    }
    
    func intitalizeProfile() {
        let userObj = self.getUserObjUsingID()
        if (userObj != nil) {
            self.lblName.text = userObj?.full_name
            self.lblEmail.text = userObj?.email_id
            
            // split date & time
            let dateTime = userObj?.date_created ?? Date()
            let df = DateFormatter()
            df.dateFormat = "MM/dd/yyyy hh:mm a"
            let dateTimeStr = df.string(from: dateTime)
            let dataTimeArr = dateTimeStr.components(separatedBy: " ")
            self.lblDate.text = dataTimeArr[0]
            self.lblTime.text = "\(dataTimeArr[1]) \(dataTimeArr[2])" 
            
            // convert image from binary to UIImage
            let image = UIImage(data: (userObj?.userImage)!)
            self.imgProfile.image = image
        }
        //image formatting
        self.setImageDimensions()
    }
    
    private func setImageDimensions() {
        self.imgProfile.contentMode = UIView.ContentMode.scaleAspectFill
        self.imgProfile.frame.size.width = 250
        self.imgProfile.frame.size.height = 250
        self.imgProfile.layer.cornerRadius = 122
        self.imgProfile.clipsToBounds = true
        self.imgProfile.layer.borderWidth = 3
        self.imgProfile.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        if(self.removeUserDefaults()){
            print("User successfully looged out")
            self.showLogoutConfimation()
        }
        else{
            print("Unable to logout")
        }
    }
    
    func removeUserDefaults() -> Bool{
        var returnVal = false

        //Removeing Remember Me Switch Status from the UserDefaults DB
        self.defaults.removeObject(forKey:"isRememberSwitchOn")
        
        //Removing the loggedInStatus(Key-pair value) in the UserDefaults DB
        self.defaults.removeObject(forKey:"loggedInStatus")
        
        //Removing the loggedInID(Key-pair value) in the UserDefaults DB
        self.defaults.removeObject(forKey: "loggedInID")
        
        // check remember me value
        let rememberMe:Bool = self.defaults.bool(forKey: "isRememberSwitchOn")
        
        if(rememberMe == false){
            returnVal = true
        }
        
        return returnVal
    }
    
    func showLogoutConfimation() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: goToLoginScreen))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: .none))
        present(alert, animated: true)
    }
    
    func goToLoginScreen(alert: UIAlertAction!){
        //go to root view controller
        guard let loginScreen = storyboard?.instantiateViewController(identifier: "signInScreen") as? LoginScreenViewController else {
            print("Cannot find next screen")
            return
        }
        self.navigationController?.pushViewController(loginScreen, animated: true)
    }
    
}
