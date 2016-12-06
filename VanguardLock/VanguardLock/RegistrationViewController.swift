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
    
    var usersData: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
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
        createAccount(username: userEmail, password: userPassword)
        
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
    
    func getInfo() {
        let baseEndPoint = "\(Constant.BASE_API)/user/all"
        guard let url = URL(string: baseEndPoint) else {
            print( "Could not create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        DispatchQueue.main.async {
            let task = session.dataTask(with: urlRequest, completionHandler: {data, response, error in
                if error != nil {
                    print("Error found \(error)")
                    return
                }
                
                guard let responseData = data else {
                    print("No data")
                    return
                }
                
                let users = try! JSONSerialization.jsonObject(with: responseData, options: []) as! NSArray
                self.usersData = users
                
                
            })
            task.resume()
        }
    }
    
    func createAccount(username: String, password: String) {
        let postEndPoint = "\(Constant.BASE_API)/user/post"
        let newID = generateNewIDNumber()
        
        guard let createUserURL = URL(string: postEndPoint) else {
            print("Error: cannot create URL")
            return
        }
        var createUserUrlRequest = URLRequest(url: createUserURL)
        createUserUrlRequest.httpMethod = "POST"
        createUserUrlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let newUser: [String: Any] = ["user_id": newID, "username": username, "password": password]
        let jsonUser: Data
        do {
            jsonUser = try JSONSerialization.data(withJSONObject: newUser, options: [])
            createUserUrlRequest.httpBody = jsonUser
        } catch {
            print("Error: Could not create JSON from newUser")
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: createUserUrlRequest, completionHandler: { (data, response, error) in
            guard error == nil else {
                print("error calling POST on /post/")
                print(error as! String)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            print("Response Data: \(responseData)")
            
            do {
                guard let receivedUser = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Any else {
                    print("Could not get JSON from responseData as dictionary")
                    return
                }
                print("the user is: \(receivedUser)")
                
            } catch let error as Error {
                print("error parsing response from POST on /user/post")
                print(error)
                return
            }
        })
        task.resume()
    }
    
    private func generateNewIDNumber() -> Int{
        var highestID:Int = 0
        if let users = usersData {
            for user in users {
                let userData = user as! [String: AnyObject]
                let userID = userData["user_id"] as! Int
                if(userID > highestID) {
                    highestID = userID
                }
            }
        }
        
        return highestID + 1
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
