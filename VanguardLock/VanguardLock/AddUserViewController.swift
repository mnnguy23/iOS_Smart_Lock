//
//  AddUserViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 12/7/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class AddUserViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var locks:[Lock] = []
    var selectedLock:Lock?
    var currentUsers:[User] = []
    var selectedUser:User?
    
    @IBOutlet weak var lockPickerView: UIPickerView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var verifyUserButton: UIButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyUserButton.layer.cornerRadius = 0.50 * verifyUserButton.bounds.size.height
        doneButton.isEnabled = false
        self.lockPickerView.delegate = self
        self.lockPickerView.dataSource = self
        DispatchQueue.main.async {
            self.getInfo()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveUser" {
            addUsertoLock()
        }
     }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locks[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLock = locks[row]
    }
    
    @IBAction func verify(_ sender: Any) {
        if (usernameTextField.text?.isEmpty)! {
            displayMyAlertMessage(title: "Error", message: "Username required.")
        } else {
            let results = checkUserId()
            if results.0 {
                selectedUser = results.1
                doneButton.isEnabled = results.0
                displayMyAlertMessage(title: "Found", message: "Username \(usernameTextField.text!) exists.")
            } else {
                displayMyAlertMessage(title: "Error", message: "Username does not exist.")
                doneButton.isEnabled = results.0
            }
        }
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func checkUserId() -> (Bool, User) {
        var result = false
        var selectedUser:User?
        if let username = usernameTextField.text {
            for user in currentUsers {
                if user.username == username {
                    result = true
                    selectedUser = user
                }
            }
        }
        return (result, selectedUser!)
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
                do {
                    let users = try JSONSerialization.jsonObject(with: responseData, options: []) as? NSArray
                    for user in users! {
                        let userData = user as! [String: AnyObject]
                        let userId = userData["user_id"] as! Int
                        let username = userData["username"] as! String
                        let newUser = User(id: userId, username: username)
                        self.currentUsers.append(newUser)
                    }
                } catch {
                    self.displayMyAlertMessage(title: "Error", message: "Currently unable to gather information. Try again shortly")
                }
                
            })
            task.resume()
        }
    }
    
    func addUsertoLock() {
        let postEndPoint = "\(Constant.BASE_API)/lock_user_auth/post"
        guard let createUserURL = URL(string: postEndPoint) else {
            print("Error: cannot create URL")
            return
        }
        var createUserUrlRequest = URLRequest(url: createUserURL)
        createUserUrlRequest.httpMethod = "POST"
        createUserUrlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        guard let lock = self.selectedLock else {
            print("Lock not selectd.")
            return
        }
        guard let user = self.selectedUser else {
            print("No user found.")
            return
        }
        print(lock.lockId)
        print(user.id)
        let newUserAuth: [String: Any] = ["lock_id": lock.lockId, "user_id": user.id]
        let jsonUserAuth: Data
        
        do {
            jsonUserAuth = try JSONSerialization.data(withJSONObject: newUserAuth, options: .prettyPrinted)
            createUserUrlRequest.httpBody = jsonUserAuth
        } catch {
            print("Error: Could not create JSON from newUserAuth")
            return
        }
        let session = URLSession.shared
        
        /// ToDo: Backend needs to be look at to see why the response is not working
        DispatchQueue.main.async {
            let task = session.dataTask(with: createUserUrlRequest,
                                        completionHandler: { data, response, error in
                                            guard error == nil else {
                                                print("Error calling /locker_user_auth/post")
                                                print(error as! String)
                                                return
                                            }
                                            
                                            guard let responseData = data else {
                                                print("Error: did not received data")
                                                return
                                            }
                                            
                                            do {
                                                guard let receivedUserAuth = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Any else {
                                                    print("Could not get JSON from responseData as Any")
                                                    return
                                                }
                                                print("received: \(receivedUserAuth)")
                                            } catch let error as Error {
                                                print("error parsing response from POST on /lock/post")
                                                print(error)
                                                return
                                            }
            })
            task.resume()
        }
        
        for currentLock in locks {
            if currentLock.lockId == lock.lockId {
                currentLock.users.append(user)
            }
        }
    }
    
    func displayMyAlertMessage(title: String, message: String) {
        let myAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok" , style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        present(myAlert, animated: true, completion: nil)
    }
}
