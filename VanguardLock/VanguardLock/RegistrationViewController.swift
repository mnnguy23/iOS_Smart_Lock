//
//  RegistrationViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 10/23/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerAccount(_ sender: AnyObject) {
        
        let userEmail = emailTextField.text!
        let userPassword = passwordTextField.text!
        let repeatPassword = repeatPasswordTextField.text!
        
        // Check for empty fields
        if ( userEmail.isEmpty || userPassword.isEmpty || repeatPassword.isEmpty) {
            
            // Display alert message
            displayMyAlertMessage(message: "All fields are required")
            return
        }
        
        if(userPassword != repeatPassword) {
            
            displayMyAlertMessage(message: "Passwords do not match")
            return
        }
        
        
        // Store data: Temporary stored in user defaults for now
        // ToDo: Delete from User defaults
        
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        UserDefaults.standard.set(userPassword, forKey: "userPassword")
        UserDefaults.standard.synchronize()
        
        // Display alert message with confirmation
        
        confirmationMessage(message: "Registration is successful. Thank you!")
    }
    
    
    func displayMyAlertMessage(message: String) {
        let myAlert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok" , style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        present(myAlert, animated: true, completion: nil)
    }
    
    func confirmationMessage(message: String) {
        let myAlert = UIAlertController(title: "Confirmed", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok" , style: UIAlertActionStyle.default) { action in
            self.dismiss(animated: true, completion: nil)
        }
        
        myAlert.addAction(okAction)
        
        present(myAlert, animated: true, completion: nil)
    }
    @IBAction func cancelToLogInScreen(_ sender: UIButton) {
        confirmationMessage(message: "Returning to Log In Screen")
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
