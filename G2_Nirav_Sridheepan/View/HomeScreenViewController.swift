//
//  HomeScreenViewController.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882

import UIKit

class HomeScreenViewController: UIViewController {
    // MARK: User Defaults
    var defaults:UserDefaults = UserDefaults.standard
    
    // MARK: singleton db instance
    private var db = CoreDBHelper.getInstance()
    
    //MARK: Variables
    var loggedInUser:Users? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check remember me value
        let rememberMe:Bool = self.defaults.bool(forKey: "isRememberSwitchOn")
        print("Is remember me? \(rememberMe)")
        
        //check the logged in user
        let loggedInUserID:String? = self.defaults.string(forKey: "loggedInID")
        print("Logged in user email: \(loggedInUserID ?? "NA")")
        
        guard let userId = loggedInUserID else{
            let errorMsg = "Logged in user not found"
            print("\(errorMsg)")
            return
        }
        let uuid = UUID(uuidString: userId)
        
        
        
        if(uuid != nil){
            self.loggedInUser = self.db.searchUserWithID(id: uuid!)
            guard let user = loggedInUser else{
                let errorMsg = "Logged in user not found"
                print("\(errorMsg)")
                return
            }
            print(user)
        }
        else{
            print("Not valid UUID`")
        }
        
        
        
        
        
        
        
        //Hide BAck Button
        self.navigationItem.hidesBackButton = true
        
        //set loffed in user object
//        self.loggedInUser = self.db.getLoggedInUser()
//        guard let user = loggedInUser else{
//            let errorMsg = "Logged in user not found"
//            print("\(errorMsg)")
//            return
//        }
        
        //print(user)
        
        //Navigation bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
    }
    
    // MARK: Helper Functions
    @objc func logoutTapped() {
        print("nirav kumbhare return value \(removeUserDefaults())")
        if(removeUserDefaults()){
            print("User successfully looged out")
            goToLoginScreen()
        }
        else{
            print("Unable to logout")
        }
    }
    
    func removeUserDefaults() -> Bool{
        var returnVal = false
        //Removeing the required Key-Value Pairs from the UserDefaults DB
//        DispatchQueue.main.async {
//
//        }
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
    
    func goToLoginScreen(){
        //go to root view controller
        navigationController?.popToRootViewController(animated: true)
    }

}
