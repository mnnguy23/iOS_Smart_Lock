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

    @IBOutlet weak var serialNumberTextField: UITextField!
    @IBOutlet weak var repeatSerialNumberTextField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            if segue.identifier == "saveLockDetail"{
                lock = Lock(lockId: serialNumberTextField.text!, name: nameField.text!, location: addressTextField.text!)
            }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var result = false
        if( identifier == "saveLockDetail") {
            if !(nameField.text?.isEmpty)! {
                if !(serialNumberTextField.text?.isEmpty)! {
                    if !(repeatSerialNumberTextField.text?.isEmpty)! {
                        if !(addressTextField.text?.isEmpty)! {
                            if serialNumberTextField.text! == repeatSerialNumberTextField.text! {
                                createAlert(title: "Success", message: "Device successfully added!")
                                result = true
                            } else {
                                createAlert(title: "Error", message: "Values do not match.")
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

    
    func createAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.alert)
        let alertAct = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(alertAct)
        present(alertVC, animated: true, completion: nil)
    }

}
