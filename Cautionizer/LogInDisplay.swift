//
//  LogInDisplay.swift
//  Cautionizer
//
//  Created by Yaro on 4/27/16.
//  Copyright © 2016 Yaro. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class LogInDisplay: UIViewController, UITextFieldDelegate {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle { return UIStatusBarStyle.LightContent }
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButtonOutlet: UIButton!
    @IBOutlet weak var autoCompleteButton: UIButton!
    
    
    @IBOutlet weak var createAccountOutlet: UIButton!
    
    //MARK: Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameTextField.attributedPlaceholder = NSAttributedString(string:"Email",
                                                                     attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string:"Password",
                                                                          attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        self.autoCompleteButton.hidden = false
        let user = PFUser.currentUser()
        if ((user?.username) != nil) {
            dispatch_async(dispatch_get_main_queue()) {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let main: UIViewController = storyBoard.instantiateViewControllerWithIdentifier("googleMapsView")
                self.presentViewController(main, animated: true, completion: nil)
            }
        }
        
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogInDisplay.textChanged(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
   func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.userNameTextField {
            passwordTextField.becomeFirstResponder()
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textChanged(sender: NSNotification) {
        
        if let uP = self.passwordTextField {
            if let uE = userNameTextField {
                if uP.hasText() && uE.hasText() {
                    signInButtonOutlet.userInteractionEnabled = true
                    self.signInButtonOutlet.alpha = 1 }
                else {
                    signInButtonOutlet.userInteractionEnabled = false
                    self.signInButtonOutlet.alpha = 0.5 }
            }
        }
        
    }
    func disableInteraction () {
        signInButtonOutlet.userInteractionEnabled = false
     //   createAccountOutlet.userInteractionEnabled = false
        userNameTextField.userInteractionEnabled = false
        passwordTextField.userInteractionEnabled = false
    }

    func enableFields() {
        signInButtonOutlet.userInteractionEnabled = true
      //  createAccountOutlet.userInteractionEnabled = true
        userNameTextField.userInteractionEnabled = true
        passwordTextField.userInteractionEnabled = true
        view.endEditing(true)  //Dismisses keyboard if applicable
    }
    
    func animateHUD (labelText: String, detailsLabel: String) {
        let spinAct = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinAct.activityIndicatorColor = UIColor.whiteColor()
        spinAct.label.text = labelText
        spinAct.detailsLabel.textColor = UIColor.whiteColor()
        spinAct.detailsLabel.text = detailsLabel
        spinAct.label.textColor = UIColor.whiteColor()
        spinAct.bezelView.color = UIColor.blackColor()
        //MBProgressHUD.hideAllHUDsForView(self.view, animated: true)  For hiding the HUD
    }
    
    func signUserIn () {
        let user = PFUser()
        user.username = userNameTextField.text
        user.password = passwordTextField.text
        
        disableInteraction()
        
        if Reachability.isConnectedToNetwork() == false {
            JSSAlertView().danger(self, title: "No Internet Connection", text: "Make sure your device is connected to the internet.")
            enableFields()
        }
        else {
            animateHUD("Loading", detailsLabel: "Please Wait")
            PFUser.logInWithUsernameInBackground(userNameTextField.text!, password: passwordTextField.text!, block: {(User: PFUser?, error: NSError?) -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
                if error == nil! {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let main: UIViewController = storyBoard.instantiateViewControllerWithIdentifier("googleMapsView")
                        self.presentViewController(main, animated: true, completion: nil)} }
                else {
                    JSSAlertView().danger(self, title: "Error", text: "Invalid username or password", buttonText:"Try again")
                    self.userNameTextField.text = ""
                    self.passwordTextField.text = ""
                    self.enableFields()
                    self.signInButtonOutlet.userInteractionEnabled = false
                    self.signInButtonOutlet.alpha = 0.5
                }})}}
    
    @IBAction func signInWithFacebookButton(sender: UIButton) {
        let permissions = [ "public_profile", "email", "user_friends" ]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions,  block: {  (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                self.loadFacebookData()
                self.goToAnotherScreen("googleMapsView")
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        })
    }
    
    func loadFacebookData(){
        let myFB_user: PFUser = PFUser.currentUser()!
        let requestParameters = ["fields": "id, email, first_name, last_name"]
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        userDetails.startWithCompletionHandler { (connection, result, error: NSError!) -> Void in
            
            if (result != nil) {
                let userFirstName = result.objectForKey("first_name") as! String
                let userLastName = result.objectForKey("last_name") as! String
                let userEmail = result.objectForKey("email") as! String
                
                var userFullName = userFirstName + " " + userLastName
                
                if (!userFirstName.isEmpty) { myFB_user.setObject(userFullName, forKey: "fullName") }
                if (!userEmail.isEmpty) { myFB_user.setObject(userEmail, forKey: "email") }
                
                myFB_user.saveInBackgroundWithBlock({ (success: Bool, error:NSError?)-> Void in })
            }
        }
        
    }
    
    func goToAnotherScreen (viewController: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(viewController)
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }
    
    
    @IBAction func autofillButton(sender: AnyObject) {
        userNameTextField.text = "test@mail.com"
        passwordTextField.text = "1234"
        self.signInButtonOutlet.userInteractionEnabled = true
        self.signInButtonOutlet.alpha = 1
        
    }
    
    @IBAction func signInButton(sender: AnyObject) {
        signUserIn()
    }

    //To dismiss keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

}
