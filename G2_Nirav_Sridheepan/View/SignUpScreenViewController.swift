//
//  SignUpScreenViewController.swift
//  G2_Nirav_Sridheepan
//  Group 2
//  Nirav - 101395267
//  Sridheepan - 101392882

import UIKit

class SignUpScreenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //singleton db instance
    private var db = CoreDBHelper.getInstance()
    
    //Properties
    var userPictureUploaded = false
    
    // MARK: Outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userFullName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var signInLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Make sign up label clickable
        let signIn = UITapGestureRecognizer(target: self, action: #selector(SignUpScreenViewController.signInPressed))
        signInLabel.isUserInteractionEnabled = true
        signInLabel.addGestureRecognizer(signIn)
        
        self.db.getAllUsers()
        self.setImageDimensions()

    }
    
    // MARK: Actions
    
    @IBAction func uploadPhotoPressed(_ sender: Any) {
        // create an image picker object
        // this object lets us choose the "source" of our photos (camera, photo gallery, etc)
        let imagePicker = UIImagePickerController()
        
        // choose a source for the photos
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera) == true) {
            // - if a camera is available, open the camera and wait for user to take a photo
            print("Camera is available")
            
            // do the code to open the camera and get a photo
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            
            present(imagePicker, animated: true, completion:nil)

        }
        else {
            // - if no camera is available, then open the photo gallery and wait for user to select a photo
            print("Camera is not available")
            
            // do the code to open a photo gallery and get a photo
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            //imagePicker.allowsEditing = true
            
            present(imagePicker, animated: true, completion:nil)

        }
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        print("Sign Up Pressed")
        //Validatig Profile Picture
        if(!userPictureUploaded){
            let errorMsg = "Please upload a photo"
            self.errorMessage.text = errorMsg
            print("\(errorMsg)")
            return
        }
        
        //Validating userFullName
        guard let fullName = userFullName.text, fullName.isEmpty == false else{
            let errorMsg = "Full name is mandatory"
            self.errorMessage.text = errorMsg
            print("\(errorMsg)")
            return
        }
        
        //Validating userEmail
        guard let email = userEmail.text, email.isEmpty == false else{
            let errorMsg = "Email address is mandatory"
            self.errorMessage.text = errorMsg
            print("\(errorMsg)")
            return
        }
        
        if(!email.isValidEmail){
            let errorMsg = "Please enter a valid email address"
            self.errorMessage.text = errorMsg
            print("\(errorMsg)")
            return
        }
        
        if(db.isEmailAddressExist(emailAddress: email)){
            let errorMsg = "Email address already exist in database."
            self.errorMessage.text = errorMsg
            print("\(errorMsg)")
            return
        }
        
        //Validating the userPassword
        guard let password = userPassword.text, password.isEmpty == false else{
            let errorMsg = "Passowrd is mandatory"
            self.errorMessage.text = errorMsg
            print("\(errorMsg)")
            return
        }
        
        print("validation complete")
        let pngImageData  = (self.userImage.image?.pngData())!
        
        clearInputsAndError()
        addUser(email: email, password: password, fullname: fullName, userImage: pngImageData)
        
        showSuccessAlert()
        
        //Function call to go to the home screen
        //goToHomeScreen(userEmail: email)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // This function will execute when the user finishes choosing a photo (or) taking a photo with the camera
        print("User finished selecting a photo.")
        
        //close the popup
        picker.dismiss(animated: true, completion: nil)
        
        // get the photo the person selected
        guard let imageFromPicker = info[.originalImage] as? UIImage else {
            print("Error getting the photo")
            return
        }
        
        // do something with the photo here, for example, display it in an UIImageView outlet
        userImage.image = imageFromPicker
        userPictureUploaded = true
        self.errorMessage.text = ""
        
    }
    
    
    // MARK: Helper Functions
    @objc
    func signInPressed(sender:UITapGestureRecognizer) {
        print("Sign In Pressed")
        goToSignIn()
    }
    
    //Navigate to home screen function
    func goToHomeScreen(userEmail: String){
        
        clearInputsAndError()
        
        //Get a reference to the home screen
        guard let homeScreen = storyboard?.instantiateViewController(identifier: "homeScreen") as? HomeScreenViewController else {
            print("Cannot find home screen")
            return
        }
        
        //Go to the home screen
        self.navigationController?.pushViewController(homeScreen, animated: true)
    }
    
    //Navigate to signIn screen function
    func goToSignIn(){
        //go to root view controller
        navigationController?.popToRootViewController(animated: true)
    }
    
    //Clear Outlets values
    func clearInputsAndError(){
        self.userFullName.text = ""
        self.userEmail.text = ""
        self.userPassword.text = ""
        self.errorMessage.text = ""
    }
    
    //Insert data to Users database
    private func addUser(email:String, password: String, fullname: String, userImage: Data){
        self.db.insertUser(email: email, password: password, fullname: fullname, userImage: userImage)
    }
    
    //user signup success alert
    func showSuccessAlert(){
        let alert = UIAlertController(title: "Success", message: "You have successfully created an account. Please Sign in to continue.", preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
            //go to root view controller
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // set image dimensions
    func setImageDimensions() {
        self.userImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.userImage.frame.size.width = 250
        self.userImage.frame.size.height = 250
        self.userImage.layer.cornerRadius = 122
        self.userImage.clipsToBounds = true
        self.userImage.layer.borderWidth = 3
        self.userImage.layer.borderColor = UIColor.systemGreen.cgColor
    }
}

