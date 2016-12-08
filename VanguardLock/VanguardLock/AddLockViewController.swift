//
//  AddLockViewController.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 10/31/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit
import MapKit

class AddLockViewController: UIViewController{
    
    var lock:Lock?
    let geoCoder = CLGeocoder()
    var newLockID:Int = 0
    let owner = UserDefaults.standard.integer(forKey: Constant.USER_ID)

    @IBOutlet weak var serialNumberTextField: UITextField!
    @IBOutlet weak var repeatSerialNumberTextField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLockID()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "saveLockDetail" {
                let serialNumber = self.serialNumberTextField.text!
                let name = self.nameField.text!
                let address = "\(self.addressTextField.text!), \(cityTextField.text!), \(stateTextField.text!) \(zipcodeTextField.text!)"
                let id = self.newLockID
                createLock(name: name, number: serialNumber, address: address)
                self.lock = Lock(lockId: id, owner: owner, name: name, location: address, serialNumber: serialNumber, locked: false)
            }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var result = false
        if( identifier == "saveLockDetail") {
            if !(nameField.text?.isEmpty)! {
                if !(serialNumberTextField.text?.isEmpty)! {
                    if !(repeatSerialNumberTextField.text?.isEmpty)! {
                        if !(addressTextField.text?.isEmpty)! {
                            if !(cityTextField.text?.isEmpty)! {
                                if !(stateTextField.text?.isEmpty)! {
                                    if !(zipcodeTextField.text?.isEmpty)! {
                                        if serialNumberTextField.text! == repeatSerialNumberTextField.text! {
                                                createAlert(title: "Success", message: "Device successfully added!")
                                                result = true
                                        } else {
                                            createAlert(title: "Error", message: "Values do not match.")
                                        }
                                    } else {
                                        createAlert(title: "Error", message: "Value missing from Zip Code Field")
                                    }
                                } else {
                                    createAlert(title: "Error", message: "Value missing from State field")
                                }
                            } else {
                                createAlert(title: "Error", message: "Value missing from City field")
                            }
                        } else {
                            createAlert(title: "No Address", message: "Value missing from address field")
                        }
                    } else {
                        createAlert(title: "Error", message: "Value missing in second field.")
                    }
                } else {
                    createAlert(title: "Error", message: "Value missing in first field.")
                }
            } else {
                createAlert(title: "Error", message: "Name is missing.")
            }
        }
        return result
    }
    
    private func createLockID() {
        let baseEndPoint = "\(Constant.BASE_API)/lock/all"
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
                
                let locks = try! JSONSerialization.jsonObject(with: responseData, options: []) as! NSArray
                var currentLockID = 0
                for lock in locks {
                    if let lockData = lock as? [String: AnyObject] {
                        let lockID = lockData["lock_id"] as! Int
                        
                        if(lockID > currentLockID) {
                            currentLockID = lockID
                        }
                    }
                }
                self.newLockID = currentLockID + 1
            })
            task.resume()
        }
    }
    
    private func createLock(name: String, number: String, address: String) {
        let postEndPoint = "\(Constant.BASE_API)/lock/post"
        
        guard let createLockURL = URL(string:postEndPoint) else {
            print("Error: cannot create URL")
            return
        }
        
        var createLockUrlRequest = URLRequest(url: createLockURL)
        createLockUrlRequest.httpMethod = "POST"
        createLockUrlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let newLock: [String: Any] = ["lock_id": newLockID, "lock_state": false, "lock_name": name, "serial_number": number, "address": address, "owner": self.owner]
        let jsonLock: Data
        
        do {
            jsonLock = try JSONSerialization.data(withJSONObject: newLock, options: .prettyPrinted)
            createLockUrlRequest.httpBody = jsonLock
        } catch {
            print("Error: Could not create JSON from newLock")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: createLockUrlRequest,
                                    completionHandler: { data, response, error in
                                        guard error == nil else {
                                            print("Error calling Post on /lock/post/")
                                            print(error as! String)
                                            return
                                        }
                                        guard let responseData = data else {
                                            print("Error: did not receive data")
                                            return
                                        }
                                        
                                        do {
                                            guard let receivedLock = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Any else {
                                                print("Could not get JSON from responseData as Any")
                                                return
                                            }
                                        } catch let error as Error {
                                            print("error parsing response from POST on /lock/post")
                                            print(error)
                                            return
                                        }
        })
        task.resume()
    }
    
    
    
    func createAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.alert)
        let alertAct = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(alertAct)
        present(alertVC, animated: true, completion: nil)
    }

}
