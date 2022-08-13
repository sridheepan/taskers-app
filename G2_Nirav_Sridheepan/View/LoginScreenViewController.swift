//
//  LoginScreenViewController.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882

import UIKit

class LoginScreenViewController: UIViewController {
    // MARK: User Defaults
    var defaults:UserDefaults = UserDefaults.standard
    
    // MARK: singleton db instance
    private var db = CoreDBHelper.getInstance()
    
    //MARK: Variables
    var loggedInUser:Users? = nil

    // MARK: Outlets
    @IBOutlet weak var loginScreenImage: UIImageView!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var rememberSwitch: UISwitch!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var signUp: UILabel!
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        // Check if user already logged in and remember me switch is on
        if(checkIfUserLoggedIn()){
            loggedInUser = getUserObjUsingID()
            
            guard let user = loggedInUser else{
                print(#function, "Logged in User not found")
                return
            }
            print(#function, "Remember switch is on. redirecting user to home screen")
            //Function call to go to the home screen
            goToHomeScreen(loggedInUser: user)
        }
        super.viewDidLoad()
        
        //Setting the Remember Me Switch Status as per its Stored rememberMe Status in UserDefaults DB
        setRememberMeSwitch()
        
        //Make sign up label clickable
        let signUpLabel = UITapGestureRecognizer(target: self, action: #selector(LoginScreenViewController.signUpPressed))
        signUp.isUserInteractionEnabled = true
        signUp.addGestureRecognizer(signUpLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Setting the Remember Me Switch Status as per its Stored rememberMe Status in UserDefaults DB
        setRememberMeSwitch()
    }
    
    // MARK: Actions
    @IBAction func loginPressed(_ sender: Any) {
        print(#function, "Login Pressed")
        
        //Validating the userEmail
        guard let email = userEmail.text, email.isEmpty == false else{
            let errorMsg = "Email address is mandatory"
            self.errorMessage.text = errorMsg
            print(#function, "\(errorMsg)")
            return
        }
        
        if(!email.isValidEmail){
            let errorMsg = "Please enter a valid email address"
            self.errorMessage.text = errorMsg
            print(#function, "\(errorMsg)")
            return
        }
        
        // Validating the userPassword
        guard let password = userPassword.text, password.isEmpty == false else{
            let errorMsg = "Passowrd is mandatory"
            self.errorMessage.text = errorMsg
            print(#function, "\(errorMsg)")
            return
        }
        
        //check user authorisation
        let loggedInUser:Users? = self.db.searchUser(emailAddress: email, password: password)
        
        guard let loggedInUser = loggedInUser else{
            let errorMsg = "No matching user found"
            self.errorMessage.text = errorMsg
            print(#function, "\(errorMsg)")
            return
        }
    
        print(loggedInUser)
        clearInputsAndError()
        
        //store loggedInUser to singleton db variable
        self.db.addLoggedInUser(loggedInUser: loggedInUser)
        
        //Function call to go to the home screen
        goToHomeScreen(loggedInUser: loggedInUser)
    }
    
    
    // MARK: Helper Functions
    @objc
    func signUpPressed(sender:UITapGestureRecognizer) {
        print("Sign Up Pressed")
        goToSignUp()
    }
    
    //Navigate to home screen function
    func goToHomeScreen(loggedInUser: Users){
        //Checking Remember Me Switch Status
        if(rememberSwitch.isOn){
            // Add Remember Me Switch Status to the UserDefaults
            self.defaults.set(true, forKey:"isRememberSwitchOn")
        }
        
        // Setting the loggedInStatus to the UserDefaults
        self.defaults.set(true, forKey: "loggedInStatus")
                
        // Setting the loggedInUserID to the UserDefaults
        let loggedInUserIDString = loggedInUser.id?.uuidString
        self.defaults.set(loggedInUserIDString, forKey: "loggedInID")
        
        //Get a reference to the home screen
        guard let tabBarView = storyboard?.instantiateViewController(identifier: "tabBarView") as? UITabBarController else {
            print("Cannot find home screen")
            return
        }
        
        //Go to the home screen
        self.navigationController?.pushViewController(tabBarView, animated: true)
    }
    
    //Navigate to signUp screen function
    func goToSignUp(){
        clearInputsAndError()
        
        //Get a reference to the signUp screen
        guard let signUpScreen = storyboard?.instantiateViewController(identifier: "signUpScreen") as? SignUpScreenViewController else {
            print("Cannot find signUp screen")
            return
        }
        
        //Go to the signUp screen
        self.navigationController?.pushViewController(signUpScreen, animated: true)
    }
    
    func clearInputsAndError(){
        self.userEmail.text = ""
        self.userPassword.text = ""
        self.errorMessage.text = ""
    }
    
    func checkIfUserLoggedIn() -> Bool{
        // check remember me value
        let rememberMe:Bool = self.defaults.bool(forKey: "isRememberSwitchOn")
        
        return rememberMe
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
    
    func setRememberMeSwitch(){
        //Setting the Remember Me Switch Status as per its Stored rememberMe Status in UserDefaults DB
        print(#function, self.defaults.bool(forKey: "isRememberSwitchOn"))
        self.rememberSwitch.isOn = self.defaults.bool(forKey: "isRememberSwitchOn")
    }
}

extension String {
   var isValidEmail: Bool {
      let regexForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let email = NSPredicate(format:"SELF MATCHES %@", regexForEmail)
      return email.evaluate(with: self)
   }
}
